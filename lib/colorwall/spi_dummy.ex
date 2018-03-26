defmodule Colorwall.SPIDummy do
  require Logger

  import ExPrintf

  use GenServer

  def start_link(_devname, _spi_opts \\ [], opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(args) do
    {:ok, args}
  end

  def release(_pid) do
    {:noreply}
  end

  def transfer(_pid, data) do
    size = byte_size(data)
    parse_printf("SPI[%04d]: %s")
    |> :io_lib.format([size, inspect(data, limit: size)])
    |> Logger.debug

    Enum.map(0..byte_size(data), fn(_) -> <<0>> end)
  end
end