require "../../src/crubbletea"

class StopwatchModel
  include Crubbletea::Model
  include Crubbletea::Bubbles::Help::KeyMap

  getter stopwatch : Crubbletea::Bubbles::Stopwatch::Model
  getter quitting : Bool

  @start_key : Crubbletea::Bubbles::Key::Binding
  @stop_key : Crubbletea::Bubbles::Key::Binding
  @reset_key : Crubbletea::Bubbles::Key::Binding
  @quit_key : Crubbletea::Bubbles::Key::Binding

  def initialize
    @stopwatch = Crubbletea::Bubbles::Stopwatch::Model.new(interval: 1.millisecond)
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
    @stopwatch.init
  end

  def update(msg) : {StopwatchModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::Bubbles::Stopwatch::TickMsg
      @stopwatch, cmd = @stopwatch.update(msg)
      return {self, cmd}
    when Crubbletea::Bubbles::Stopwatch::StartStopMsg
      @stopwatch, cmd = @stopwatch.update(msg)
      @stop_key.enabled = @stopwatch.running?
      @start_key.enabled = !@stopwatch.running?
      return {self, cmd}
    when Crubbletea::Bubbles::Stopwatch::ResetMsg
      @stopwatch, cmd = @stopwatch.update(msg)
      return {self, cmd}
    when Crubbletea::KeyPressMsg
      key = msg.key
      case
      when Crubbletea::Bubbles::Key.matches(key, @quit_key)
        @quitting = true
        return {self, Crubbletea.quit}
      when Crubbletea::Bubbles::Key.matches(key, @reset_key)
        return {self, @stopwatch.reset}
      when Crubbletea::Bubbles::Key.matches(key, @start_key, @stop_key)
        @stop_key.enabled = !@stopwatch.running?
        @start_key.enabled = @stopwatch.running?
        return {self, @stopwatch.toggle}
      end
    end
    {self, nil}
  end

  def view : Crubbletea::View
    s = @stopwatch.view + "\n"
    unless @quitting
      help_model = Crubbletea::Bubbles::Help::Model.new(
        width: 60,
        styles: Crubbletea::Bubbles::Help::Styles.new(
          short_key: Crubbletea::Lipgloss::Style.new.bold(true).foreground("#FFD700"),
          short_desc: Crubbletea::Lipgloss::Style.new.foreground("#AAA"),
        ),
      )
      s = "Elapsed: " + s
      s += "\n" + help_model.short_help_view(short_help)
    end
    Crubbletea.new_view(s)
  end
end

program = Crubbletea::Program(StopwatchModel).new(StopwatchModel.new)
program.run
