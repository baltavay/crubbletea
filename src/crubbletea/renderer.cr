class Crubbletea::Renderer
  @output : IO
  @width : Int32
  @height : Int32
  @last_view : View?
  @last_lines : Array(String) = [] of String
  @cursor_hidden : Bool = false
  @inline_height : Int32 = 0
  @cursor_row : Int32 = 0

  def initialize(@output : IO, @width : Int32 = 80, @height : Int32 = 24)
  end

  def resize(w : Int32, h : Int32) : Nil
    @width = w
    @height = h
  end

  def render(view : View) : Nil
    current_view = @last_view
    first_render = current_view.nil?

    if current_view &&
       current_view.content == view.content &&
       current_view.alt_screen == view.alt_screen &&
       current_view.cursor == view.cursor &&
       current_view.window_title == view.window_title &&
       current_view.progress_bar == view.progress_bar &&
       current_view.foreground_color == view.foreground_color &&
       current_view.background_color == view.background_color
      return
    end

    buf = IO::Memory.new

    screen_changed = false
    if view.alt_screen && (first_render || (current_view && !current_view.alt_screen))
      buf << ANSI.enter_alt_screen
      screen_changed = true
    elsif current_view && current_view.alt_screen && !view.alt_screen
      buf << ANSI.exit_alt_screen
      screen_changed = true
    end

    if view.cursor || !@cursor_hidden
      buf << ANSI.hide_cursor
      if c = view.cursor
        new_style = cursor_style_seq(c)
        old_cursor = current_view.try(&.cursor)
        if !old_cursor || cursor_style_seq(old_cursor) != new_style
          buf << new_style
        end
      end
      @cursor_hidden = true
    end

    if screen_changed
      @output.write(buf.to_slice)
      @output.flush
      buf = IO::Memory.new
    end

    if current_view && current_view.mouse_mode != view.mouse_mode
      case current_view.mouse_mode
      in MouseMode::None
        nil
      in MouseMode::CellMotion, MouseMode::AllMotion
        buf << ANSI.disable_mouse
      end
    end

    case view.mouse_mode
    in MouseMode::None
      nil
    in MouseMode::CellMotion
      buf << ANSI.enable_mouse_cell
    in MouseMode::AllMotion
      buf << ANSI.enable_mouse_all
    end

    if current_view && current_view.report_focus && !view.report_focus
      buf << ANSI.disable_focus
    elsif (!current_view || !current_view.report_focus) && view.report_focus
      buf << ANSI.enable_focus
    end

    if view.window_title != "" && (current_view.nil? || current_view.window_title != view.window_title)
      buf << ANSI.set_window_title(view.window_title)
    end

    if view.foreground_color != "" && (current_view.nil? || current_view.foreground_color != view.foreground_color)
      buf << ANSI.set_foreground_color(view.foreground_color)
    end

    if view.background_color != "" && (current_view.nil? || current_view.background_color != view.background_color)
      buf << ANSI.set_background_color(view.background_color)
    end

    if pb = view.progress_bar
      if current_view.nil? || current_view.try(&.progress_bar) != pb
        buf << ANSI.set_progress_bar(pb.state, pb.value)
      end
    end

    if ke = view.keyboard_enhancements
      if current_view.nil?
        buf << ANSI.enable_kitty_keyboard
      end
    end

    new_lines = view.content.split('\n')

    if view.alt_screen
      render_altscreen(buf, new_lines, first_render, screen_changed)
    else
      render_inline(buf, new_lines, first_render, screen_changed)
    end

    if cursor = view.cursor
      if view.alt_screen
        buf << ANSI.cursor_move(cursor.position.x, cursor.position.y)
      else
        up = @inline_height - 1 - cursor.position.y
        buf << ANSI.cursor_up(up) if up > 0
        buf << "\r"
        buf << ANSI.cursor_right(cursor.position.x) if cursor.position.x > 0
        @cursor_row = cursor.position.y
      end
      buf << cursor_style_seq(cursor)
      buf << ANSI.show_cursor
      @cursor_hidden = false
    else
      @cursor_row = @inline_height - 1
    end

    data = buf.to_slice
    if data.size > 0
      @output.write(data)
      @output.flush
    end

    @last_view = view
    @last_lines = new_lines
  end

  def force_render(view : View) : Nil
    old_lines = @last_lines
    old_inline_height = @inline_height
    @last_view = nil
    @last_lines = [] of String

    buf = IO::Memory.new

    buf << ANSI.hide_cursor
    if c = view.cursor
      buf << cursor_style_seq(c)
    end
    @cursor_hidden = true

    new_lines = view.content.split('\n')

    if view.alt_screen
      render_altscreen(buf, new_lines, true, false)
    else
      @inline_height = old_inline_height
      if @inline_height > 0
        buf << ANSI.cursor_up(@inline_height > 1 ? @inline_height - 1 : 1)
        buf << "\r"
      end
      written = {new_lines.size, old_lines.size}.max
      written.times do |i|
        buf << "\r"
        if i < new_lines.size
          buf << new_lines[i]
          buf << ANSI.erase_line_right
        else
          buf << ANSI.clear_line
        end
        buf << "\n" if i < written - 1
      end
      if new_lines.size < old_lines.size
        buf << ANSI.cursor_up(old_lines.size - new_lines.size)
      end
      @inline_height = new_lines.size
    end

    if cursor = view.cursor
      if view.alt_screen
        buf << ANSI.cursor_move(cursor.position.x, cursor.position.y)
      else
        up = @inline_height - 1 - cursor.position.y
        buf << ANSI.cursor_up(up) if up > 0
        buf << "\r"
        buf << ANSI.cursor_right(cursor.position.x) if cursor.position.x > 0
        @cursor_row = cursor.position.y
      end
      buf << cursor_style_seq(cursor)
      buf << ANSI.show_cursor
      @cursor_hidden = false
    end

    data = buf.to_slice
    if data.size > 0
      @output.write(data)
      @output.flush
    end

    @last_view = view
    @last_lines = new_lines
  end

  def clear_screen : Nil
    @output << ANSI.cursor_home
    @output << ANSI.clear_screen
    @output.flush
    @last_lines = [] of String
  end

  def insert_above(text : String) : Nil
    lines = text.split('\n')
    count = lines.size
    buf = IO::Memory.new
    buf << ANSI.cursor_move(0, 0)
    buf << ANSI.insert_line(count)
    lines.each do |line|
      buf << line
      buf << ANSI.clear_line
      buf << "\r\n"
    end
    @output.write(buf.to_slice)
    @output.flush
    @last_view = nil
    @last_lines = [] of String
  end

  def close : Nil
    if lv = @last_view
      if lv.alt_screen
        @output << ANSI.exit_alt_screen
      else
        @output << ANSI.clear_below
      end
      case lv.mouse_mode
      in MouseMode::None
        nil
      in MouseMode::CellMotion, MouseMode::AllMotion
        @output << ANSI.disable_mouse
      end
      if lv.report_focus
        @output << ANSI.disable_focus
      end
      if lv.window_title != ""
        @output << ANSI.set_window_title("")
      end
    end
    @output << ANSI.reset_cursor_style
    @output << ANSI.show_cursor
    @output << ANSI.disable_kitty_keyboard
    @output.flush
    @cursor_hidden = false
  end

  private def render_altscreen(buf : IO::Memory, new_lines : Array(String), first_render : Bool, screen_changed : Bool) : Nil
    if first_render || screen_changed
      buf << ANSI.clear_screen
    end
    old_lines = @last_lines
    max_lines = {@height, new_lines.size}.min
    max_lines.times do |i|
      old_line = old_lines[i]? || ""
      new_line = new_lines[i]? || ""
      if first_render || screen_changed || old_line != new_line
        buf << ANSI.cursor_move(0, i)
        buf << new_line
        buf << ANSI.erase_line_right unless first_render || screen_changed
      end
    end
    if @height > new_lines.size
      (new_lines.size...@height).each do |i|
        buf << ANSI.cursor_move(0, i)
        buf << ANSI.clear_line
      end
    end
  end

  private def render_inline(buf : IO::Memory, new_lines : Array(String), first_render : Bool, screen_changed : Bool) : Nil
    old_lines = @last_lines
    old_height = @inline_height

    if first_render
      move_up = 0
    elsif screen_changed
      move_up = old_height
    else
      move_up = @cursor_row
    end

    if move_up > 0
      buf << ANSI.cursor_up(move_up)
      buf << "\r"
    end

    written = {new_lines.size, old_lines.size}.max
    written.times do |i|
      old_line = old_lines[i]? || ""
      new_line = new_lines[i]? || ""
      if i < new_lines.size && (first_render || screen_changed || old_line != new_line)
        buf << "\r"
        buf << new_line
        buf << ANSI.erase_line_right
      elsif i < new_lines.size
        buf << "\r"
        buf << old_line
      else
        buf << "\r"
        buf << ANSI.clear_line
      end
      buf << "\n" if i < written - 1
    end

    if new_lines.size < old_lines.size
      buf << ANSI.cursor_up(old_lines.size - new_lines.size)
    end

    @inline_height = new_lines.size
  end

  private def cursor_style_seq(cursor : Cursor) : String
    case {cursor.shape, cursor.blink}
    when {CursorShape::Block, true}     then ANSI.set_cursor_style_block_blink
    when {CursorShape::Block, false}    then ANSI.set_cursor_style_block
    when {CursorShape::Underline, true} then ANSI.set_cursor_style_underline_blink
    when {CursorShape::Underline, false} then ANSI.set_cursor_style_underline
    when {CursorShape::Bar, true}       then ANSI.set_cursor_style_bar_blink
    when {CursorShape::Bar, false}      then ANSI.set_cursor_style_bar
    else                                     ANSI.set_cursor_style_block_blink
    end
  end
end
