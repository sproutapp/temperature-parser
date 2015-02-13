defmodule TemperatureConsumerTest do
  use Pavlov.Case
  import Pavlov.Syntax.Expect
  import Temperature.Consumer

  describe "Temperature Consumer" do
    describe ".start_link" do
      let :payload do
        %{
          "event" => "sensor::received",
          "data" => %{ "reading" => "temperature::55" },
          "cid" => 12345
        }
      end

      let :temperature do
        %{:temperature => Temperature.Parser.parse("temperature::55")}
      end

      before :each do
        stream = Stream.resource(
          fn ->
            {:ok, pid} = Agent.start_link fn -> 0 end
            pid
          end,
          fn agent ->
            Agent.update agent, fn counter -> counter + 1 end
            count = Agent.get agent, fn counter -> counter end

            cond do
              count == 1 -> { [{ payload, [delivery_tag: "a_tag"] }], agent}
              true      -> {:halt, agent}
            end
          end,
          fn agent -> agent end
        )

        allow(Microbrew.Consumer, [:no_link, :passthrough])
          |> to_receive(new: fn _, queue, _ -> {:ok, %Microbrew.Consumer{channel: %AMQP.Channel{}, queue: queue}} end)

        allow(Microbrew.Agent, [:no_link, :passthrough])
          |> to_receive(stream: fn _ -> stream end)
          |> to_receive(emit: fn _, _ -> nil end)

        allow(AMQP.Basic)
          |> to_receive(ack: fn _, _ -> :ok end)

        :ok
      end

      it "publishes temperatures consumed from an exchange & queue" do
        Temperature.Consumer.start_link [], %{ :exchange => "exchange", :queue => "queue" }

        expect(Microbrew.Agent)
          |> to_have_received :emit
          |> with([:_, temperature])
      end

      it "acknowledges correctly parsed messages" do
        Temperature.Consumer.start_link [], %{ :exchange => "exchange", :queue => "queue" }

        expect(AMQP.Basic)
          |> to_have_received :ack
          |> with([%AMQP.Channel{}, "a_tag"])
      end
    end
  end
end
