require "../../src/crubbletea"

class PreventQuitModel
  include Crubbletea::Model

  getter textarea : Crubbletea::Bubbles::TextArea::Model
  getter has_changes : Bool
  getter quit_confirm : Bool
  getter save_msg : String?

  def initialize
    @textarea = Crubbletea::Bubbles::TextArea::Model.new(
      placeholder: "Type something...",
      width: 60,
      height: 10
    )
    @textarea.focus
    @has_changes = false
    @quit_confirm = false
    @initial_value = ""
    @save_msg = nil
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {PreventQuitModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "escape"
        if @has_changes && !@quit_confirm
          @quit_confirm = true
          return {self, nil}
        end
        return {self, Crubbletea.quit}
      when "ctrl+s"
        if @has_changes
          @has_changes = false
          @initial_value = @textarea.value
          @save_msg = "Changes saved!"
        end
        return {self, nil}
      when "y"
        if @quit_confirm
          return {self, Crubbletea.quit}
        end
      when "n"
        if @quit_confirm
          @quit_confirm = false
          return {self, nil}
        end
      end
    end

    @textarea, cmd = @textarea.update(msg)

    if @textarea.value != @initial_value && !@has_changes
      @has_changes = true
    end

    {self, cmd}
  end

  def view : Crubbletea::View
    if @quit_confirm
      return Crubbletea.new_view("You have unsaved changes. Quit without saving? [y/N]\n")
    end

    content = @textarea.view + "\n"
    content += "#{@save_msg}\n" if @save_msg
    content += "(ctrl+c to quit"
    content += " • ctrl+s to save" if @has_changes
    content += ")\n"
    v = Crubbletea.new_view(content)
    if @textarea.focused?
      v.cursor = Crubbletea::Cursor.new(@textarea.visible_cursor_col, @textarea.visible_cursor_row)
    end
    v
  end
end

program = Crubbletea::Program(PreventQuitModel).new(PreventQuitModel.new)
program.run
