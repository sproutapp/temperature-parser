defmodule Temperature.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Temperature.Consumer, [
        [
          exchange: "sprout.sensors.readings",
          queue: "sprout.sensors.temperature",
          options: [
            exchange: [
              type: :fanout
            ]
          ]
        ]
      ], restart: :permanent)
    ]

    supervise(children, strategy: :one_for_one, max_seconds: 1)
  end
end
