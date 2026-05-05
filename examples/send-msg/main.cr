require "../../src/crubbletea"

FOODS = [
  "an apple", "a pear", "a gherkin", "a party gherkin",
  "a kohlrabi", "some spaghetti", "tacos", "a currywurst", "some curry",
  "a sandwich", "some peanut butter", "some cashews", "some ramen",
]

struct ResultMsg
  include Crubbletea::Msg
  getter food : String
  getter duration : Time::Span

  def initialize(@food : String, @duration : Time::Span)
  end
end

class SendMsgModel
  include Crubbletea::Model

  getter spinner : Crubbletea::Bubbles::Spinner::Model
  getter results : Array(ResultMsg)
  getter quitting : Bool

  def initialize
    @spinner = Crubbletea::Bubbles::Spinner::Model.new(
      spinner: Crubbletea::Bubbles::Spinner::LINE,
      style: Crubbletea::Lipgloss::Style.new.foreground("63")
    )
    @results = Array(ResultMsg).new(5) { ResultMsg.new("...", Time::Span.zero) }
    @quitting = false
  end

  def init : Crubbletea::Cmd?
    @spinner.tick
  end

  def update(msg) : {SendMsgModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      @quitting = true
      return {self, Crubbletea.quit}
    when ResultMsg
      @results.shift
      @results << msg
      return {self, nil}
    when Crubbletea::Bubbles::Spinner::TickMsg
      @spinner, cmd = @spinner.update(msg)
      return {self, cmd}
    end
    {self, nil}
  end

  def view : Crubbletea::View
    app_style = Crubbletea::Lipgloss::Style.new.margin(1, 2, 0, 2)
    help_style = Crubbletea::Lipgloss::Style.new.foreground("#606060").margin(1, 0, 0, 0)
    dot_style = Crubbletea::Lipgloss::Style.new.foreground("#606060")

    b = String::Builder.new

    if @quitting
      b << "That's all for today!"
    else
      b << @spinner.view
      b << " Eating food..."
    end

    b << "\n\n"

    @results.each do |res|
      if res.duration == Time::Span.zero
        b << dot_style.render("." * 30)
      else
        b << "🍔 Ate #{res.food} #{dot_style.render(res.duration.to_s)}"
      end
      b << "\n"
    end

    unless @quitting
      b << help_style.render("Press any key to exit")
    end

    if @quitting
      b << "\n"
    end

    Crubbletea.new_view(app_style.render(b.to_s))
  end
end

m = SendMsgModel.new
program = Crubbletea::Program(SendMsgModel).new(m)

spawn do
  loop do
    pause = Time::Span.new(nanoseconds: Random.rand(899_000_000) + 100_000_000)
    sleep pause
    food = FOODS[Random.rand(FOODS.size)]
    program.send(ResultMsg.new(food, pause))
  end
end

program.run
