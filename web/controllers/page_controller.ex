defmodule Colorwall.PageController do
  use Colorwall.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
