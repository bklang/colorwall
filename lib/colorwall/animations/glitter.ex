defmodule Colorwall.Animations.Glitter do

  use Colorwall.Animations

  alias Colorwall.APA102
  alias Colorwall.RGBI

  def step(opts) do
    scale = 0.95
    Enum.map(APA102.get_strip(), fn(led) ->
      case led do
        %RGBI{r: 0, g: 0, b: 0} ->
          if (Enum.random(1..100) == 1) do
            intensity = random_intensity()
            %RGBI{r: intensity, g: intensity, b: intensity}
          else
            led
          end
        %RGBI{} ->
          %RGBI{r: trunc(led.r*scale), g: trunc(led.g*scale), b: trunc(led.b*scale)}
      end |> APA102.validate_pixel()
    end) |> APA102.set_strip()
    opts
  end
end
