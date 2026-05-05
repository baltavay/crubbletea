require "../../src/crubbletea"

struct ResponseMsg
  include Crubbletea::Msg
end

class RealtimeModel
  include Crubbletea::Model

  getter responses : Int32
  getter spinner : Crubbletea::Bubbles::Spinner::Model
  getter quitting : Bool
  getter sub : Channel(Nil)

  def initialize
    @sub = Channel(Nil).new
    @responses = 0
    @spinner = Crubbletea::Bubbles::Spinner::Model.new
    @quitting = false
  end

  def init : Crubbletea::Cmd?
    Crubbletea.batch([
      @spinner.tick,
      listen_for_activity,
      wait_for_activity
    ] of Crubbletea::Cmd)
  end

  def update(msg) : {RealtimeModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      @quitting = true
      return {self, Crubbletea.quit}
    when ResponseMsg
      @responses += 1
      return {self, wait_for_activity}
    when Crubbletea::Bubbles::Spinner::TickMsg
      @spinner, cmd = @spinner.update(msg)
      return {self, cmd}
    end
    {self, nil}
  end

  def view : Crubbletea::View
    s = "\n #{@spinner.view} Events received: #{@responses}\n\n Press any key to exit\n"
    s += "\n" if @quitting
    Crubbletea.new_view(s)
  end

  private def listen_for_activity : Crubbletea::Cmd
    ->{
      spawn do
        loop do
          sleep (Random.new.next_float * 0.9 + 0.1).seconds
          @sub.send(nil)
        end
      end
      ResponseMsg.new.as(Crubbletea::Msg)
    }
  end

  private def wait_for_activity : Crubbletea::Cmd
    ->{
      @sub.receive
      ResponseMsg.new.as(Crubbletea::Msg)
    }
  end
end

program = Crubbletea::Program(RealtimeModel).new(RealtimeModel.new)
program.run
