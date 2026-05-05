require "../../src/crubbletea"

class KeyboardEnhancementsModel
  include Crubbletea::Model

  getter last_press : String
  getter last_release : String
  getter enhancements_supported : Bool

  def initialize
    @last_press = ""
    @last_release = ""
    @enhancements_supported = false
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {KeyboardEnhancementsModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyboardEnhancementsMsg
      @enhancements_supported = msg.supported
    when Crubbletea::KeyPressMsg
      @last_press = msg.key.to_s
      return {self, Crubbletea.quit} if msg.key.to_s == "ctrl+c"
    when Crubbletea::KeyReleaseMsg
      @last_release = msg.key.to_s
    end
    {self, nil}
  end

  def view : Crubbletea::View
    s = "\n  Keyboard Enhancements\n\n"
    s += "  Enhanced keyboard: #{@enhancements_supported}\n\n"
    s += "  Last press:   #{@last_press.empty? ? "(none)" : @last_press}\n"
    s += "  Last release: #{@last_release.empty? ? "(none)" : @last_release}\n\n"
    s += "  Press any key to see events. ctrl+c to quit.\n"

    v = Crubbletea.new_view(s)
    v.keyboard_enhancements = Crubbletea::KeyboardEnhancements.new(report_event_types: true)
    v
  end
end

program = Crubbletea::Program(KeyboardEnhancementsModel).new(KeyboardEnhancementsModel.new)
program.run
