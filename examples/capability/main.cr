require "../../src/crubbletea"

class CapabilityModel
  include Crubbletea::Model

  getter input : Crubbletea::Bubbles::TextInput::Model
  getter capabilities : Array({String, String})

  def initialize
    @input = Crubbletea::Bubbles::TextInput::Model.new(
      placeholder: "e.g. RGB, Tc...",
      char_limit: 50,
      width: 20,
      prompt: "> "
    )
    @input.focus
    @capabilities = [] of {String, String}
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {CapabilityModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c"
        return {self, Crubbletea.quit}
      when "enter"
        query = @input.value
        unless query.empty?
          @capabilities << {query, "(requested)"}
          @input.value = ""
        end
        return {self, nil}
      end
    when Crubbletea::CapabilityMsg
      @capabilities << {msg.name, msg.value}
    end

    @input, cmd = @input.update(msg)
    {self, cmd}
  end

  def view : Crubbletea::View
    s = "\n  Terminal Capability Query\n\n"
    s += "  #{@input.view}\n\n"

    if @capabilities.empty?
      s += "  No capabilities queried yet.\n"
    else
      @capabilities.each do |name, value|
        s += "  #{name}: #{value}\n"
      end
    end

    s += "\n  ctrl+c: quit • enter: query capability\n"

    v = Crubbletea.new_view(s)
    v.cursor = Crubbletea::Cursor.new(@input.visible_cursor_pos + 4, 3) if @input.focused?
    v
  end
end

program = Crubbletea::Program(CapabilityModel).new(CapabilityModel.new)
program.run
