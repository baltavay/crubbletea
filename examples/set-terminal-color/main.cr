require "../../src/crubbletea"

MODES = ["foreground", "background", "cursor"]

class SetTerminalColorModel
  include Crubbletea::Model

  getter mode_index : Int32
  getter input : Crubbletea::Bubbles::TextInput::Model
  getter fg_color : String
  getter bg_color : String
  getter cursor_color : String

  def initialize
    @mode_index = 0
    @input = Crubbletea::Bubbles::TextInput::Model.new(
      placeholder: "#FF0000",
      width: 20,
      prompt: "> "
    )
    @input.focus
    @fg_color = ""
    @bg_color = ""
    @cursor_color = ""
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {SetTerminalColorModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "q"
        return {self, Crubbletea.quit}
      when "j", "down"
        @mode_index = (@mode_index + 1) % MODES.size
        return {self, nil}
      when "k", "up"
        @mode_index = (@mode_index - 1) % MODES.size
        return {self, nil}
      when "enter"
        val = @input.value
        if val.matches?(/^#[0-9a-fA-F]{6}$/)
          case MODES[@mode_index]
          when "foreground"
            @fg_color = val
          when "background"
            @bg_color = val
          when "cursor"
            @cursor_color = val
          end
          @input.value = ""
        end
        return {self, nil}
      end
    end

    @input, cmd = @input.update(msg)
    {self, cmd}
  end

  def view : Crubbletea::View
    s = "\n  Set Terminal Color\n\n"
    MODES.each_with_index do |mode, i|
      marker = i == @mode_index ? ">" : " "
      s += "  #{marker} #{mode}\n"
    end
    s += "\n"
    s += "  Enter a hex color (e.g. #FF0000):\n"
    s += "  #{@input.view}\n\n"
    s += "  j/k: switch mode • enter: apply • q: quit\n"

    v = Crubbletea.new_view(s)
    v.foreground_color = @fg_color unless @fg_color.empty?
    v.background_color = @bg_color unless @bg_color.empty?
    prompt_w = Crubbletea::Lipgloss::ANSI.string_width(@input.prompt)
    v.cursor = Crubbletea::Cursor.new(2 + prompt_w + @input.visible_cursor_pos, 8) if @input.focused?
    v
  end
end

program = Crubbletea::Program(SetTerminalColorModel).new(SetTerminalColorModel.new)
program.run
