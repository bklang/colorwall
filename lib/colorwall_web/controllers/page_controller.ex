defmodule ColorwallWeb.PageController do
  use ColorwallWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
