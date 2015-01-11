defmodule Temperature do
  use Application

  def start(_type, _args) do
    Temperature.Supervisor.start_link
  end
end
