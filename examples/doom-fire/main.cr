require "../../src/crubbletea"

WHITE_FG = Crubbletea::Lipgloss::Style.new.foreground("#ffffff")

PALETTE = [0, 233, 234, 52, 53, 88, 89, 94, 95, 96, 130, 131, 132, 133, 172, 214, 215, 220, 220, 221, 3, 226, 227, 230, 231, 7]

struct TickMsg
  include Crubbletea::Msg
end

class DoomFireModel
  include Crubbletea::Model

  getter screen_buf : Array(Int32)
  getter width : Int32
  getter height : Int32
  getter start_time : Time

  def initialize
    @screen_buf = [] of Int32
    @width = 0
    @height = 0
    @start_time = Time.utc
  end

  def init : Crubbletea::Cmd?
    ->{
      sleep 50.milliseconds
      TickMsg.new.as(Crubbletea::Msg)
    }
  end

  def update(msg) : {DoomFireModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "q", "ctrl+c"
        return {self, Crubbletea.quit}
      end
    when TickMsg
      spread_fire
      return {self, ->{
        sleep 50.milliseconds
        TickMsg.new.as(Crubbletea::Msg)
      }}
    when Crubbletea::WindowSizeMsg
      @width = msg.width
      @height = msg.height * 2
      @screen_buf = Array(Int32).new(@width * @height, 0)
      @width.times do |x|
        @screen_buf[(@height - 1) * @width + x] = PALETTE.size - 1
      end
    end
    {self, nil}
  end

  def view : Crubbletea::View
    if @width == 0
      return Crubbletea.new_view("Initializing...")
    end

    s = String::Builder.new
    y = 0
    while y < @height - 2
      @width.times do |x|
        pixel_hi = @screen_buf[y * @width + x]
        pixel_lo = @screen_buf[(y + 1) * @width + x]
        hi_color = PALETTE[pixel_hi]
        lo_color = PALETTE[pixel_lo]
        s << "\e[38;5;#{hi_color}m\e[48;5;#{lo_color}m▀"
      end
      s << "\e[0m\n" if y < @height - 2
      y += 2
    end

    elapsed = (Time.utc - @start_time).total_seconds.round.to_i
    s << WHITE_FG.render("Press q or ctrl+c to quit. Elapsed: #{elapsed}s")

    v = Crubbletea.new_view(s.to_s)
    v.alt_screen = true
    v
  end

  private def spread_fire : Nil
    return if @width == 0 || @height == 0
    @width.times do |x|
      @height.times do |y|
        spread_pixel(y * @width + x)
      end
    end
  end

  private def spread_pixel(idx : Int32) : Nil
    return if idx < @width
    pixel = @screen_buf[idx]
    if pixel == 0
      @screen_buf[idx - @width] = 0
      return
    end

    rnd = Random.new.next_int.abs % 3
    dst = idx - rnd + 1
    if dst - @width >= 0 && dst - @width < @screen_buf.size
      decay = rnd & 1
      new_value = {pixel - decay, 0}.max
      @screen_buf[dst - @width] = new_value
    end
  end
end

program = Crubbletea::Program(DoomFireModel).new(DoomFireModel.new)
program.run
