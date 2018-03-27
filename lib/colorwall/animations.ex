defmodule Colorwall.Animations do
  alias Colorwall.APA102
  alias Colorwall.RGBI

  require Logger

  def led_count() do
    leds = APA102.get_strip
    tuple_size(leds) - 1
  end

  def rainbow_glitter() do
    leds = APA102.get_strip()
    Enum.map(leds, fn(led) ->
      case led do
        %RGBI{r: 0, g: 0, b: 0} ->
          random_color()
        %RGBI{} ->
          %RGBI{r: div(led.r, 2), g: div(led.g, 2), b: div(led.b, 2)}
      end |> APA102.validate_pixel()
    end) |> APA102.set_strip()
    APA102.show()
  end

  def random_fade() do
    leds = APA102.get_strip()
    scale = 0.95
    Enum.map(leds, fn(led) ->
      led = case led do
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
    APA102.show()
  end

  def random_color() do
    %RGBI{r: random_intensity(), g: random_intensity(), b: random_intensity()}
  end

  def random_intensity() do
    Enum.random(0..255)
  end
end

alias Colorwall.Animations
Enum.map(0..10000, fn(_) -> Animations.random_fade() end)