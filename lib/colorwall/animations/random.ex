defmodule Colorwall.Animations.Random do

  use Colorwall.Animations

  alias Colorwall.APA102
  alias Colorwall.RGBI

  def step(opts) do
    leds = APA102.get_strip()
    Enum.map(leds, fn(led) ->
      case led do
        %RGBI{r: 0, g: 0, b: 0} ->
          random_color()
        %RGBI{} ->
          %RGBI{r: div(led.r, 2), g: div(led.g, 2), b: div(led.b, 2)}
      end |> APA102.validate_pixel()
    end) |> APA102.set_strip()
    opts
  end
end
