require "../../src/crubbletea"

class MyKeyMap
  include Crubbletea::Bubbles::Help::KeyMap

  getter up_key : Crubbletea::Bubbles::Key::Binding
  getter down_key : Crubbletea::Bubbles::Key::Binding
  getter left_key : Crubbletea::Bubbles::Key::Binding
  getter right_key : Crubbletea::Bubbles::Key::Binding
  getter help_key : Crubbletea::Bubbles::Key::Binding
  getter quit_key : Crubbletea::Bubbles::Key::Binding

  def initialize
    @up_key = Crubbletea::Bubbles::Key::Binding.new(["up", "k"], "↑/k", "move up")
    @down_key = Crubbletea::Bubbles::Key::Binding.new(["down", "j"], "↓/j", "move down")
    @left_key = Crubbletea::Bubbles::Key::Binding.new(["left", "h"], "←/h", "move left")
    @right_key = Crubbletea::Bubbles::Key::Binding.new(["right", "l"], "→/l", "move right")
    @help_key = Crubbletea::Bubbles::Key::Binding.new(["?"], "?", "toggle help")
    @quit_key = Crubbletea::Bubbles::Key::Binding.new(["q", "ctrl+c", "escape"], "q", "quit")
  end

  def short_help : Array(Crubbletea::Bubbles::Key::Binding)
    [@help_key, @quit_key]
  end

  def full_help : Array(Array(Crubbletea::Bubbles::Key::Binding))
    [
      [@up_key, @down_key, @left_key, @right_key],
      [@help_key, @quit_key],
    ]
  end
end

class HelpModel
  include Crubbletea::Model

  getter keys : MyKeyMap
  getter help : Crubbletea::Bubbles::Help::Model
  getter last_key : String
  getter quitting : Bool

  @show_all : Bool

  def initialize
    @keys = MyKeyMap.new
    @help = Crubbletea::Bubbles::Help::Model.new
    @last_key = ""
    @quitting = false
    @show_all = false
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {HelpModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::WindowSizeMsg
      nil
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "up", "k"
        @last_key = "↑"
      when "down", "j"
        @last_key = "↓"
      when "left", "h"
        @last_key = "←"
      when "right", "l"
        @last_key = "→"
      when "?"
        @show_all = !@show_all
        @help = Crubbletea::Bubbles::Help::Model.new(show_all: @show_all)
      when "q", "ctrl+c", "escape"
        @quitting = true
        return {self, Crubbletea.quit}
      end
    end
    {self, nil}
  end

  def view : Crubbletea::View
    if @quitting
      return Crubbletea.new_view("Bye!\n")
    end

    input_style = Crubbletea::Lipgloss::Style.new.foreground("#FF75B7")

    status = @last_key.empty? ? "Waiting for input..." : "You chose: #{input_style.render(@last_key)}"
    help_view = @help.view(@keys)
    height = 8 - status.count('\n') - help_view.count('\n')

    Crubbletea.new_view(status + ("\n" * {height, 0}.max) + help_view)
  end
end

program = Crubbletea::Program(HelpModel).new(HelpModel.new)
program.run
