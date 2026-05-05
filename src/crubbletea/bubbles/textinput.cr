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
  getter suggestions : Array(String)
  getter show_suggestions : Bool

  @@last_id = 0

  @value : String
  @cursor_pos : Int32
  @focus : Bool
  @err : Exception?
  @offset : Int32
  @offset_right : Int32
  @selected_suggestion : Int32

  def initialize(
    @prompt : String = "> ",
    @placeholder : String = "",
    @width : Int32 = 20,
    @char_limit : Int32 = 0,
    @echo_mode : Symbol = :normal,
    @style : Lipgloss::Style = Lipgloss::Style.new,
    @prompt_style : Lipgloss::Style = Lipgloss::Style.new,
    @placeholder_style : Lipgloss::Style = Lipgloss::Style.new,
    @cursor : Cursor::Model = Cursor::Model.new,
    @suggestions : Array(String) = [] of String,
    @show_suggestions : Bool = false
  )
    @@last_id += 1
    @id = @@last_id
    @value = ""
    @cursor_pos = 0
    @focus = false
    @offset = 0
    @offset_right = 0
    @selected_suggestion = -1
  end

  def value : String
    @value
  end

  def value=(v : String) : Nil
    @value = v
    @cursor_pos = v.size
    handle_overflow
  end

  def cursor_pos : Int32
    @cursor_pos
  end

  def visible_cursor_pos : Int32
    prompt_w = Lipgloss::ANSI.string_width(@prompt_style.render(@prompt))
    prompt_w + {@cursor_pos - @offset, 0}.max
  end

  def cursor_pos=(pos : Int32) : Nil
    @cursor_pos = {0, {pos, @value.size}.min}.max
  end

  def width=(w : Int32) : Nil
    @width = w
  end

  def cursor_end : Nil
    @cursor_pos = @value.size
    handle_overflow
  end

  def cursor_start : Nil
    @cursor_pos = 0
    handle_overflow
  end

  def show_suggestions=(v : Bool) : Nil
    @show_suggestions = v
  end

  def set_suggestions(suggestions : Array(String)) : Nil
    @suggestions = suggestions
  end

  def matched_suggestions : Array(String)
    return @suggestions if @value.empty?
    @suggestions.select { |s| s.downcase.starts_with?(@value.downcase) }
  end

  def next_suggestion : Nil
    matched = matched_suggestions
    return if matched.empty?
    @selected_suggestion = (@selected_suggestion + 1) % matched.size
  end

  def prev_suggestion : Nil
    matched = matched_suggestions
    return if matched.empty?
    @selected_suggestion = (@selected_suggestion - 1) % matched.size
  end

  def apply_suggestion : Nil
    matched = matched_suggestions
    return if matched.empty? || @selected_suggestion < 0 || @selected_suggestion >= matched.size
    self.value = matched[@selected_suggestion]
    @selected_suggestion = -1
  end

  private def current_completion : String
    return "" unless @show_suggestions
    return "" if @value.empty?
    matched = matched_suggestions
    return "" if matched.empty?
    idx = @selected_suggestion >= 0 ? @selected_suggestion : 0
    return "" if idx >= matched.size
    suggestion = matched[idx]
    return "" unless suggestion.size > @value.size
    return "" unless suggestion.downcase.starts_with?(@value.downcase)
    suggestion[@value.size..]
  end

  def suggestions_view : String
    matched = matched_suggestions
    return "" if matched.empty? || !@show_suggestions
    selected = {@selected_suggestion, 0}.max
    matched.first(10).map_with_index do |s, i|
      if i == selected
        Crubbletea::Lipgloss::Style.new.background("#585858").render(s)
      else
        s
      end
    end.join("\n")
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
    return if @cursor_pos <= 0 || @value.empty?
    @value = @value[0...(@cursor_pos - 1)] + @value[@cursor_pos..]
    @cursor_pos -= 1 if @cursor_pos > 0
  end

  def delete_char_forward : Nil
    return if @cursor_pos >= @value.size || @value.empty?
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

  def delete_word_backward : Nil
    return if @cursor_pos <= 0
    old_pos = @cursor_pos
    word_left
    @value = @value[0...@cursor_pos] + @value[old_pos..]
  end

  def delete_word_forward : Nil
    return if @cursor_pos >= @value.size
    old_pos = @cursor_pos
    word_right
    @value = @value[0...old_pos] + @value[@cursor_pos..]
    @cursor_pos = old_pos
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
      when key.to_s == "left", key.ctrl && key.text == "b"
        if key.alt
          word_left
        else
          move_left
        end
      when key.to_s == "right", key.ctrl && key.text == "f"
        if key.alt
          word_right
        else
          move_right
        end
      when key.to_s == "home", key.ctrl && key.text == "a"
        move_to_start
      when key.to_s == "end", key.ctrl && key.text == "e"
        move_to_end
      when key.to_s == "backspace", key.ctrl && key.text == "h"
        delete_char_backward
      when key.to_s == "delete", key.ctrl && key.text == "d"
        delete_char_forward
      when key.alt && key.to_s == "backspace"
        delete_word_backward
      when key.alt && (key.text == "d" || key.to_s == "delete")
        delete_word_forward
      when key.ctrl && key.text == "u"
        @value = @value[@cursor_pos..]
        @cursor_pos = 0
      when key.ctrl && key.text == "k"
        @value = @value[0...@cursor_pos]
      when key.ctrl && key.text == "w"
        delete_word_backward
      when @show_suggestions && key.to_s == "tab"
        completion = current_completion
        if !completion.empty?
          @value += completion
          @cursor_pos = @value.size
        end
      when @show_suggestions && key.to_s == "down"
        next_suggestion
      when @show_suggestions && key.to_s == "up"
        prev_suggestion
      when !key.text.empty? && !key.ctrl && !key.alt
        key.text.each_char { |c| insert_char(c) }
        @selected_suggestion = -1
      end
    end
    handle_overflow
    {self, nil}
  end

  def view : String
    prompt_view = @prompt_style.render(@prompt)
    prompt_w = Lipgloss::ANSI.string_width(prompt_view)
    avail = {@width - prompt_w, 1}.max

    if @value.empty?
      visible = placeholder_display
      if Lipgloss::ANSI.string_width(visible) > avail
        visible = Lipgloss::ANSI.truncate(visible, avail)
      end
      value_view = @placeholder_style.render(visible)
      rendered_w = Lipgloss::ANSI.string_width(value_view)
      pad = {avail - rendered_w, 0}.max
      prompt_view + value_view + (" " * pad)
    else
      dv = display_value
      or_ = {@offset_right, dv.size}.min
      visible = dv[@offset...or_]
      value_view = @style.render(visible)

      completion = current_completion
      completion_view = ""
      unless completion.empty?
        completion_view = Lipgloss::Style.new.foreground("240").inline(true).render(completion)
      end

      val_w = Lipgloss::ANSI.string_width(visible) + Lipgloss::ANSI.string_width(completion)
      if val_w < avail
        pad = avail - val_w
        value_view = value_view + completion_view + (" " * pad)
      else
        value_view = value_view + completion_view
      end
      prompt_view + value_view
    end
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

  private def handle_overflow : Nil
    prompt_w = Lipgloss::ANSI.string_width(@prompt_style.render(@prompt))
    avail = {@width - prompt_w, 1}.max

    if avail <= 0 || Lipgloss::ANSI.string_width(@value) <= avail
      @offset = 0
      @offset_right = @value.size
      return
    end

    @offset_right = {@offset_right, @value.size}.min

    if @cursor_pos < @offset
      @offset = @cursor_pos
      w = 0
      count = 0
      i = @offset
      while i < @value.size && w < avail
        cw = Lipgloss::ANSI.char_width(@value[i])
        w += cw
        if w <= avail
          count += 1
          i += 1
        else
          break
        end
      end
      @offset_right = @offset + count
    elsif @cursor_pos >= @offset_right
      @offset_right = {@cursor_pos, @value.size}.min
      w = 0
      i = @offset_right - 1
      while i > 0 && w < avail
        w += Lipgloss::ANSI.char_width(@value[i])
        if w <= avail
          i -= 1
        else
          break
        end
      end
      @offset = i + 1
    end
  end
end
