require "../../src/crubbletea"

class ClickableModel
  include Crubbletea::Model

  getter compositor : Crubbletea::Compositor
  getter width : Int32
  getter height : Int32
  getter dialogs : Array(Dialog)

  struct Dialog
    getter id : String
    getter x : Int32
    getter y : Int32
    getter title : String

    def initialize(@id : String, @x : Int32, @y : Int32, @title : String)
    end
  end

  @next_id : Int32

  def initialize
    @compositor = Crubbletea::Compositor.new(80, 24)
    @width = 80
    @height = 24
    @dialogs = [] of Dialog
    @next_id = 0
  end

  def init : Crubbletea::Cmd?
    Crubbletea.request_window_size
  end

  def update(msg) : {ClickableModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::WindowSizeMsg
      @width = msg.width
      @height = msg.height
      rebuild
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "q"
        return {self, Crubbletea.quit}
      end
    when Crubbletea::MouseClickMsg
      x = msg.mouse.x
      y = msg.mouse.y

      layer = @compositor.hit(x, y)
      if layer
        if layer.content.includes?("Run Away")
          @dialogs.reject! { |d| d.id == layer.id }
          rebuild
        end
      else
        @next_id += 1
        id = "dialog-#{@next_id}"
        @dialogs << Dialog.new(id, {x - 15, 2}.max, {y - 2, 1}.max, "Dialog #{@next_id}")
        rebuild
      end
    end
    {self, nil}
  end

  def view : Crubbletea::View
    v = Crubbletea.new_view(@compositor.render)
    v.alt_screen = true
    v.mouse_mode = :all_motion
    v
  end

  private def rebuild : Nil
    @compositor = Crubbletea::Compositor.new(@width, @height)

    bg = Crubbletea::Lipgloss::Style.new
      .width(@width - 4)
      .render("Click anywhere to create a dialog. Click 'Run Away' to close.")

    @compositor.add_layer(Crubbletea::Layer.new(bg, 2, @height - 3, 0, "help"))

    @dialogs.each do |dialog|
      content = Crubbletea::Lipgloss::Style.new
        .border(Crubbletea::Lipgloss::Border.rounded)
        .border_foreground("#5f87ff")
        .padding(1, 2)
        .width(30)
        .render("#{dialog.title}\n\n#{Crubbletea::Lipgloss::Style.new.foreground("#ff8700").render("[ Run Away ]")}")

      @compositor.add_layer(Crubbletea::Layer.new(content, dialog.x, dialog.y, 1, dialog.id))
    end
  end
end

program = Crubbletea::Program(ClickableModel).new(ClickableModel.new)
program.run
