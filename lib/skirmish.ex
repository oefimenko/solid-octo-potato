
defmodule Skirmish do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Rooms.Lobby, [])
    ]

    # Start the main supervisor, and restart failed children individually
    opts = [strategy: :one_for_one, name: AcmeUdpLogger.Supervisor]
    Supervisor.start_link(children, opts)
  end
  
end
