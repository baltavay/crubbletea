module Crubbletea::ANSI
  ESC = "\e"

  def self.cursor_up(n : Int32 = 1) : String
    "\e[#{n}A"
  end

  def self.cursor_down(n : Int32 = 1) : String
    "\e[#{n}B"
  end

  def self.cursor_right(n : Int32 = 1) : String
    "\e[#{n}C"
  end

  def self.cursor_left(n : Int32 = 1) : String
    "\e[#{n}D"
  end

  def self.cursor_home : String
    "\e[H"
  end

  def self.cursor_move(x : Int32, y : Int32) : String
    "\e[#{y + 1};#{x + 1}H"
  end

  def self.clear_screen : String
    "\e[2J"
  end

  def self.clear_line : String
    "\e[2K"
  end

  def self.clear_below : String
    "\e[J"
  end

  def self.hide_cursor : String
    "\e[?25l"
  end

  def self.show_cursor : String
    "\e[?25h"
  end

  def self.enter_alt_screen : String
    "\e[?1049h"
  end

  def self.exit_alt_screen : String
    "\e[?1049l"
  end

  def self.enable_mouse_cell : String
    "\e[?1000h\e[?1006h"
  end

  def self.enable_mouse_all : String
    "\e[?1003h\e[?1006h"
  end

  def self.disable_mouse : String
    "\e[?1000l\e[?1003l\e[?1006l"
  end

  def self.enable_focus : String
    "\e[?1004h"
  end

  def self.disable_focus : String
    "\e[?1004l"
  end

  def self.enable_bracketed_paste : String
    "\e[?2004h"
  end

  def self.disable_bracketed_paste : String
    "\e[?2004l"
  end

  def self.set_window_title(title : String) : String
    "\e]0;#{title}\e\\"
  end

  def self.set_cursor_style_block_blink : String
    "\e[1 q"
  end

  def self.set_cursor_style_block : String
    "\e[2 q"
  end

  def self.set_cursor_style_underline_blink : String
    "\e[3 q"
  end

  def self.set_cursor_style_underline : String
    "\e[4 q"
  end

  def self.set_cursor_style_bar_blink : String
    "\e[5 q"
  end

  def self.set_cursor_style_bar : String
    "\e[6 q"
  end

  def self.reset_cursor_style : String
    "\e[0 q"
  end

  def self.scroll_up(n : Int32 = 1) : String
    "\e[#{n}S"
  end

  def self.insert_line(n : Int32 = 1) : String
    "\e[#{n}L"
  end

  def self.erase_line_right : String
    "\e[K"
  end
end
