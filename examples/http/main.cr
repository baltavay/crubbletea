require "../../src/crubbletea"
require "http/client"

URL = "https://charm.sh/"

struct StatusMsg
  include Crubbletea::Msg
  getter status : Int32

  def initialize(@status : Int32)
  end
end

struct ErrMsg
  include Crubbletea::Msg
  getter error : Exception

  def initialize(@error : Exception)
  end
end

class HttpModel
  include Crubbletea::Model

  getter status : Int32
  getter err : Exception?

  def initialize
    @status = 0
    @err = nil
  end

  def init : Crubbletea::Cmd?
    ->{
      begin
        response = HTTP::Client.get(URL)
        StatusMsg.new(response.status_code).as(Crubbletea::Msg)
      rescue e
        ErrMsg.new(e).as(Crubbletea::Msg)
      end
    }
  end

  def update(msg) : {HttpModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "q", "ctrl+c", "escape"
        return {self, Crubbletea.quit}
      end
    when StatusMsg
      @status = msg.status
      return {self, Crubbletea.quit}
    when ErrMsg
      @err = msg.error
    end
    {self, nil}
  end

  def view : Crubbletea::View
    s = "Checking #{URL}..."
    if e = @err
      s += "\nsomething went wrong: #{e.message}"
    elsif @status != 0
      s += "\n#{@status}"
    end
    Crubbletea.new_view(s + "\n")
  end
end

program = Crubbletea::Program(HttpModel).new(HttpModel.new)
program.run
