require "../../src/crubbletea"

SPACE_FG = "\e[38;2;"
SPACE_BG = "\e[48;2;"

struct TickMsg
  include Crubbletea::Msg
end

class SpaceModel
  include Crubbletea::Model

  getter grays : Array(Array(Int32))
  getter last_width : Int32
  getter last_height : Int32
  getter frame_count : Int32
  getter width : Int32
  getter height : Int32

  def initialize
    @grays = [] of Array(Int32)
    @last_width = 0
    @last_height = 0
    @frame_count = 0
    @width = 0
    @height = 0
  end

  def init : Crubbletea::Cmd?
    Crubbletea.tick(16.milliseconds) { TickMsg.new.as(Crubbletea::Msg) }
  end

  def update(msg) : {SpaceModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "q", "ctrl+c"
        return {self, Crubbletea.quit}
      end
    when Crubbletea::WindowSizeMsg
      @width = msg.width
      @height = msg.height
      if @width != @last_width || @height != @last_height
        setup_grays
        @last_width = @width
        @last_height = @height
      end
    when TickMsg
      @frame_count += 1
      return {self, Crubbletea.tick(16.milliseconds) { TickMsg.new.as(Crubbletea::Msg) }}
    end
    {self, nil}
  end

  def view : Crubbletea::View
    return Crubbletea.new_view("Waiting for window size...") if @width == 0

    title = Crubbletea::Lipgloss::Style.new.bold(true).render("Space")

    s = String::Builder.new(@width * (@height - 1) * 2)
    display_height = @height - 1
    display_height.times do |y|
      @width.times do |x|
        xi = (x + @frame_count) % @width
        g1 = @grays[y * 2]?.try(&.[xi]?) || 0
        g2 = @grays[y * 2 + 1]?.try(&.[xi]?) || 0
        s << SPACE_FG << g1 << ';' << g1 << ';' << g1 << 'm'
        s << SPACE_BG << g2 << ';' << g2 << ';' << g2 << 'm' << '▀'
      end
      s << "\e[0m\n" if y < display_height - 1
    end
    s << "\e[0m"

    v = Crubbletea.new_view("#{title}\n#{s.to_s}")
    v.alt_screen = true
    v
  end

  private def setup_grays : Nil
    h = @height * 2
    rng = Random.new
    @grays = Array(Array(Int32)).new(h) do |y|
      Array(Int32).new(@width) do
        factor = (h - y).to_f / h.to_f
        base = factor * factor
        offset = rng.next_float * 0.2 - 0.1
        value = base + offset
        value = 0.0 if value < 0.0
        value = 1.0 if value > 1.0
        gray = (value * 255).to_i
        {gray, 0}.max
      end
    end
  end
end

program = Crubbletea::Program(SpaceModel).new(SpaceModel.new)
program.run
