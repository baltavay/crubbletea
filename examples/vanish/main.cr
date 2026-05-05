require "../../src/crubbletea"

class VanishModel
  include Crubbletea::Model

  getter quitting : Bool

  def initialize(@quitting = false)
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {VanishModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      @quitting = true
      return {self, Crubbletea.quit}
    end
    {self, nil}
  end

  def view : Crubbletea::View
    if @quitting
      return Crubbletea.new_view("")
    end
    Crubbletea.new_view("Press any key to quit.\n(When this program quits, it will vanish without a trace.)")
  end
end

program = Crubbletea::Program(VanishModel).new(VanishModel.new)
program.run
