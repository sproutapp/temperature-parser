defmodule Temperature.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Temperature.Consumer, [queue: "sprout.sensors.readings"]),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
