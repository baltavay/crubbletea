require "../../src/crubbletea"

class CanvasModel
  include Crubbletea::Model

  getter compositor : Crubbletea::Compositor
  getter flipped : Bool
  getter width : Int32
  getter height : Int32
  getter quitting : Bool

  @card1 : Crubbletea::Layer?
  @card2 : Crubbletea::Layer?
  @footer : Crubbletea::Layer?

  def initialize
    @compositor = Crubbletea::Compositor.new(80, 24)
    @flipped = false
    @width = 80
    @height = 24
    @quitting = false
  end

  def init : Crubbletea::Cmd?
    Crubbletea.request_window_size
  end

  def update(msg) : {CanvasModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::WindowSizeMsg
      @width = msg.width
      @height = msg.height
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "q", "escape"
        @quitting = true
        return {self, Crubbletea.quit}
      else
        @flipped = !@flipped
      end
    end
    {self, nil}
  end

  def view : Crubbletea::View
    return Crubbletea.new_view("") if @quitting

    z = @flipped ? [1, 0] : [0, 1]

    footer_content = Crubbletea::Lipgloss::Style.new
      .height(13)
      .foreground("102")
      .align_vertical(Crubbletea::Lipgloss::Style::Pos::Bottom)
      .render("Press any key to swap the cards, or q to quit.")

    card_a_content = Crubbletea::Lipgloss::Style.new
      .width(20)
      .height(10)
      .border(Crubbletea::Lipgloss::Border.rounded)
      .border_foreground("175")
      .align_horizontal(Crubbletea::Lipgloss::Style::Pos::Center)
      .align_vertical(Crubbletea::Lipgloss::Style::Pos::Center)
      .render("Hello")

    card_b_content = Crubbletea::Lipgloss::Style.new
      .width(20)
      .height(10)
      .border(Crubbletea::Lipgloss::Border.rounded)
      .border_foreground("175")
      .align_horizontal(Crubbletea::Lipgloss::Style::Pos::Center)
      .align_vertical(Crubbletea::Lipgloss::Style::Pos::Center)
      .render("Goodbye")

    compositor = Crubbletea::Compositor.new(@width, @height)
    compositor.add_layer(Crubbletea::Layer.new(footer_content, 0, 0, 0, "footer"))
    compositor.add_layer(Crubbletea::Layer.new(card_a_content, 0, 0, z[0], "cardA"))
    compositor.add_layer(Crubbletea::Layer.new(card_b_content, 10, 2, z[1], "cardB"))

    v = Crubbletea.new_view(compositor.render)
    v.alt_screen = true
    v
  end
end

program = Crubbletea::Program(CanvasModel).new(CanvasModel.new)
program.run
