defmodule Colorwall.RGBI do
  # One accessor each for Red, Green, Blue, and Intensity
  # FIXME: magic number 31 is 5 bits of brightness
  defstruct r: 0, g: 0, b: 0, i: 31
end
