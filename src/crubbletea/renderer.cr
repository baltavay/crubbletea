class Crubbletea::Renderer
  @output : IO::FileDescriptor
  @width : Int32
  @height : Int32
  @last_view : View?
  @last_lines : Array(String) = [] of String

  def initialize(@output : IO::FileDescriptor, @width : Int32, @height : Int32)
  end

  def resize(w : Int32, h : Int32) : Nil
    @width = w
    @height = h
  end

  def render(view : View) : Nil
    current_view = @last_view
    first_render = current_view.nil?

    if current_view && !first_render &&
       current_view.content == view.content &&
       current_view.alt_screen == view.alt_screen &&
       current_view.cursor == view.cursor &&
       current_view.window_title == view.window_title
      return
    end

    buf = IO::Memory.new

    if first_render || (current_view && !current_view.alt_screen && view.alt_screen)
      buf << ANSI.enter_alt_screen
    elsif current_view && current_view.alt_screen && !view.alt_screen
      buf << ANSI.exit_alt_screen
    end

    buf << ANSI.hide_cursor

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

    new_lines = view.content.split('\n')

    if first_render
      buf << ANSI.clear_screen
      max_lines = {@height, new_lines.size}.min
      max_lines.times do |i|
        buf << ANSI.cursor_move(0, i)
        buf << ANSI.clear_line
        buf << new_lines[i]? || ""
      end
      if @height > new_lines.size
        (@height - new_lines.size).times do |i|
          buf << ANSI.cursor_move(0, new_lines.size + i)
          buf << ANSI.clear_line
        end
      end
    else
      old_lines = @last_lines
      max_lines = {@height, {old_lines.size, new_lines.size}.max}.min

      max_lines.times do |i|
        old_line = old_lines[i]? || ""
        new_line = new_lines[i]? || ""
        next if old_line == new_line

        buf << ANSI.cursor_move(0, i)
        buf << ANSI.clear_line
        buf << new_line
      end

      if new_lines.size < old_lines.size
        (new_lines.size...{@height, old_lines.size}.min).each do |i|
          buf << ANSI.cursor_move(0, i)
          buf << ANSI.clear_line
        end
      end
    end

    if cursor = view.cursor
      buf << ANSI.cursor_move(cursor.position.x, cursor.position.y)
      buf << cursor_style_seq(cursor)
      buf << ANSI.show_cursor
    end

    @output.write(buf.to_slice)
    @output.flush

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
    @output << ANSI.scroll_up
    @output << ANSI.cursor_move(0, 0)
    @output << ANSI.insert_line
    @output << text
    @output << "\n"
    @output.flush
  end

  def close : Nil
    if lv = @last_view
      if lv.alt_screen
        @output << ANSI.exit_alt_screen
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
    @output.flush
  end

  private def cursor_style_seq(cursor : Cursor) : String
    case {cursor.shape, cursor.blink}
    when {:block, true}     then ANSI.set_cursor_style_block_blink
    when {:block, false}    then ANSI.set_cursor_style_block
    when {:underline, true} then ANSI.set_cursor_style_underline_blink
    when {:underline, false} then ANSI.set_cursor_style_underline
    when {:bar, true}       then ANSI.set_cursor_style_bar_blink
    when {:bar, false}      then ANSI.set_cursor_style_bar
    else                         ANSI.set_cursor_style_block_blink
    end
  end
end
