defmodule Temperature.Consumer do
  import Microbrew.Agent

  def start_link(_ \\ [], options) do
    pid = spawn_link fn -> start_consuming(options) end
    {:ok, pid}
  end

  def start_consuming(options) do
    agent(options)
      |> signal("sensor::received")
      |> stream
      |> consume agent(options)
  end

  defp agent(options) do
    Microbrew.Agent.new(
      exchange: options[:exchange],
      queue: options[:queue],
      queue_error: "#{options[:queue]}_error",
      options: options[:options]
    )
  end

  defp consume(stream, agent) do
    for value <- stream |> Stream.map(&parse/1) |> Stream.reject(&is_nil/1) do
      publish agent, value
    end

    :timer.sleep(1000)
    :shutdown
  end

  defp parse({payload, meta}) do
    reading = payload["data"]["reading"]
    type = Regex.run ~r/temperature/, reading

    cond do
      hd(type) == "temperature" -> {Temperature.Parser.parse(reading), meta}
      true -> nil
    end
  end

  defp publish(agent, {temperature, meta}) do
    AMQP.Basic.ack agent.consumer.channel, meta[:delivery_tag]

    agent
      |> signal("temperature::new")
      |> emit(%{ :temperature => temperature })
  end
end
