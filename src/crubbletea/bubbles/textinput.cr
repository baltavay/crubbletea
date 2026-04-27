require "../lipgloss"
require "./cursor"

struct Crubbletea::Bubbles::TextInput::FocusMsg
  include Crubbletea::Msg
end

class Crubbletea::Bubbles::TextInput::Model
  getter prompt : String
  getter placeholder : String
  getter width : Int32
  getter char_limit : Int32
  getter echo_mode : Symbol
  getter style : Lipgloss::Style
  getter prompt_style : Lipgloss::Style
  getter placeholder_style : Lipgloss::Style
  getter cursor : Cursor::Model
  getter id : Int32

  @@last_id = 0

  @value : String
  @cursor_pos : Int32
  @focus : Bool
  @err : Exception?

  def initialize(
    @prompt : String = "> ",
    @placeholder : String = "",
    @width : Int32 = 20,
    @char_limit : Int32 = 0,
    @echo_mode : Symbol = :normal,
    @style : Lipgloss::Style = Lipgloss::Style.new,
    @prompt_style : Lipgloss::Style = Lipgloss::Style.new,
    @placeholder_style : Lipgloss::Style = Lipgloss::Style.new,
    @cursor : Cursor::Model = Cursor::Model.new
  )
    @@last_id += 1
    @id = @@last_id
    @value = ""
    @cursor_pos = 0
    @focus = false
  end

  def value : String
    @value
  end

  def value=(v : String) : Nil
    @value = v
    @cursor_pos = v.size
  end

  def cursor_pos : Int32
    @cursor_pos
  end

  def cursor_pos=(pos : Int32) : Nil
    @cursor_pos = {0, {pos, @value.size}.min}.max
  end

  def focused? : Bool
    @focus
  end

  def focus : Nil
    @focus = true
    @cursor.focus
  end

  def blur : Nil
    @focus = false
    @cursor.blur
  end

  def err : Exception?
    @err
  end

  def insert_char(c : Char) : Nil
    return if @char_limit > 0 && @value.size >= @char_limit
    @value = @value.insert(@cursor_pos, c)
    @cursor_pos += 1
  end

  def delete_char_backward : Nil
    return if @cursor_pos <= 0
    @value = @value[0...(@cursor_pos - 1)] + @value[@cursor_pos..]
    @cursor_pos -= 1
  end

  def delete_char_forward : Nil
    return if @cursor_pos >= @value.size
    @value = @value[0...@cursor_pos] + @value[(@cursor_pos + 1)..]
  end

  def move_left : Nil
    @cursor_pos -= 1 if @cursor_pos > 0
  end

  def move_right : Nil
    @cursor_pos += 1 if @cursor_pos < @value.size
  end

  def move_to_start : Nil
    @cursor_pos = 0
  end

  def move_to_end : Nil
    @cursor_pos = @value.size
  end

  def word_left : Nil
    return if @cursor_pos <= 0
    pos = @cursor_pos - 1
    while pos > 0 && @value[pos].whitespace?
      pos -= 1
    end
    while pos > 0 && !@value[pos - 1].whitespace?
      pos -= 1
    end
    @cursor_pos = pos
  end

  def word_right : Nil
    return if @cursor_pos >= @value.size
    pos = @cursor_pos
    while pos < @value.size && !@value[pos].whitespace?
      pos += 1
    end
    while pos < @value.size && @value[pos].whitespace?
      pos += 1
    end
    @cursor_pos = pos
  end

  def update(msg : Crubbletea::Msg) : {Model, Crubbletea::Cmd}
    case msg
    when Crubbletea::FocusMsg
      focus
    when Crubbletea::BlurMsg
      blur
    when Crubbletea::KeyPressMsg
      return {self, nil} unless @focus

      key = msg.key
      case
      when key.to_s == "left"
        if key.alt
          word_left
        else
          move_left
        end
      when key.to_s == "right"
        if key.alt
          word_right
        else
          move_right
        end
      when key.to_s == "home", key.ctrl && key.to_s == "a"
        move_to_start
      when key.to_s == "end", key.ctrl && key.to_s == "e"
        move_to_end
      when key.to_s == "backspace"
        delete_char_backward
      when key.to_s == "delete", key.ctrl && key.to_s == "d"
        delete_char_forward
      when key.to_s == "ctrl+u"
        @value = @value[@cursor_pos..]
        @cursor_pos = 0
      when key.to_s == "ctrl+k"
        @value = @value[0...@cursor_pos]
      when key.to_s == "ctrl+w"
        word_left
        @value = @value[0...@cursor_pos] + @value[(@cursor_pos + 1)..]
      when !key.text.empty? && !key.ctrl && !key.alt
        key.text.each_char { |c| insert_char(c) }
      end
    end
    {self, nil}
  end

  def view : String
    prompt_view = @prompt_style.render(@prompt)

    if @value.empty?
      value_view = @placeholder_style.render(placeholder_display)
    else
      value_view = @style.render(display_value)
    end

    prompt_view + value_view
  end

  def error_view : String
    prompt_view = @prompt_style.render(@prompt)
    prompt_view + (@err.try(&.message) || "")
  end

  private def display_value : String
    case @echo_mode
    when :password
      "*" * @value.size
    when :none
      ""
    else
      @value
    end
  end

  private def placeholder_display : String
    case @echo_mode
    when :password
      "*" * @placeholder.size
    when :none
      ""
    else
      @placeholder
    end
  end
end
