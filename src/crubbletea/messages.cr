struct Crubbletea::QuitMsg
  include Crubbletea::Msg
end

struct Crubbletea::InterruptMsg
  include Crubbletea::Msg
end

struct Crubbletea::SuspendMsg
  include Crubbletea::Msg
end

struct Crubbletea::ResumeMsg
  include Crubbletea::Msg
end

struct Crubbletea::WindowSizeMsg
  include Crubbletea::Msg
  getter width : Int32
  getter height : Int32

  def initialize(@width : Int32, @height : Int32)
  end
end

struct Crubbletea::ClearScreenMsg
  include Crubbletea::Msg
end

struct Crubbletea::FocusMsg
  include Crubbletea::Msg
end

struct Crubbletea::BlurMsg
  include Crubbletea::Msg
end

struct Crubbletea::PasteMsg
  include Crubbletea::Msg
  getter content : String

  def initialize(@content : String)
  end

  def to_s : String
    @content
  end
end

struct Crubbletea::CursorPositionMsg
  include Crubbletea::Msg
  getter x : Int32
  getter y : Int32

  def initialize(@x : Int32, @y : Int32)
  end
end

struct Crubbletea::BatchMsg
  include Crubbletea::Msg
  getter cmds : Array(Proc(Msg))

  def initialize(@cmds : Array(Proc(Msg)))
  end
end

struct Crubbletea::SequenceMsg
  include Crubbletea::Msg
  getter cmds : Array(Proc(Msg))

  def initialize(@cmds : Array(Proc(Msg)))
  end
end

struct Crubbletea::EnvMsg
  include Crubbletea::Msg
  getter env : Array(String)

  def initialize(@env : Array(String))
  end
end

struct Crubbletea::EscapePendingMsg
  include Crubbletea::Msg
end

struct Crubbletea::FlushEscapeMsg
  include Crubbletea::Msg
end

struct Crubbletea::PrintLineMsg
  include Crubbletea::Msg
  getter body : String

  def initialize(@body : String)
  end
end

struct Crubbletea::CapabilityMsg
  include Crubbletea::Msg
  getter name : String
  getter value : String

  def initialize(@name : String, @value : String)
  end
end

struct Crubbletea::BackgroundColorMsg
  include Crubbletea::Msg
  getter hex : String

  def initialize(@hex : String)
  end

  def dark? : Bool
    h = hex.lchop('#')
    r = h[0..1].to_i(16)
    g = h[2..3].to_i(16)
    b = h[4..5].to_i(16)
    luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0
    luminance < 0.5
  end
end

struct Crubbletea::ColorProfileMsg
  include Crubbletea::Msg
  getter profile : Symbol

  def initialize(@profile : Symbol = :truecolor)
  end
end

struct Crubbletea::KeyboardEnhancementsMsg
  include Crubbletea::Msg
  getter supported : Bool

  def initialize(@supported : Bool = false)
  end
end

struct Crubbletea::KeyReleaseMsg
  include Crubbletea::Msg
  getter key : Crubbletea::Key

  def initialize(@key : Crubbletea::Key)
  end
end

struct Crubbletea::ExecFinishedMsg
  include Crubbletea::Msg
  getter err : Exception?

  def initialize(@err : Exception? = nil)
  end
end

struct Crubbletea::FlushRenderMsg
  include Crubbletea::Msg
end
