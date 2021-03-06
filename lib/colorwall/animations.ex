defmodule Colorwall.Animations do
  alias Colorwall.APA102
  alias Colorwall.RGBI

  require Logger

  defmacro __using__(_) do
    quote do
      import Colorwall.Animations.Helpers

      def run(opts \\ %{}) do
        new_opts = step(opts)
        APA102.show()
        run(new_opts)
      end
    end
  end
end
