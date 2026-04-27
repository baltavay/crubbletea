require "./crubbletea/msg"
require "./crubbletea/model"
require "./crubbletea/key"
require "./crubbletea/mouse"
require "./crubbletea/messages"
require "./crubbletea/cursor"
require "./crubbletea/view"
require "./crubbletea/commands"
require "./crubbletea/ansi"
require "./crubbletea/termios"
require "./crubbletea/input_parser"
require "./crubbletea/renderer"
require "./crubbletea/program"
require "./crubbletea/harmonica"
require "./crubbletea/lipgloss"
require "./crubbletea/zone"
require "./crubbletea/bubbles"
require "./crubbletea/bubbles/key"
require "./crubbletea/bubbles/spinner"
require "./crubbletea/bubbles/timer"
require "./crubbletea/bubbles/stopwatch"
require "./crubbletea/bubbles/progress"
require "./crubbletea/bubbles/paginator"
require "./crubbletea/bubbles/help"
require "./crubbletea/bubbles/cursor"
require "./crubbletea/bubbles/viewport"
require "./crubbletea/bubbles/textinput"
require "./crubbletea/bubbles/textarea"
require "./crubbletea/bubbles/table"
require "./crubbletea/bubbles/list"
require "./crubbletea/bubbles/filepicker"
require "./crubbletea/ntcharts"

module Crubbletea
  VERSION = "0.1.0"

  def self.quit : Cmd
    -> { QuitMsg.new.as(Msg) }
  end

  def self.interrupt : Cmd
    -> { InterruptMsg.new.as(Msg) }
  end

  def self.suspend : Cmd
    -> { SuspendMsg.new.as(Msg) }
  end

  def self.new_view(content : String) : View
    View.new(content)
  end
end
