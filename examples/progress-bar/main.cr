require "../../src/crubbletea"

class ProgressBarModel
  include Crubbletea::Model

  getter value : Int32
  getter state : Int32

  STATE_NAMES = ["None", "Indeterminate", "Normal", "Error", "Paused"]

  def initialize
    @value = 50
    @state = 0
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {ProgressBarModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "q"
        return {self, Crubbletea.quit}
      when "up", "k"
        @value = {@value + 10, 100}.min
      when "down", "j"
        @value = {@value - 10, 0}.max
      when "right", "l"
        @state = (@state + 1) % STATE_NAMES.size
      when "left", "h"
        @state = (@state - 1) % STATE_NAMES.size
      end
    end
    {self, nil}
  end

  def view : Crubbletea::View
    filled = @value / 5
    bar = "█" * filled.to_i
    empty = "░" * (20 - filled.to_i)

    content = "\n  Terminal Progress Bar\n\n" \
      "  State: #{STATE_NAMES[@state]}\n" \
      "  Value: #{@value}%\n\n" \
      "  #{bar}#{empty}  #{@value}%\n\n" \
      "  ↑/↓: adjust value • ←/→: change state • q: quit\n"

    v = Crubbletea.new_view(content)
    v.progress_bar = Crubbletea::ProgressBar.new(@state, @value)
    v
  end
end

program = Crubbletea::Program(ProgressBarModel).new(ProgressBarModel.new)
program.run
