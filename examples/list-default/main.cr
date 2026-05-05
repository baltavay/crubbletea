require "../../src/crubbletea"

class ListDefaultModel
  include Crubbletea::Model

  getter list : Crubbletea::Bubbles::List::Model
  getter width : Int32
  getter height : Int32

  def initialize
    items = [
      Crubbletea::Bubbles::List::StringItem.new("Raspberry Pi's", "I have 'em all over my house"),
      Crubbletea::Bubbles::List::StringItem.new("Nutella", "It's good on toast"),
      Crubbletea::Bubbles::List::StringItem.new("Bitter melon", "It cools you down"),
      Crubbletea::Bubbles::List::StringItem.new("Nice socks", "And by that I mean socks without holes"),
      Crubbletea::Bubbles::List::StringItem.new("Eight hours of sleep", "I had this once"),
      Crubbletea::Bubbles::List::StringItem.new("Cats", "Usually"),
      Crubbletea::Bubbles::List::StringItem.new("Plantasia, the album", "My plants love it too"),
      Crubbletea::Bubbles::List::StringItem.new("Pour over coffee", "It takes forever to make though"),
      Crubbletea::Bubbles::List::StringItem.new("VR", "Virtual reality...what is there to say?"),
      Crubbletea::Bubbles::List::StringItem.new("Noguchi Lamps", "Such pleasing organic forms"),
      Crubbletea::Bubbles::List::StringItem.new("Linux", "Pretty much the best OS"),
      Crubbletea::Bubbles::List::StringItem.new("Business school", "Just kidding"),
      Crubbletea::Bubbles::List::StringItem.new("Pottery", "Wet clay is a great feeling"),
      Crubbletea::Bubbles::List::StringItem.new("Shampoo", "Nothing like clean hair"),
      Crubbletea::Bubbles::List::StringItem.new("Table tennis", "It's surprisingly exhausting"),
      Crubbletea::Bubbles::List::StringItem.new("Milk crates", "Great for packing in your extra stuff"),
      Crubbletea::Bubbles::List::StringItem.new("Afternoon tea", "Especially the tea sandwich part"),
      Crubbletea::Bubbles::List::StringItem.new("Stickers", "The thicker the vinyl the better"),
      Crubbletea::Bubbles::List::StringItem.new("20° Weather", "Celsius, not Fahrenheit"),
      Crubbletea::Bubbles::List::StringItem.new("Warm light", "Like around 2700 Kelvin"),
      Crubbletea::Bubbles::List::StringItem.new("The vernal equinox", "The autumnal equinox is pretty good too"),
      Crubbletea::Bubbles::List::StringItem.new("Gaffer's tape", "Basically sticky fabric"),
      Crubbletea::Bubbles::List::StringItem.new("Terrycloth", "In other words, towel fabric"),
    ].map(&.as(Crubbletea::Bubbles::List::Item))

    @list = Crubbletea::Bubbles::List::Model.new(
      items: items,
      width: 0,
      height: 0,
      title: "My Fave Things"
    )
    @width = 80
    @height = 24
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {ListDefaultModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      if msg.key.to_s == "ctrl+c"
        return {self, Crubbletea.quit}
      end
    when Crubbletea::WindowSizeMsg
      doc_style = Crubbletea::Lipgloss::Style.new.margin(1, 2, 1, 2)
      h_frame = doc_style.get_horizontal_frame_size
      v_frame = doc_style.get_vertical_frame_size
      @list.set_size(msg.width - h_frame, msg.height - v_frame)
    end

    @list, selected, cmd = @list.update(msg)
    {self, cmd}
  end

  def view : Crubbletea::View
    doc_style = Crubbletea::Lipgloss::Style.new.margin(1, 2, 1, 2)
    v = Crubbletea.new_view(doc_style.render(@list.view))
    v.alt_screen = true
    v
  end
end

program = Crubbletea::Program(ListDefaultModel).new(ListDefaultModel.new)
program.run
