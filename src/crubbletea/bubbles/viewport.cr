require "../lipgloss"

class Crubbletea::Bubbles::Viewport::Model
  getter width : Int32
  getter height : Int32
  getter style : Lipgloss::Style
  getter y_offset : Int32
  getter x_offset : Int32
  getter y_cursor_offset : Int32
  getter highlight : Bool
  getter highlight_style : Lipgloss::Style
  getter gutter : Bool
  getter soft_wrap : Bool

  @content : String
  @lines : Array(String)
  @total_lines : Int32

  def initialize(
    @width : Int32 = 80,
    @height : Int32 = 24,
    @style : Lipgloss::Style = Lipgloss::Style.new,
    @highlight : Bool = false,
    @highlight_style : Lipgloss::Style = Lipgloss::Style.new.reverse(true),
    @gutter : Bool = false,
    @soft_wrap : Bool = true
  )
    @content = ""
    @lines = [] of String
    @total_lines = 0
    @y_offset = 0
    @x_offset = 0
    @y_cursor_offset = 0
  end

  def content : String
    @content
  end

  def content=(s : String) : Nil
    @content = s
    rebuild_lines
  end

  def width=(w : Int32) : Nil
    @width = w
    rebuild_lines if @soft_wrap
  end

  def height=(h : Int32) : Nil
    @height = h
  end

  def goto_bottom : Nil
    @y_offset = max_y_offset
  end

  def total_lines : Int32
    @total_lines
  end

  def at_top? : Bool
    @y_offset <= 0
  end

  def at_bottom? : Bool
    @y_offset >= max_y_offset
  end

  def max_y_offset : Int32
    {0, @total_lines - @height}.max
  end

  def line(i : Int32) : String
    @lines[i]? || ""
  end

  def set_size(w : Int32, h : Int32) : Nil
    @width = w
    @height = h
    rebuild_lines if @soft_wrap
  end

  def set_y_offset(n : Int32) : Nil
    @y_offset = {0, {n, max_y_offset}.min}.max
  end

  def set_x_offset(n : Int32) : Nil
    @x_offset = {0, n}.max
  end

  def view_up(n : Int32 = 1) : Nil
    @y_offset -= n
    @y_offset = 0 if @y_offset < 0
  end

  def view_down(n : Int32 = 1) : Nil
    @y_offset += n
    @y_offset = max_y_offset if @y_offset > max_y_offset
  end

  def update(msg : Crubbletea::Msg) : {Model, Crubbletea::Cmd}
    case msg
    when Crubbletea::KeyPressMsg
      key = msg.key
      case key.to_s
      when "up", "k"
        view_up
      when "down", "j"
        view_down
      when "pgup"
        view_up(@height)
      when "pgdown"
        view_down(@height)
      when "home", "g"
        set_y_offset(0)
      when "end", "G"
        set_y_offset(max_y_offset)
      end
    when Crubbletea::MouseWheelMsg
      if msg.mouse.button.wheel_up?
        view_up(3)
      elsif msg.mouse.button.wheel_down?
        view_down(3)
      end
    end
    {self, nil}
  end

  def view : String
    visible = [] of String

    @height.times do |i|
      idx = @y_offset + i
      if idx < @total_lines
        line = @lines[idx]
        lw = Lipgloss::ANSI.string_width(line)

        if @soft_wrap && @width > 0
          line = Lipgloss::ANSI.wrap(line, @width)
        end

        if lw > @width && @width > 0
          line = Lipgloss::ANSI.truncate(line, @width)
        elsif lw < @width
          line = line + " " * (@width - lw)
        end

        if @highlight && idx == @y_cursor_offset
          line = @highlight_style.render(line)
        end

        visible << line
      else
        visible << " " * {@width, 1}.max
      end
    end

    visible.join('\n')
  end

  def over?(y : Int32) : Bool
    y >= @total_lines
  end

  def past_bottom?(y : Int32) : Bool
    y > @y_offset + @height
  end

  private def rebuild_lines : Nil
    if @soft_wrap && @width > 0
      @lines = [] of String
      @content.split('\n').each do |line|
        if Lipgloss::ANSI.string_width(line) > @width
          wrapped = Lipgloss::ANSI.wrap(line, @width)
          wrapped.split('\n').each { |wl| @lines << wl }
        else
          @lines << line
        end
      end
    else
      @lines = @content.split('\n')
    end
    @total_lines = @lines.size
  end
end
