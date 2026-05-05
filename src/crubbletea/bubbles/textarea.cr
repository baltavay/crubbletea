require "../lipgloss"
require "./cursor"

class Crubbletea::Bubbles::TextArea::Model
  getter placeholder : String
  getter style : Lipgloss::Style
  getter prompt : String
  getter width : Int32
  getter height : Int32
  getter char_limit : Int32
  getter cursor : Cursor::Model
  getter id : Int32
  getter show_line_numbers : Bool
  getter line_number_style : Lipgloss::Style
  getter placeholder_style : Lipgloss::Style

  @@last_id = 0

  @lines : Array(String)
  @cursor_row : Int32
  @cursor_col : Int32
  @focus : Bool
  @err : Exception?
  @viewport_y : Int32
  @viewport_x : Int32

  def initialize(
    @placeholder : String = "",
    @style : Lipgloss::Style = Lipgloss::Style.new,
    @prompt : String = "",
    @width : Int32 = 40,
    @height : Int32 = 6,
    @char_limit : Int32 = 0,
    @cursor : Cursor::Model = Cursor::Model.new,
    @show_line_numbers : Bool = false,
    @line_number_style : Lipgloss::Style = Lipgloss::Style.new,
    @placeholder_style : Lipgloss::Style = Lipgloss::Style.new.faint(true)
  )
    @@last_id += 1
    @id = @@last_id
    @lines = [""]
    @cursor_row = 0
    @cursor_col = 0
    @focus = false
    @viewport_y = 0
    @viewport_x = 0
  end

  def value : String
    @lines.join('\n')
  end

  def value=(v : String) : Nil
    @lines = v.split('\n')
    @lines = [""] if @lines.empty?
    @cursor_row = @lines.size - 1
    @cursor_col = @lines.last.size
    gutter_width = @show_line_numbers ? (@lines.size.to_s.size + 1) : 0
    content_width = {@width - gutter_width, 1}.max
    @viewport_x = {@cursor_col - content_width + 1, 0}.max
  end

  def line_count : Int32
    @lines.size
  end

  def line(row : Int32) : String
    @lines[row]? || ""
  end

  def line(row : Int32, v : String) : Nil
    return unless row >= 0 && row < @lines.size
    @lines[row] = v
  end

  def cursor_row : Int32
    @cursor_row
  end

  def cursor_col : Int32
    @cursor_col
  end

  def visible_cursor_col : Int32
    gutter_width = @show_line_numbers ? (@lines.size.to_s.size + 1) : 0
    Lipgloss::ANSI.string_width(@prompt) + gutter_width + @cursor_col - @viewport_x
  end

  def visible_cursor_row : Int32
    @cursor_row - @viewport_y
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

  def insert_char(c : Char) : Nil
    return if @char_limit > 0 && value.size >= @char_limit
    current = @lines[@cursor_row]
    @lines[@cursor_row] = current.insert(@cursor_col, c)
    @cursor_col += 1
    gutter_width = @show_line_numbers ? (@lines.size.to_s.size + 1) : 0
    content_width = {@width - gutter_width, 1}.max
    if @cursor_col >= @viewport_x + content_width
      @viewport_x = @cursor_col - content_width + 1
    end
  end

  def insert_newline : Nil
    current = @lines[@cursor_row]
    before = current[0...@cursor_col]
    after = current[@cursor_col..]
    @lines[@cursor_row] = before
    @lines.insert(@cursor_row + 1, after)
    @cursor_row += 1
    @cursor_col = 0
  end

  def delete_char_backward : Nil
    if @cursor_col > 0
      current = @lines[@cursor_row]
      @lines[@cursor_row] = current[0...(@cursor_col - 1)] + current[@cursor_col..]
      @cursor_col -= 1
      @viewport_x = {@viewport_x, @cursor_col}.min
    elsif @cursor_row > 0
      prev_line = @lines[@cursor_row - 1]
      @cursor_col = prev_line.size
      @lines[@cursor_row - 1] = prev_line + @lines[@cursor_row]
      @lines.delete_at(@cursor_row)
      @cursor_row -= 1
      @viewport_x = {@viewport_x, @cursor_col}.min
    end
  end

  def delete_char_forward : Nil
    current = @lines[@cursor_row]
    if @cursor_col < current.size
      @lines[@cursor_row] = current[0...@cursor_col] + current[(@cursor_col + 1)..]
    elsif @cursor_row < @lines.size - 1
      @lines[@cursor_row] = current + @lines[@cursor_row + 1]
      @lines.delete_at(@cursor_row + 1)
    end
  end

  def move_left : Nil
    if @cursor_col > 0
      @cursor_col -= 1
    elsif @cursor_row > 0
      @cursor_row -= 1
      @cursor_col = @lines[@cursor_row].size
    end
  end

  def move_right : Nil
    if @cursor_col < @lines[@cursor_row].size
      @cursor_col += 1
    elsif @cursor_row < @lines.size - 1
      @cursor_row += 1
      @cursor_col = 0
    end
  end

  def move_up : Nil
    if @cursor_row > 0
      @cursor_row -= 1
      @cursor_col = {@cursor_col, @lines[@cursor_row].size}.min
    end
  end

  def move_down : Nil
    if @cursor_row < @lines.size - 1
      @cursor_row += 1
      @cursor_col = {@cursor_col, @lines[@cursor_row].size}.min
    end
  end

  def move_to_start : Nil
    @cursor_col = 0
  end

  def move_to_end : Nil
    @cursor_col = @lines[@cursor_row].size
  end

  def page_up : Nil
    @cursor_row = {@cursor_row - @height, 0}.max
    @cursor_col = {@cursor_col, @lines[@cursor_row].size}.min
  end

  def page_down : Nil
    @cursor_row = {@cursor_row + @height, @lines.size - 1}.min
    @cursor_col = {@cursor_col, @lines[@cursor_row].size}.min
  end

  def word_left : Nil
    return if @cursor_col <= 0 && @cursor_row <= 0
    if @cursor_col > 0
      pos = @cursor_col - 1
      line = @lines[@cursor_row]
      while pos > 0 && line[pos].whitespace?
        pos -= 1
      end
      while pos > 0 && !line[pos - 1].whitespace?
        pos -= 1
      end
      @cursor_col = pos
    elsif @cursor_row > 0
      @cursor_row -= 1
      @cursor_col = @lines[@cursor_row].size
    end
  end

  def word_right : Nil
    line = @lines[@cursor_row]
    if @cursor_col < line.size
      pos = @cursor_col
      while pos < line.size && !line[pos].whitespace?
        pos += 1
      end
      while pos < line.size && line[pos].whitespace?
        pos += 1
      end
      @cursor_col = pos
    elsif @cursor_row < @lines.size - 1
      @cursor_row += 1
      @cursor_col = 0
    end
  end

  def delete_word_backward : Nil
    if @cursor_col > 0
      old_pos = @cursor_col
      word_left
      line = @lines[@cursor_row]
      @lines[@cursor_row] = line[0...@cursor_col] + line[old_pos..]
    elsif @cursor_row > 0
      prev_line = @lines[@cursor_row - 1]
      @cursor_col = prev_line.size
      @lines[@cursor_row - 1] = prev_line + @lines[@cursor_row]
      @lines.delete_at(@cursor_row)
      @cursor_row -= 1
    end
  end

  def delete_word_forward : Nil
    line = @lines[@cursor_row]
    if @cursor_col < line.size
      old_pos = @cursor_col
      pos = @cursor_col
      while pos < line.size && !line[pos].whitespace?
        pos += 1
      end
      while pos < line.size && line[pos].whitespace?
        pos += 1
      end
      @lines[@cursor_row] = line[0...old_pos] + line[pos..]
    elsif @cursor_row < @lines.size - 1
      @lines[@cursor_row] = line + @lines[@cursor_row + 1]
      @lines.delete_at(@cursor_row + 1)
    end
  end

  def set_cursor(row : Int32, col : Int32) : Nil
    @cursor_row = {0, {row, @lines.size - 1}.min}.max
    @cursor_col = {0, {col, @lines[@cursor_row].size}.min}.max
  end

  def width=(w : Int32) : Nil
    @width = w
  end

  def height=(h : Int32) : Nil
    @height = h
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
      when key.to_s == "up", key.ctrl && key.text == "p"
        move_up
      when key.to_s == "down", key.ctrl && key.text == "n"
        move_down
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
      when key.to_s == "enter", key.to_s == "ctrl+m"
        insert_newline
      when key.to_s == "pgup"
        page_up
      when key.to_s == "pgdown"
        page_down
      when key.ctrl && key.text == "k"
        @lines[@cursor_row] = @lines[@cursor_row][0...@cursor_col]
      when key.ctrl && key.text == "u"
        @lines[@cursor_row] = @lines[@cursor_row][@cursor_col..]
        @cursor_col = 0
      when !key.text.empty? && !key.ctrl && !key.alt
        key.text.each_char { |c| insert_char(c) }
      end

      adjust_viewport
    end
    {self, nil}
  end

  def view : String
    visible = [] of String
    gutter_width = @show_line_numbers ? (@lines.size.to_s.size + 1) : 0
    prompt_w = Lipgloss::ANSI.string_width(@prompt)
    content_width = {@width - gutter_width - prompt_w, 1}.max

    adjust_viewport

    @height.times do |i|
      line_idx = @viewport_y + i
      if line_idx < @lines.size
        line = @lines[line_idx]
        is_empty = @lines.size == 1 && @lines[0].empty? && !@placeholder.empty?
        if is_empty && line_idx == 0
          display = @placeholder
          if Lipgloss::ANSI.string_width(display) > content_width
            display = Lipgloss::ANSI.truncate(display, content_width)
          else
            display = display + " " * (content_width - Lipgloss::ANSI.string_width(display))
          end
          line = @placeholder_style.render(display)
        elsif line.empty?
          line = " " * content_width
          line = @style.render(line)
        else
          if @viewport_x > 0
            skipped = 0
            pos = 0
            line.each_char do |c|
              break if skipped >= @viewport_x
              skipped += Lipgloss::ANSI.char_width(c)
              pos += 1
            end
            line = line[pos..]
          end
          if Lipgloss::ANSI.string_width(line) > content_width
            line = Lipgloss::ANSI.truncate(line, content_width)
          else
            line = line + " " * (content_width - Lipgloss::ANSI.string_width(line))
          end
          line = @style.render(line)
        end

        if @show_line_numbers
          num = @line_number_style.render("#{line_idx + 1}".rjust(gutter_width - 1) + " ")
          line = num + line
        end

        if !@prompt.empty?
          line = @prompt + line
        end

        visible << line
      else
        pad = " " * content_width
        pad = @style.render(pad) unless @style == Lipgloss::Style.new
        if @show_line_numbers
          num = @line_number_style.render(" " * (gutter_width - 1) + " ")
          pad = num + pad
        end
        if !@prompt.empty?
          pad = @prompt + pad
        end
        visible << pad
      end
    end

    visible.join('\n')
  end

  private def adjust_viewport : Nil
    if @cursor_row < @viewport_y
      @viewport_y = @cursor_row
    elsif @cursor_row >= @viewport_y + @height
      @viewport_y = @cursor_row - @height + 1
    end

    gutter_width = @show_line_numbers ? (@lines.size.to_s.size + 1) : 0
    prompt_w = Lipgloss::ANSI.string_width(@prompt)
    content_width = {@width - gutter_width - prompt_w, 1}.max

    if @cursor_col < @viewport_x
      @viewport_x = @cursor_col
    elsif @cursor_col >= @viewport_x + content_width
      @viewport_x = @cursor_col - content_width + 1
    end

    max_line_width = @lines.max_of { |l| l.size }
    if @viewport_x > 0 && @viewport_x + content_width > max_line_width
      @viewport_x = {max_line_width - content_width + 1, 0}.max
    end
  end
end
