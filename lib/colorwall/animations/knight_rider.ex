defmodule Colorwall.Animations.KnightRider do

  use Colorwall.Animations

  alias Colorwall.APA102
  alias Colorwall.RGBI

  @defaults %{
    head: 0,
    direction: 1,
    width: 5,
    color: %RGBI{r: 255}
  }

  @black %RGBI{}

  def step(opts) do
    opts = Map.merge(@defaults, opts)

    strip = APA102.get_strip()
    strip_len = length(strip)

    strip
    |> List.replace_at(contain_idx(opts.head + opts.direction, strip_len), opts.color)
    |> List.replace_at(contain_idx(opts.head - (opts.width)*opts.direction, strip_len), @black)
    |> APA102.set_strip()

    new_direction = cond do
      opts.head >= strip_len -> -1
      opts.head <= 0 -> 1
      true -> opts.direction
    end

    Map.merge(opts, %{head: opts.head + new_direction, direction: new_direction})
  end
end
