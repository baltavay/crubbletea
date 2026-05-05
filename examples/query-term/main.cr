require "../../src/crubbletea"

struct SentMsg
  include Crubbletea::Msg
end

class QueryTermModel
  include Crubbletea::Model

  getter input : Crubbletea::Bubbles::TextInput::Model
  getter err : Exception?
  getter last_msg : String

  def initialize
    @input = Crubbletea::Bubbles::TextInput::Model.new(
      char_limit: 156,
      width: 20
    )
    @input.focus
    @err = nil
    @last_msg = ""
  end

  def init : Crubbletea::Cmd?
    nil
  end

  private def unescape(s : String) : String
    result = String::Builder.new
    i = 0
    while i < s.size
      if s[i] == '\\' && i + 1 < s.size
        case s[i + 1]
        when 'e', 'E'
          result << '\e'
          i += 2
        when 'x'
          hex = s[i + 2, 2]
          result << hex.to_u8(16).chr
          i += 4
        when 'n'
          result << '\n'
          i += 2
        when 'r'
          result << '\r'
          i += 2
        when 't'
          result << '\t'
          i += 2
        when '\\'
          result << '\\'
          i += 2
        when '['
          result << '\e' << '['
          i += 2
        else
          result << s[i]
          i += 1
        end
      else
        result << s[i]
        i += 1
      end
    end
    result.to_s
  end

  def update(msg) : {QueryTermModel, Crubbletea::Cmd?}
    cmds = [] of Crubbletea::Cmd

    case msg
    when Crubbletea::KeyPressMsg
      @err = nil
      case msg.key.to_s
      when "ctrl+c"
        return {self, Crubbletea.quit}
      when "enter"
        val = @input.value
        seq = unescape(val)
        unless seq.starts_with?('\e')
          @err = Exception.new("sequence is not an ANSI escape sequence")
          return {self, nil}
        end

        @input.value = ""
        cmds << ->{
          STDOUT << seq
          STDOUT.flush
          SentMsg.new.as(Crubbletea::Msg)
        }
      end
    when Crubbletea::BackgroundColorMsg, Crubbletea::CapabilityMsg,
         Crubbletea::CursorPositionMsg, Crubbletea::MouseClickMsg,
         Crubbletea::MouseMotionMsg, Crubbletea::MouseReleaseMsg,
         Crubbletea::MouseWheelMsg, Crubbletea::FocusMsg, Crubbletea::BlurMsg,
         Crubbletea::ColorProfileMsg, Crubbletea::KeyboardEnhancementsMsg,
         Crubbletea::KeyReleaseMsg
      short = msg.class.name.split("::").last
      text = "Received message: #{short} #{msg.inspect}"
      cmds << Crubbletea.printf("%s", text)
    end

    @input, cmd = @input.update(msg)
    cmds << cmd if cmd

    {self, Crubbletea.batch(cmds)}
  end

  def view : Crubbletea::View
    s = @input.view
    if e = @err
      s += "\n\nError: #{e.message}"
    end
    s += "\n\nPress ctrl+c to quit, enter to write the sequence to the terminal"
    v = Crubbletea.new_view(s)
    prompt_w = Crubbletea::Lipgloss::ANSI.string_width(@input.prompt)
    v.cursor = Crubbletea::Cursor.new(prompt_w + @input.visible_cursor_pos, 0)
    v
  end
end

program = Crubbletea::Program(QueryTermModel).new(QueryTermModel.new)
program.run
