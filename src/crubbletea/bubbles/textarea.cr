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
    @line_number_style : Lipgloss::Style = Lipgloss::Style.new
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
    elsif @cursor_row > 0
      prev_line = @lines[@cursor_row - 1]
      @cursor_col = prev_line.size
      @lines[@cursor_row - 1] = prev_line + @lines[@cursor_row]
      @lines.delete_at(@cursor_row)
      @cursor_row -= 1
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

  def set_cursor(row : Int32, col : Int32) : Nil
    @cursor_row = {0, {row, @lines.size - 1}.min}.max
    @cursor_col = {0, {col, @lines[@cursor_row].size}.min}.max
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
      when key.to_s == "up"
        move_up
      when key.to_s == "down"
        move_down
      when key.to_s == "left"
        move_left
      when key.to_s == "right"
        move_right
      when key.to_s == "home", key.ctrl && key.to_s == "a"
        move_to_start
      when key.to_s == "end", key.ctrl && key.to_s == "e"
        move_to_end
      when key.to_s == "backspace"
        delete_char_backward
      when key.to_s == "delete"
        delete_char_forward
      when key.to_s == "enter"
        insert_newline
      when key.ctrl && key.to_s == "k"
        @lines[@cursor_row] = @lines[@cursor_row][0...@cursor_col]
      when key.ctrl && key.to_s == "u"
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
    content_width = {@width - gutter_width, 1}.max

    adjust_viewport

    @height.times do |i|
      line_idx = @viewport_y + i
      if line_idx < @lines.size
        line = @lines[line_idx]
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

        if @show_line_numbers
          num = @line_number_style.render("#{line_idx + 1}".rjust(gutter_width - 1) + " ")
          line = num + line
        end

        visible << line
      else
        visible << " " * @width
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
    content_width = {@width - gutter_width, 1}.max

    if @cursor_col < @viewport_x
      @viewport_x = @cursor_col
    elsif @cursor_col >= @viewport_x + content_width
      @viewport_x = @cursor_col - content_width + 1
    end
  end
end
