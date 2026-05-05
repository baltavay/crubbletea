require "../../src/crubbletea"

FOCUSED_STYLE = Crubbletea::Lipgloss::Style.new.foreground("205")
BLURRED_STYLE = Crubbletea::Lipgloss::Style.new.foreground("240")
TEXTINPUTS_HELP_STYLE = BLURRED_STYLE
CURSOR_MODE_HELP_STYLE = Crubbletea::Lipgloss::Style.new.foreground("244")

class TextinputsModel
  include Crubbletea::Model

  getter focus_index : Int32
  getter inputs : Array(Crubbletea::Bubbles::TextInput::Model)
  getter quitting : Bool

  def initialize
    @focus_index = 0
    @quitting = false
    @inputs = (0..2).map do |i|
      Crubbletea::Bubbles::TextInput::Model.new(
        placeholder: i == 0 ? "Nickname" : (i == 1 ? "Email" : "Password"),
        width: 30,
        char_limit: i == 1 ? 64 : 32,
        echo_mode: i == 2 ? :password : :normal
      )
    end
    @inputs[0].focus
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {TextinputsModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "escape"
        @quitting = true
        return {self, Crubbletea.quit}
      when "tab", "shift+tab", "enter", "up", "down"
        s = msg.key.to_s
        if s == "enter" && @focus_index == @inputs.size
          return {self, Crubbletea.quit}
        end

        if s == "up" || s == "shift+tab"
          @focus_index -= 1
        else
          @focus_index += 1
        end

        if @focus_index > @inputs.size
          @focus_index = 0
        elsif @focus_index < 0
          @focus_index = @inputs.size
        end

        @inputs.each_with_index do |inp, i|
          if i == @focus_index
            inp.focus
          else
            inp.blur
          end
        end
        return {self, nil}
      when "ctrl+r"
        modes = [Crubbletea::Bubbles::Cursor::Model::Mode::Blink,
                 Crubbletea::Bubbles::Cursor::Model::Mode::Static,
                 Crubbletea::Bubbles::Cursor::Model::Mode::Hide]
        current = @inputs[@focus_index]?.try(&.cursor.mode) || modes[0]
        idx = modes.index(current) || 0
        next_mode = modes[(idx + 1) % modes.size]
        @inputs.each do |inp|
          inp.cursor.set_mode(next_mode)
        end
        return {self, nil}
      end
    end

    cmds = [] of Crubbletea::Cmd
    @inputs.each do |inp|
      inp, cmd = inp.update(msg)
      cmds << cmd if cmd
    end
    {self, cmds.empty? ? nil : Crubbletea.batch(cmds)}
  end

  def view : Crubbletea::View
    parts = [] of String

    @inputs.each_with_index do |inp, i|
      parts << inp.view
    end

    focused_button = FOCUSED_STYLE.render("[ Submit ]")
    blurred_button = "[ #{BLURRED_STYLE.render("Submit")} ]"

    if @focus_index == @inputs.size
      parts << ""
      parts << ""
      parts << focused_button
      parts << ""
      parts << ""
    else
      parts << ""
      parts << ""
      parts << blurred_button
      parts << ""
      parts << ""
    end

    current_mode = @inputs[@focus_index]?.try(&.cursor.mode) || Crubbletea::Bubbles::Cursor::Model::Mode::Blink
    mode_name = case current_mode
                when Crubbletea::Bubbles::Cursor::Model::Mode::Blink then "Blink Block"
                when Crubbletea::Bubbles::Cursor::Model::Mode::Static then "Steady Block"
                else "Hidden"
                end
    parts << TEXTINPUTS_HELP_STYLE.render("cursor mode is ") + CURSOR_MODE_HELP_STYLE.render(mode_name) + TEXTINPUTS_HELP_STYLE.render(" (ctrl+r to change style)")
    parts << "" if @quitting

    v = Crubbletea.new_view(parts.join('\n'))
    focused_input = @inputs[@focus_index]? if @focus_index < @inputs.size
     if focused_input && focused_input.focused?
       col = focused_input.visible_cursor_pos
      cm = focused_input.cursor
      case cm.mode
      when Crubbletea::Bubbles::Cursor::Model::Mode::Blink
        v.cursor = Crubbletea::Cursor.new(col, @focus_index, :block, true)
      when Crubbletea::Bubbles::Cursor::Model::Mode::Static
        v.cursor = Crubbletea::Cursor.new(col, @focus_index, :block, false)
      when Crubbletea::Bubbles::Cursor::Model::Mode::Hide
        nil
      end
    end
    v
  end
end

program = Crubbletea::Program(TextinputsModel).new(TextinputsModel.new)
program.run
