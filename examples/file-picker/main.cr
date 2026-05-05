require "../../src/crubbletea"

struct ClearErrorMsg
  include Crubbletea::Msg
end

class FilePickerModel
  include Crubbletea::Model

  getter filepicker : Crubbletea::Bubbles::FilePicker::Model
  getter selected_file : String?
  getter quitting : Bool

  def initialize
    @filepicker = Crubbletea::Bubbles::FilePicker::Model.new(
      width: 40,
      height: 15
    )
    @selected_file = nil
    @quitting = false
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {FilePickerModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "q"
        @quitting = true
        return {self, Crubbletea.quit}
      end
    when ClearErrorMsg
      return {self, nil}
    end

    @filepicker, cmd = @filepicker.update(msg)
    if @filepicker.did_select?
      @selected_file = @filepicker.selected_file
      return {self, Crubbletea.quit}
    end
    {self, cmd}
  end

  def view : Crubbletea::View
    if f = @selected_file
      return Crubbletea.new_view("Selected: #{f}\n")
    end
    header = "Pick a file:\n\n"
    footer = "\n\nenter: select • backspace/h: go up • q: quit"
    Crubbletea.new_view(header + @filepicker.view + footer)
  end
end

program = Crubbletea::Program(FilePickerModel).new(FilePickerModel.new)
program.run
