defmodule Colorwall.Animator do
  require Logger

  def start_animating(mode, mode_opts \\ []) do
    {:ok, pid} = Task.start_link(mode, :run, mode_opts)
  end
end
