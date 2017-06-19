
defmodule API.Router.Login do
  use Maru.Router
    
  resource :login do
    params do
      requires :username, type: String
      requires :password, type: String
    end
    post do
      json(conn, params)
    end
  end
end

defmodule API.Router.Skirmish do
  use Maru.Router   

  resource :skirmish do
    post do
      text(conn, "Please, wait for oponent")
    end

    delete do
      text(conn, "Cancel skirmish wait")
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

  rescue_from :all do
    conn
    |> put_status(500)
    |> text("Server Error")
  end

end
