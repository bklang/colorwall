defmodule Colorwall.Animations.Helpers do
  alias Colorwall.RGBI

  def random_color() do
    %RGBI{r: random_intensity(), g: random_intensity(), b: random_intensity()}
  end

  def random_intensity() do
    Enum.random(0..255)
  end

  @doc """
  Clamp the index value to within the length of the strip
  require the strip_len, rather than calculating it, since calling length() on a list
  is relatively expensive, and this function may be called inside a time-sensitive loop
  """
  def contain_idx(idx, strip_len) do
    Enum.min([strip_len - 1, Enum.max([0, idx])])
  end
end