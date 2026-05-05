require "../../src/crubbletea"

WORDS = [
  "apple", "application", "banana", "blueberry", "buffer",
  "cancel", "canvas", "capture", "cherry", "click",
  "command", "component", "cursor", "daemon", "delegate",
  "display", "editor", "element", "filter", "focus",
  "format", "frame", "generate", "gradient", "handler",
  "highlight", "hover", "input", "interface", "key",
  "keyboard", "layout", "margin", "model", "mouse",
  "navigate", "output", "padding", "pager", "panel",
  "parser", "progress", "prompt", "render", "resize",
  "scroll", "spinner", "status", "style", "suggestion",
  "terminal", "theme", "toggle", "update", "view",
  "viewport", "widget", "window",
]

class AutocompleteModel
  include Crubbletea::Model

  getter input : Crubbletea::Bubbles::TextInput::Model

  def initialize
    prompt_style = Crubbletea::Lipgloss::Style.new
      .foreground("63")
      .margin(0, 0, 0, 2)

    @input = Crubbletea::Bubbles::TextInput::Model.new(
      prompt: "> ",
      prompt_style: prompt_style,
      placeholder: "Type to search...",
      width: 30,
      char_limit: 50,
    )
    @input.focus
    @input.show_suggestions = true
    @input.set_suggestions(WORDS)
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {AutocompleteModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "enter", "ctrl+c", "escape"
        return {self, Crubbletea.quit}
      end
    end

    @input, cmd = @input.update(msg)
    {self, cmd}
  end

  def view : Crubbletea::View
    s = "Type a word:\n"
    s += @input.view
    s += "\n\n  tab: complete • ↑/↓: navigate • esc: quit"

    v = Crubbletea.new_view(s)
    v.cursor = Crubbletea::Cursor.new(@input.visible_cursor_pos, 1) if @input.focused?
    v
  end
end

program = Crubbletea::Program(AutocompleteModel).new(AutocompleteModel.new)
program.run
