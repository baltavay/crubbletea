require "../../src/crubbletea"

class DynamicTextareaModel
  include Crubbletea::Model

  getter textarea : Crubbletea::Bubbles::TextArea::Model

  def initialize
    @textarea = Crubbletea::Bubbles::TextArea::Model.new(
      placeholder: "Schnrr...",
      width: 60,
      height: 3
    )
    @textarea.focus
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {DynamicTextareaModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c"
        return {self, Crubbletea.quit}
      end
    end

    @textarea, cmd = @textarea.update(msg)
    {self, cmd}
  end

  def view : Crubbletea::View
    status = sprintf(
      "\nHeight: %d · Lines: %d · Cursor: (%d, %d)",
      @textarea.height,
      @textarea.line_count,
      @textarea.cursor_col,
      @textarea.cursor_row
    )

    content = "\n#{@textarea.view}#{status}\n(ctrl+c to quit)"

    v = Crubbletea.new_view(content)
    if @textarea.focused?
      v.cursor = Crubbletea::Cursor.new(@textarea.visible_cursor_col, 1 + @textarea.visible_cursor_row)
    end
    v
  end
end

program = Crubbletea::Program(DynamicTextareaModel).new(DynamicTextareaModel.new)
program.run
