require "../../src/crubbletea"

class TextinputModel
  include Crubbletea::Model

  getter text_input : Crubbletea::Bubbles::TextInput::Model
  getter quitting : Bool

  def initialize
    @text_input = Crubbletea::Bubbles::TextInput::Model.new(
      prompt: "> ",
      placeholder: "Pikachu",
      width: 20,
      char_limit: 156
    )
    @text_input.focus
    @quitting = false
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {TextinputModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "enter", "ctrl+c", "escape"
        @quitting = true
        return {self, Crubbletea.quit}
      end
    end

    @text_input, cmd = @text_input.update(msg)
    {self, cmd}
  end

  def view : Crubbletea::View
    header = "What's your favorite Pokémon?\n"
    body = @text_input.view
    footer = "\n(esc to quit)"
    suffix = @quitting ? "\n" : ""

     v = Crubbletea.new_view("#{header}#{body}#{footer}#{suffix}")
     if @text_input.focused?
       v.cursor = Crubbletea::Cursor.new(@text_input.visible_cursor_pos, 1)
     end
    v
  end
end

program = Crubbletea::Program(TextinputModel).new(TextinputModel.new)
program.run
