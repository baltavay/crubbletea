require "../../src/crubbletea"

EYE_WIDTH   = 15
EYE_HEIGHT  = 12
EYE_SPACING = 40
BLINK_FRAMES = 20
OPEN_TIME_MIN = 1000
OPEN_TIME_MAX = 4000

EYE_CHAR = "●"
BG_CHAR  = " "

struct TickMsg
  include Crubbletea::Msg
end

class EyesModel
  include Crubbletea::Model

  getter width : Int32
  getter height : Int32
  getter eye_positions : Array(Int32)
  getter eye_y : Int32
  getter is_blinking : Bool
  getter blink_state : Int32
  getter last_blink : Time
  getter open_time : Time::Span

  def initialize
    @width = 80
    @height = 24
    @is_blinking = false
    @blink_state = 0
    @last_blink = Time.utc
    @open_time = (Random.new.next_int.abs % (OPEN_TIME_MAX - OPEN_TIME_MIN) + OPEN_TIME_MIN).milliseconds
    @eye_positions = [0, 0]
    @eye_y = 0
    update_eye_positions
  end

  def init : Crubbletea::Cmd?
    Crubbletea.tick(50.milliseconds) { |t| TickMsg.new.as(Crubbletea::Msg) }
  end

  def update(msg) : {EyesModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "q", "escape"
        return {self, Crubbletea.quit}
      end
    when Crubbletea::WindowSizeMsg
      @width = msg.width
      @height = msg.height
      update_eye_positions
    when TickMsg
      current_time = Time.utc

      if !@is_blinking && (current_time - @last_blink) >= @open_time
        @is_blinking = true
        @blink_state = 0
      end

      if @is_blinking
        @blink_state += 1

        if @blink_state >= BLINK_FRAMES
          @is_blinking = false
          @last_blink = current_time
          @open_time = (Random.new.next_int.abs % (OPEN_TIME_MAX - OPEN_TIME_MIN) + OPEN_TIME_MIN).milliseconds

          if Random.new.next_int.abs % 10 == 0
            @open_time = 300.milliseconds
          end
        end
      end
    end

    {self, Crubbletea.tick(50.milliseconds) { |t| TickMsg.new.as(Crubbletea::Msg) }}
  end

  def view : Crubbletea::View
    canvas = Array(Array(String)).new(@height) { Array(String).new(@width) { BG_CHAR } }

    current_height = EYE_HEIGHT
    if @is_blinking
      half = BLINK_FRAMES // 2
      blink_progress : Float64
      if @blink_state < half
        bp = @blink_state.to_f / half.to_f
        blink_progress = 1.0 - (bp * bp)
      else
        bp = (@blink_state - half).to_f / half.to_f
        blink_progress = bp * (2.0 - bp)
      end
      current_height = {1, (EYE_HEIGHT.to_f * blink_progress).to_i}.max
    end

    2.times do |i|
      draw_ellipse(canvas, @eye_positions[i], @eye_y, EYE_WIDTH, current_height)
    end

    s = String::Builder.new
    style = Crubbletea::Lipgloss::Style.new.foreground("#F0F0F0")
    help_style = Crubbletea::Lipgloss::Style.new.foreground("#888888")

    (@height - 1).times do |y|
      canvas[y].each { |cell| s << cell }
      s << '\n'
    end
    s << help_style.render("q: exit")

    v = Crubbletea.new_view(style.render(s.to_s))
    v.alt_screen = true
    v
  end

  private def update_eye_positions : Nil
    start_x = (@width - EYE_SPACING) // 2
    @eye_y = @height // 2
    @eye_positions = [start_x, start_x + EYE_SPACING]
  end

  private def draw_ellipse(canvas : Array(Array(String)), x0 : Int32, y0 : Int32, rx : Int32, ry : Int32) : Nil
    (-ry..ry).each do |y|
      ratio = (y.to_f / ry.to_f)
      width = (rx.to_f * Math.sqrt(1.0 - ratio * ratio)).to_i
      (-width..width).each do |x|
        cx = x0 + x
        cy = y0 + y
        if cx >= 0 && cx < canvas[0].size && cy >= 0 && cy < canvas.size
          canvas[cy][cx] = EYE_CHAR
        end
      end
    end
  end
end

program = Crubbletea::Program(EyesModel).new(EyesModel.new)
program.run
