defmodule Temperature.Consumer do
  use GenServer
  use AMQP
  import JSX
  import Temperature.Parser
  alias Temperature.Parser, as: Parser

  defmodule Payload do
    defstruct event: nil, data: nil
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], [])
  end

  @exchange    "sprout.sensors.readings"
  @queue       "sensor::received"
  @queue_error "#{@queue}_error"

  def init(_opts) do
    {:ok, conn} = Connection.open("amqp://guest:guest@localhost")
    {:ok, chan} = Channel.open(conn)
    # Limit unacknowledged messages to 10
    Basic.qos(chan, prefetch_count: 10)
    Queue.declare(chan, @queue_error, durable: true)
    # Messages that cannot be delivered to any consumer in the main queue will be routed to the error queue
    Queue.declare(chan, @queue, durable: true, arguments: [
      {"x-dead-letter-exchange", :longstr, ""},
      {"x-dead-letter-routing-key", :longstr, @queue_error}
    ])
    Exchange.topic(chan, @exchange, durable: true)
    Queue.bind(chan, @queue, @exchange)
    # Register the GenServer process as a consumer
    Basic.consume(chan, @queue)
    {:ok, chan}
  end

  def handle_info({payload, %{delivery_tag: tag, redelivered: redelivered}}, chan) do
    spawn fn -> consume(chan, tag, redelivered, payload) end
    {:noreply, chan}
  end

  defp publish(data) do
    {:ok, conn} = Connection.open("amqp://guest:guest@localhost")
    {:ok, channel} = Channel.open(conn)

    payload = %Payload{
      event: "temperature::new",
      data: data
    }
    {_, payload} = JSX.encode(payload)

    IO.puts "publishing #{payload}"

    Basic.publish channel, @exchange, "", payload

    Connection.close(conn)
  end

  defp consume(channel, tag, redelivered, payload) do
    {_, payload} = JSX.decode(payload)

    try do
      case payload["event"] do
        "sensor::received" ->
          reading = payload["data"]["reading"]
          [type] = Regex.run ~r/temperature/, reading

          if type == "temperature" do
            temperature = Parser.parse(reading)
            publish(temperature)
            Basic.ack channel, tag
          end
      end
    rescue
      exception ->
        Basic.reject channel, tag, requeue: not redelivered
        IO.puts "Error parsing #{payload}, #{exception}"
    end
  end
end
