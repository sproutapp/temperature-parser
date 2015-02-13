defmodule Temperature.Consumer do
  use GenServer
  import Microbrew.Agent

  def start_link(_ \\ [], opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  def init(options) do
    a = agent(options)
    start_consuming(a)

    {:ok, a}
  end

  defp agent(options) do
    Microbrew.Agent.new(
      exchange: options[:exchange],
      queue: options[:queue],
      queue_error: "#{options[:queue]}_error"
    )
  end

  defp start_consuming(agent) do
    agent
      |> signal("sensor::received")
      |> stream
      |> consume agent
  end

  defp consume(stream, agent) do
     for value <- stream |> Stream.map(&parse/1) |> Stream.reject(&is_nil/1) do
       publish agent, value
     end
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
