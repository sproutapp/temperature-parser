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
      |> on(:data, fn (payload, meta) ->
        temperature = consume(payload, meta)
        if (temperature) do
          publish(agent, temperature)
        end
      end)
  end

  defp consume(payload, _) do
    reading = payload["reading"]
    [type] = Regex.run ~r/temperature/, reading

    if type == "temperature" do
      Temperature.Parser.parse(reading)
    else
      nil
    end
  end

  defp publish(agent, temperature) do
    agent
      |> signal("temperature::new")
      |> emit(%{ :temperature => temperature })
  end
end
