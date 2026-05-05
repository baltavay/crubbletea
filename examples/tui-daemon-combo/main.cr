require "../../src/crubbletea"

class TuiDaemonComboModel
  include Crubbletea::Model

  getter spinner : Crubbletea::Bubbles::Spinner::Model
  getter jobs : Array(String)
  getter daemon : Bool

  def initialize(@daemon : Bool = false)
    @spinner = Crubbletea::Bubbles::Spinner::Model.new(
      style: Crubbletea::Lipgloss::Style.new.foreground("#af87ff")
    )
    @jobs = [] of String
  end

  def init : Crubbletea::Cmd?
    cmds = [@spinner.tick] of Crubbletea::Cmd
    cmds << start_job("Cleanup")
    cmds << start_job("Index files")
    cmds << start_job("Sync remote")
    Crubbletea.batch(cmds)
  end

  struct JobDoneMsg
    include Crubbletea::Msg
    getter name : String

    def initialize(@name : String)
    end
  end

  def update(msg) : {TuiDaemonComboModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      return {self, Crubbletea.quit}
    when Crubbletea::Bubbles::Spinner::TickMsg
      @spinner, cmd = @spinner.update(msg)
      return {self, cmd}
    when JobDoneMsg
      @jobs << msg.name
      return {self, nil}
    end
    {self, nil}
  end

  def view : Crubbletea::View
    if @daemon
      return Crubbletea.new_view("")
    end

    s = "\n  #{@spinner.view} Background Jobs\n\n"
    @jobs.each { |j| s += "  ✓ #{j}\n" }
    s += "\n  Press any key to exit\n"

    Crubbletea.new_view(s)
  end

  private def start_job(name : String) : Crubbletea::Cmd
    ->{
      sleep (Random.new.next_float * 2 + 0.5).seconds
      JobDoneMsg.new(name).as(Crubbletea::Msg)
    }
  end
end

daemon = ARGV.includes?("-d") || !STDOUT.tty?
program = Crubbletea::Program(TuiDaemonComboModel).new(TuiDaemonComboModel.new(daemon: daemon), without_renderer: daemon)
program.run
