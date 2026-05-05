require "../../src/crubbletea"

class SuspendModel
  include Crubbletea::Model

  getter quitting : Bool
  getter suspending : Bool

  def initialize
    @quitting = false
    @suspending = false
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {SuspendModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::ResumeMsg
      @suspending = false
      return {self, nil}
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "q", "escape"
        @quitting = true
        return {self, Crubbletea.quit}
      when "ctrl+c"
        @quitting = true
        return {self, Crubbletea.interrupt}
      when "ctrl+z"
        @suspending = true
        return {self, Crubbletea.suspend}
      end
    end
    {self, nil}
  end

  def view : Crubbletea::View
    if @suspending || @quitting
      return Crubbletea.new_view("")
    end
    Crubbletea.new_view("\nPress ctrl-z to suspend, ctrl+c to interrupt, q, or esc to exit\n")
  end
end

program = Crubbletea::Program(SuspendModel).new(SuspendModel.new)
program.run
