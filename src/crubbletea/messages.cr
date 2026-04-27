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
