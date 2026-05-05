require "../../src/crubbletea"

class TextareaModel
  include Crubbletea::Model

  getter textarea : Crubbletea::Bubbles::TextArea::Model

  def initialize
    @textarea = Crubbletea::Bubbles::TextArea::Model.new(
      placeholder: "Once upon a time...",
      width: 40,
      height: 6,
      prompt: "┃ ",
      show_line_numbers: true,
      line_number_style: Crubbletea::Lipgloss::Style.new.foreground("7")
    )
    @textarea.focus
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {TextareaModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "escape"
        if @textarea.focused?
          @textarea.blur
        end
      when "ctrl+c"
        return {self, Crubbletea.quit}
      else
        unless @textarea.focused?
          @textarea.focus
        end
      end
    end

    @textarea, cmd = @textarea.update(msg)
    {self, cmd}
  end

  def view : Crubbletea::View
    header = "Tell me a story.\n"
    footer = "\n(ctrl+c to quit)\n"

    content = "#{header}\n#{@textarea.view}\n#{footer}"
    v = Crubbletea.new_view(content)
    if @textarea.focused?
      v.cursor = Crubbletea::Cursor.new(@textarea.visible_cursor_col, 2 + @textarea.visible_cursor_row)
    end
    v
  end
end

program = Crubbletea::Program(TextareaModel).new(TextareaModel.new)
program.run
