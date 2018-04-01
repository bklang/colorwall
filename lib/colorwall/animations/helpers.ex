defmodule Colorwall.Animations.Helpers do
  alias Colorwall.RGBI

  def random_color() do
    %RGBI{r: random_intensity(), g: random_intensity(), b: random_intensity()}
  end

  def random_intensity() do
    Enum.random(0..255)
  end
end