defmodule ColorwallWeb.ColorController do
  use ColorwallWeb, :controller

  alias Colorwall.APA102
  alias Colorwall.RGBI

  def set_color(conn, _params = %{"r" => r, "g" => g, "b" => b}) do
    r = String.to_integer(r)
    g = String.to_integer(g)
    b = String.to_integer(b)
    APA102.set_strip(%RGBI{r: r, g: g, b: b})
    APA102.show()

    send_resp(conn, 202, "")
  end
end
