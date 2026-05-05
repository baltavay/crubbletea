require "../lipgloss"

struct Crubbletea::Bubbles::Spinner::SpinnerFrames
  getter frames : Array(String)
  getter fps : Time::Span

  def initialize(@frames : Array(String), @fps : Time::Span)
  end
end

module Crubbletea::Bubbles::Spinner
  LINE      = SpinnerFrames.new(["|", "/", "-", "\\"], 100.milliseconds)
  DOT       = SpinnerFrames.new(["⣾ ", "⣽ ", "⣻ ", "⢿ ", "⡿ ", "⣟ ", "⣯ ", "⣷ "], 100.milliseconds)
  MINI_DOT  = SpinnerFrames.new(["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"], 83.milliseconds)
  JUMP      = SpinnerFrames.new(["⢄", "⢂", "⢁", "⡁", "⡈", "⡐", "⡠"], 100.milliseconds)
  PULSE     = SpinnerFrames.new(["█", "▓", "▒", "░"], 125.milliseconds)
  POINTS    = SpinnerFrames.new(["∙∙∙", "●∙∙", "∙●∙", "∙∙●"], 142.milliseconds)
  GLOBE     = SpinnerFrames.new(["🌍", "🌎", "🌏"], 250.milliseconds)
  MOON      = SpinnerFrames.new(["🌑", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘"], 125.milliseconds)
  MONKEY    = SpinnerFrames.new(["🙈", "🙉", "🙊"], 333.milliseconds)
  METER     = SpinnerFrames.new(["▱▱▱", "▰▱▱", "▰▰▱", "▰▰▰", "▰▰▱", "▰▱▱", "▱▱▱"], 142.milliseconds)
  HAMBURGER = SpinnerFrames.new(["☱", "☲", "☴", "☲"], 333.milliseconds)
  ELLIPSIS  = SpinnerFrames.new(["", ".", "..", "..."], 333.milliseconds)
end

struct Crubbletea::Bubbles::Spinner::TickMsg
  include Crubbletea::Msg
  getter time : Time
  getter id : Int32
  getter tag : Int32

  def initialize(@time : Time = Time.utc, @id : Int32 = 0, @tag : Int32 = 0)
  end
end

class Crubbletea::Bubbles::Spinner::Model
  getter spinner : SpinnerFrames
  getter style : Lipgloss::Style
  getter id : Int32
  getter frame : Int32

  @@last_id = 0

  def initialize(@spinner : SpinnerFrames = LINE, @style : Lipgloss::Style = Lipgloss::Style.new)
    @@last_id += 1
    @id = @@last_id
    @frame = 0
    @tag = 0
  end

  def update(msg : Crubbletea::Msg) : {Model, Crubbletea::Cmd}
    case msg
    when TickMsg
      if msg.id > 0 && msg.id != @id
        return {self, nil}
      end
      if msg.tag > 0 && msg.tag != @tag
        return {self, nil}
      end

      @frame = (@frame + 1) % @spinner.frames.size
      @tag += 1
      {self, tick_cmd(@id, @tag)}
    else
      {self, nil}
    end
  end

  def view : String
    return "(error)" if @frame >= @spinner.frames.size
    @style.render(@spinner.frames[@frame])
  end

  def tick : Crubbletea::Cmd
    @tag += 1
    tick_cmd(@id, @tag)
  end

  private def tick_cmd(id : Int32, tag : Int32) : Crubbletea::Cmd
    ->{
      sleep @spinner.fps
      TickMsg.new(Time.utc, id, tag).as(Crubbletea::Msg)
    }
  end
end
