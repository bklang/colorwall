defmodule Colorwall.APA102 do
  """
    Driver for APA102 LEDS (aka "DotStar").
    Derived from the Python APA102 library by Martin Erzberger, especially
    these inline docs (Thanks!)

    Accepted messages:
     - :set_pixel
     - :set_strip
     - :set_max_brightness
     - :show

    Very brief overview of APA102: An APA102 LED is addressed with SPI. The bits
    are shifted in one by one, starting with the least significant bit.
    An LED usually just forwards everything that is sent to its data-in to
    data-out. While doing this, it remembers its own color and keeps glowing
    with that color as long as there is power.
    An LED can be switched to not forward the data, but instead use the data
    to change it's own color. This is done by sending (at least) 32 bits of
    zeroes to data-in. The LED then accepts the next correct 32 bit LED
    frame (with color information) as its new color setting.
    After having received the 32 bit color frame, the LED changes color,
    and then resumes to just copying data-in to data-out.
    The really clever bit is this: While receiving the 32 bit LED frame,
    the LED sends zeroes on its data-out line. Because a color frame is
    32 bits, the LED sends 32 bits of zeroes to the next LED.
    As we have seen above, this means that the next LED is now ready
    to accept a color frame and update its color.
    So that's really the entire protocol:
    - Start by sending 32 bits of zeroes. This prepares LED 1 to update
      its color.
    - Send color information one by one, starting with the color for LED 1,
      then LED 2 etc.
    - Finish off by cycling the clock line a few times to get all data
      to the very last LED on the strip
    The last step is necessary, because each LED delays forwarding the data
    a bit. Imagine ten people in a row. When you yell the last color
    information, i.e. the one for person ten, to the first person in
    the line, then you are not finished yet. Person one has to turn around
    and yell it to person 2, and so on. So it takes ten additional "dummy"
    cycles until person ten knows the color. When you look closer,
    you will see that not even person 9 knows its own color yet. This
    information is still with person 2. Essentially the driver sends additional
    zeroes to LED 1 as long as it takes for the last color frame to make it
    down the line to the last LED.
    """
  require Logger

  use GenServer

  alias ElixirALE
  alias Colorwall.RGBI

  @max_speed_hz 8000000
  @led_start = 0b11100000 # Three "1" bits, followed by 5 brightness bits
  @max_brightness 0b11111 # Brightness is represented in 5 bits
  # TODO: Support different color order (RGB, BRG)
  # TODO: Support bitbanging?

  def start_link(type \\ Colorwall.SPIDummy, length, max_brightness, opts \\ []) do
    """ length is the number of LEDs in the string
    """
    opts = Keyword.merge(opts, name: __MODULE__)
    GenServer.start_link(__MODULE__, [type, length, max_brightness], opts)
  end

  def server do
    Process.whereis(__MODULE__) ||
      raise "could not find process #{__MODULE__}. Have you started the application?"
  end

  def init([type, length, max_brightness]) do
    Logger.info "Starting LED String"

    # Limit the brightness to the maximum if it's set higher
    max_brightness = if max_brightness > @max_brightness do
      Logger.warn "Maximum brightness too high, capping at #{@max_brightness}"
      @max_brightness
    else
      max_brightness
    end

    leds = Enum.map 1..length, fn(_) do
      %RGBI{}
    end |> List.to_tuple

    {:ok, pid} = type.start_link("spidev0.0")

    {:ok, %{type: type, max_brightness: max_brightness, leds: leds, spi_pid: pid}}
  end

  def handle_call({:set_pixel, [index, rgbi = %RGBI{}], _from, state = %{leds: leds}) do
    """Sets the color of one pixel in the LED string.
    The changed pixel is not shown yet on the string, it is only
    written to the pixel buffer. Colors are passed individually.
    If brightness is not set the global brightness setting is used.
    """
    leds = put_elem(leds, index, rgbi)

    {:reply, :ok, Map.put(state, :leds, leds)}
  end

  def clock_start_frame() do
    """Sends a start frame to the LED strip.
    This method clocks out a start frame, telling the receiving LED
    that it must update its own color now.
    """
    self.spi.write(<<0,0,0,0>>)  # Start frame, 32 zero bits
  end


  def clock_end_frame(leds) do
    """Sends an end frame to the LED strip.
    As explained above, dummy data must be sent after the last real colour
    information so that all of the data can reach its destination down the line.
    The delay is not as bad as with the human example above.
    It is only 1/2 bit per LED. This is because the SPI clock line
    needs to be inverted.
    Say a bit is ready on the SPI data line. The sender communicates
    this by toggling the clock line. The bit is read by the LED
    and immediately forwarded to the output data line. When the clock goes
    down again on the input side, the LED will toggle the clock up
    on the output to tell the next LED that the bit is ready.
    After one LED the clock is inverted, and after two LEDs it is in sync
    again, but one cycle behind. Therefore, for every two LEDs, one bit
    of delay gets accumulated. For 300 LEDs, 150 additional bits must be fed to
    the input of LED one so that the data can reach the last LED.
    Ultimately, we need to send additional numLEDs/2 arbitrary data bits,
    in order to trigger numLEDs/2 additional clock changes. This driver
    sends zeroes, which has the benefit of getting LED one partially or
    fully ready for the next update to the strip. An optimized version
    of the driver could omit the "clockStartFrame" method if enough zeroes have
    been sent as part of "clockEndFrame".
    """
    # Round up num_led/2 bits (or num_led/16 bytes)
    count = tuple_size(leds) + 15 |> Integer.floor_div(16)
    Enum.each(0..count, fn(_) do
      self.spi.write(<<0>>)
    end
  end
end
