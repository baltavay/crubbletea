require "../../src/crubbletea"

class TimerModel
  include Crubbletea::Model
  include Crubbletea::Bubbles::Help::KeyMap

  getter timer : Crubbletea::Bubbles::Timer::Model
  getter quitting : Bool

  @start_key : Crubbletea::Bubbles::Key::Binding
  @stop_key : Crubbletea::Bubbles::Key::Binding
  @reset_key : Crubbletea::Bubbles::Key::Binding
  @quit_key : Crubbletea::Bubbles::Key::Binding

  def initialize
    @timer = Crubbletea::Bubbles::Timer::Model.new(
      timeout: 5.seconds,
      interval: 1.millisecond
    )
    @quitting = false

    @start_key = Crubbletea::Bubbles::Key.new_binding("s", help_key: "s", help_desc: "start")
    @stop_key = Crubbletea::Bubbles::Key.new_binding("s", help_key: "s", help_desc: "stop")
    @reset_key = Crubbletea::Bubbles::Key.new_binding("r", help_key: "r", help_desc: "reset")
    @quit_key = Crubbletea::Bubbles::Key.new_binding("q", "ctrl+c", help_key: "q", help_desc: "quit")

    @start_key.enabled = false
  end

  def short_help : Array(Crubbletea::Bubbles::Key::Binding)
    [@start_key, @stop_key, @reset_key, @quit_key]
  end

  def full_help : Array(Array(Crubbletea::Bubbles::Key::Binding))
    [[@start_key, @stop_key, @reset_key, @quit_key]]
  end

  def init : Crubbletea::Cmd?
    @timer.init
  end

  def update(msg) : {TimerModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::Bubbles::Timer::TickMsg
      @timer, cmd = @timer.update(msg)
      return {self, cmd}
    when Crubbletea::Bubbles::Timer::StartStopMsg
      @timer, cmd = @timer.update(msg)
      @stop_key.enabled = @timer.running?
      @start_key.enabled = !@timer.running?
      return {self, cmd}
    when Crubbletea::Bubbles::Timer::TimeoutMsg
      @quitting = true
      return {self, Crubbletea.quit}
    when Crubbletea::KeyPressMsg
      key = msg.key
      case
      when Crubbletea::Bubbles::Key.matches(key, @quit_key)
        @quitting = true
        return {self, Crubbletea.quit}
      when Crubbletea::Bubbles::Key.matches(key, @reset_key)
        @timer.reset(5.seconds)
      when Crubbletea::Bubbles::Key.matches(key, @start_key, @stop_key)
        return {self, @timer.toggle}
      end
    end
    {self, nil}
  end

  def view : Crubbletea::View
    s = @timer.view
    if @timer.timedout?
      s = "All done!"
    end
    s += "\n"
    unless @quitting
      help_model = Crubbletea::Bubbles::Help::Model.new(
        width: 60,
        styles: Crubbletea::Bubbles::Help::Styles.new(
          short_key: Crubbletea::Lipgloss::Style.new.bold(true).foreground("#FFD700"),
          short_desc: Crubbletea::Lipgloss::Style.new.foreground("#AAA"),
        ),
      )
      s = "Exiting in " + s
      s += "\n" + help_model.short_help_view(short_help)
    end
    Crubbletea.new_view(s)
  end
end

program = Crubbletea::Program(TimerModel).new(TimerModel.new)
program.run
