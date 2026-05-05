require "../../src/crubbletea"

class MyItem < Crubbletea::Bubbles::List::Item
  getter title : String
  getter description : String

  def initialize(@title : String, @description : String)
  end
end

ITEMS_DATA = [
  {"Apple", "A crunchy red fruit"},
  {"Banana", "A yellow curved fruit"},
  {"Cherry", "A small red fruit"},
  {"Date", "A sweet middle eastern fruit"},
  {"Elderberry", "A dark purple berry"},
  {"Fig", "A sweet teardrop-shaped fruit"},
  {"Grape", "A small round fruit"},
  {"Honeydew", "A sweet green melon"},
  {"Kiwi", "A fuzzy brown fruit"},
  {"Lemon", "A sour yellow citrus"},
  {"Mango", "A tropical stone fruit"},
  {"Nectarine", "A smooth-skinned peach"},
  {"Orange", "A round citrus fruit"},
  {"Papaya", "A tropical orange fruit"},
  {"Quince", "A hard aromatic fruit"},
  {"Raspberry", "A delicate red berry"},
  {"Strawberry", "A sweet red berry"},
  {"Tomato", "A red garden fruit"},
  {"Ugli fruit", "A Jamaican tangelo"},
  {"Watermelon", "A large green melon"},
  {"Yuzu", "A Japanese citrus"},
  {"Zucchini", "A green summer squash"},
  {"Artichoke", "A thistle-like vegetable"},
  {"Broccoli", "A green tree-like vegetable"},
]

ADDITIONAL_SHORT_HELP = [
  Crubbletea::Bubbles::Key::Binding.new(keys: ["enter"], help_key: "enter", help_desc: "choose"),
  Crubbletea::Bubbles::Key::Binding.new(keys: ["x"], help_key: "x", help_desc: "delete"),
] of Crubbletea::Bubbles::Key::Binding

ADDITIONAL_FULL_HELP = [
  [
    Crubbletea::Bubbles::Key::Binding.new(keys: ["enter"], help_key: "enter", help_desc: "choose"),
    Crubbletea::Bubbles::Key::Binding.new(keys: ["x", "backspace"], help_key: "x", help_desc: "delete"),
  ] of Crubbletea::Bubbles::Key::Binding,
  [
    Crubbletea::Bubbles::Key::Binding.new(keys: ["s"], help_key: "s", help_desc: "toggle spinner"),
    Crubbletea::Bubbles::Key::Binding.new(keys: ["a"], help_key: "a", help_desc: "add item"),
    Crubbletea::Bubbles::Key::Binding.new(keys: ["T"], help_key: "T", help_desc: "toggle title"),
    Crubbletea::Bubbles::Key::Binding.new(keys: ["S"], help_key: "S", help_desc: "toggle status"),
    Crubbletea::Bubbles::Key::Binding.new(keys: ["P"], help_key: "P", help_desc: "toggle pagination"),
    Crubbletea::Bubbles::Key::Binding.new(keys: ["H"], help_key: "H", help_desc: "toggle help"),
  ] of Crubbletea::Bubbles::Key::Binding,
] of Array(Crubbletea::Bubbles::Key::Binding)

class ListFancyModel
  include Crubbletea::Model

  getter list : Crubbletea::Bubbles::List::Model
  getter width : Int32
  getter height : Int32

  @status_style : Crubbletea::Lipgloss::Style

  def initialize
    items = ITEMS_DATA.map { |t| MyItem.new(t[0], t[1]).as(Crubbletea::Bubbles::List::Item) }
    @status_style = Crubbletea::Lipgloss::Style.new.foreground("#04B575")
    @list_styles = Crubbletea::Bubbles::List::Styles.new(
      title: Crubbletea::Lipgloss::Style.new
        .background("#25A065").foreground("#FFFDF5").padding(0, 1),
    )
    @list = Crubbletea::Bubbles::List::Model.new(
      items: items,
      width: 40,
      height: 20,
      title: "Groceries",
      styles: @list_styles,
      additional_short_help_keys: ADDITIONAL_SHORT_HELP,
      additional_full_help_keys: ADDITIONAL_FULL_HELP,
    )
    @width = 40
    @height = 20
  end

  def init : Crubbletea::Cmd?
    nil
  end

  private def rebuild_list(title = @list.title, show_status_bar = @list.show_status_bar,
                           show_pagination = @list.show_pagination, show_help = @list.show_help)
    Crubbletea::Bubbles::List::Model.new(
      items: @list.items,
      width: @width - 4,
      height: @height - 4,
      title: title,
      styles: @list_styles,
      show_status_bar: show_status_bar,
      show_pagination: show_pagination,
      show_help: show_help,
      additional_short_help_keys: ADDITIONAL_SHORT_HELP,
      additional_full_help_keys: ADDITIONAL_FULL_HELP,
    )
  end

  def update(msg) : {ListFancyModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::WindowSizeMsg
      @width = msg.width
      @height = msg.height
      @list.set_size(@width - 4, @height - 4)
    when Crubbletea::KeyPressMsg
      unless @list.filtering?
        case msg.key.to_s
        when "enter"
          if sel = @list.selected
            @list.status_message = @status_style.render("You chose #{sel.title}")
          end
        when "x", "backspace"
          if sel = @list.selected
            title = sel.title
            new_items = @list.items.reject { |i| i.title == title }
            @list.items = new_items
            @list.status_message = @status_style.render("Deleted #{title}")
          end
        when "a"
          data = ITEMS_DATA.sample
          new_items = [MyItem.new(data[0], data[1]).as(Crubbletea::Bubbles::List::Item)] + @list.items
          @list.items = new_items
          @list.status_message = @status_style.render("Added #{data[0]}")
        when "T"
          title = @list.title.empty? ? "Groceries" : ""
          @list = rebuild_list(title: title)
        when "S"
          @list = rebuild_list(show_status_bar: !@list.show_status_bar)
        when "P"
          @list = rebuild_list(show_pagination: !@list.show_pagination)
        when "H"
          @list = rebuild_list(show_help: !@list.show_help)
        end
      end
    end

    @list, selected, cmd = @list.update(msg)
    {self, cmd}
  end

  def view : Crubbletea::View
    v = Crubbletea::Lipgloss::Style.new.padding(1, 2, 1, 2).render(@list.view)
    Crubbletea.new_view(v).tap { |view| view.alt_screen = true }
  end
end

program = Crubbletea::Program(ListFancyModel).new(ListFancyModel.new)
program.run
