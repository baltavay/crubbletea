require "../lipgloss"

class Crubbletea::Bubbles::Cursor::Model
  enum Mode
    Blink
    Static
    Hide
  end

  getter style : Lipgloss::Style
  getter text_style : Lipgloss::Style
  getter blink_speed : Time::Span
  getter is_blinked : Bool
  getter id : Int32
  getter mode : Mode

  @@last_id = 0

  @focus : Bool
  @blink_tag : Int32

  def initialize(
    @style : Lipgloss::Style = Lipgloss::Style.new,
    @text_style : Lipgloss::Style = Lipgloss::Style.new,
    @blink_speed : Time::Span = 530.milliseconds,
    @mode : Mode = Mode::Blink
  )
    @@last_id += 1
    @id = @@last_id
    @focus = false
    @is_blinked = true
    @blink_tag = 0
  end

  def focused? : Bool
    @focus
  end

  def focus : Crubbletea::Cmd
    @focus = true
    @is_blinked = @mode == Mode::Hide
    nil
  end

  def blur : Nil
    @focus = false
    @is_blinked = true
  end

  def set_mode(m : Mode) : Nil
    @mode = m
    @is_blinked = @mode == Mode::Hide || !@focus
  end

  def update(msg : Crubbletea::Msg) : {Model, Crubbletea::Cmd}
    case msg
    when Crubbletea::FocusMsg
      @focus = true
      @is_blinked = @mode == Mode::Hide
      {self, nil}
    when Crubbletea::BlurMsg
      @focus = false
      @is_blinked = true
      {self, nil}
    else
      {self, nil}
    end
  end

  def view(char : String = " ") : String
    if @is_blinked
      @text_style.inline(true).render(char)
    else
      @style.inline(true).reverse(true).render(char)
    end
  end
end
