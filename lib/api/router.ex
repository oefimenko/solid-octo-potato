
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
      Rooms.Lobby.login(params.user_name)
      json(conn, %{})
    end
  end
end

defmodule API.Router.Skirmish do
  use Maru.Router   

  resource :skirmish do
    params do
      requires :user_name, type: String
    end
    post do
      result = Rooms.Lobby.match(params.user_name)
      json(conn, result)
    end

  end

end

defmodule API.Router.Training do
  use Maru.Router   

  resource :training do
    params do
      requires :user_name, type: String
    end
    post do
      result = Rooms.Lobby.training(params.user_name)
      json(conn, result)
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
  mount API.Router.Training

  rescue_from :all do
    conn
    |> put_status(500)
    |> text("Server Error")
  end

end
