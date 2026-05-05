require "../../src/crubbletea"

COLORS = [
  "#881177", "#aa3355", "#cc6666", "#ee9944",
  "#eedd00", "#99dd55", "#44dd88", "#22ccbb",
  "#00bbcc", "#0099cc", "#3366bb", "#663399",
]

PARSED_COLORS = COLORS.map do |c|
  h = c.lchop('#')
  {h[0..1].to_i(16), h[2..3].to_i(16), h[4..5].to_i(16)}
end

SPLASH_FG = "\e[38;2;"
SPLASH_BG = "\e[48;2;"

struct TickMsg
  include Crubbletea::Msg
end

class SplashModel
  include Crubbletea::Model

  getter width : Int32
  getter height : Int32
  @rate : Int64

  def initialize
    @width = 0
    @height = 0
    @rate = 90_i64
  end

  def init : Crubbletea::Cmd?
    Crubbletea.tick(16.milliseconds) { TickMsg.new.as(Crubbletea::Msg) }
  end

  def update(msg) : {SplashModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      return {self, Crubbletea.quit}
    when Crubbletea::WindowSizeMsg
      @width = msg.width
      @height = msg.height
    when TickMsg
      return {self, Crubbletea.tick(16.milliseconds) { TickMsg.new.as(Crubbletea::Msg) }}
    end
    {self, nil}
  end

  def view : Crubbletea::View
    v = Crubbletea.new_view(@width == 0 ? "Initializing..." : gradient)
    v.alt_screen = true
    v
  end

  private def gradient : String
    t = Time.utc.to_unix_ns * @rate / 1_000_000_000.0
    angle = -t * Math::PI / 180.0
    sin_a = Math.sin(angle)
    cos_a = Math.cos(angle)
    center_x = @width.to_f / 2.0
    center_y = @height.to_f

    s = String::Builder.new(@width * @height * 2)
    @height.times do |line_y|
      point_y = line_y.to_f * 2 - center_y
      point_x = 0.0 - center_x

      x1 = (center_x + (point_x * cos_a - point_y * sin_a)) / @width.to_f
      x2 = (center_x + (point_x * cos_a - (point_y + 1.0) * sin_a)) / @width.to_f
      point_x = @width.to_f - center_x
      end_x1 = (center_x + (point_x * cos_a - point_y * sin_a)) / @width.to_f
      delta_x = (end_x1 - x1) / @width.to_f

      @width.times do |x|
        p1 = x1 + x.to_f * delta_x
        p2 = x2 + x.to_f * delta_x
        r1, g1, b1 = gradient_rgb(p1)
        r2, g2, b2 = gradient_rgb(p2)
        s << SPLASH_FG << r1 << ';' << g1 << ';' << b1 << 'm'
        s << SPLASH_BG << r2 << ';' << g2 << ';' << b2 << 'm' << '▀'
      end
      s << "\e[0m\n" if line_y < @height - 1
    end
    s << "\e[0m"
    s.to_s
  end

  private def gradient_rgb(pos : Float64) : {Int32, Int32, Int32}
    pos = 0.0 if pos <= 0
    pos = 1.0 if pos >= 1

    idx = pos * (COLORS.size - 1)
    i1 = idx.floor.to_i % COLORS.size
    i2 = idx.ceil.to_i % COLORS.size
    t = idx - idx.floor

    r1, g1, b1 = PARSED_COLORS[i1]
    r2, g2, b2 = PARSED_COLORS[i2]
    {
      (r1 * (1 - t) + r2 * t).to_i,
      (g1 * (1 - t) + g2 * t).to_i,
      (b1 * (1 - t) + b2 * t).to_i,
    }
  end
end

program = Crubbletea::Program(SplashModel).new(SplashModel.new)
program.run
