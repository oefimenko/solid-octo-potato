
defmodule API.Router.Ping do
  use Maru.Router
    
  resource do
    get do
      text(conn, "Alive")
    end
  end
end

defmodule API.Router.Login do
  use Maru.Router
    
  resource :login do
    params do
      requires :user_name, type: String
    end
    post do
      ip = conn.remote_ip
      Rooms.Lobby.login(params.user_name, ip)
      json(conn, %{})
    end
  end
end

defmodule API.Router.Skirmish do
  use Maru.Router   

  resource :skirmish do
    params do
      requires :user_name, type: Integer
    end
    post do
      Rooms.Lobby.match(params.user_name)
      json(conn, "Please, wait for oponent")
    end

  end

end


defmodule API.Router do
  use Maru.Router
 
  plug Plug.Parsers,
    pass: ["*/*"],
    json_decoder: Poison,
    parsers: [:urlencoded, :json, :multipart]

  mount API.Router.Login
  mount API.Router.Skirmish
  mount API.Router.Ping

  rescue_from :all do
    conn
    |> put_status(500)
    |> text("Server Error")
  end

end
