require "../../src/crubbletea"

class PipeModel
  include Crubbletea::Model

  getter user_input : Crubbletea::Bubbles::TextInput::Model

  def initialize(initial_value : String)
    @user_input = Crubbletea::Bubbles::TextInput::Model.new(
      prompt: "",
      width: 48
    )
    @user_input.value = initial_value
    @user_input.cursor_end
    @user_input.focus
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {PipeModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "escape", "enter"
        return {self, Crubbletea.quit}
      end
    end

    @user_input, cmd = @user_input.update(msg)
    {self, cmd}
  end

  def view : Crubbletea::View
    v = Crubbletea.new_view(
      "\nYou piped in: #{@user_input.view}\n\nPress ^C to exit"
    )
    if @user_input.focused?
      label_w = Crubbletea::Lipgloss::ANSI.string_width("You piped in: ")
      v.cursor = Crubbletea::Cursor.new(label_w + @user_input.visible_cursor_pos, 1)
    end
    v
  end
end

if STDIN.tty? && !Crubbletea.test_mode?
  puts "Try piping in some text."
  exit 1
end

input = STDIN.tty? ? "" : STDIN.gets_to_end.strip
program = Crubbletea::Program(PipeModel).new(PipeModel.new(input))
program.run unless Crubbletea.test_mode?
