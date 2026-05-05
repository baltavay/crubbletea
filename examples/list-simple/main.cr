require "../../src/crubbletea"

class ListSimpleModel
  include Crubbletea::Model

  getter list : Crubbletea::Bubbles::List::Model
  getter choice : String?
  getter quitting : Bool

  @styles_title : Crubbletea::Lipgloss::Style
  @styles_item : Crubbletea::Lipgloss::Style
  @styles_selected : Crubbletea::Lipgloss::Style
  @styles_pagination : Crubbletea::Lipgloss::Style
  @styles_help : Crubbletea::Lipgloss::Style
  @styles_quit : Crubbletea::Lipgloss::Style

  def initialize
    names = ["Ramen", "Tomato Soup", "Hamburgers", "Cheeseburgers",
             "Currywurst", "Okonomiyaki", "Pasta", "Fillet Mignon",
             "Caviar", "Just Wine"]

    items = names.map_with_index { |name, i|
      Crubbletea::Bubbles::List::StringItem.new("#{i + 1}. #{name}").as(Crubbletea::Bubbles::List::Item)
    }

    @styles_title = Crubbletea::Lipgloss::Style.new.margin(0, 0, 0, 2)
    @styles_item = Crubbletea::Lipgloss::Style.new.padding(0, 0, 0, 4)
    @styles_selected = Crubbletea::Lipgloss::Style.new.padding(0, 0, 0, 2).foreground("170")
    @styles_pagination = Crubbletea::Bubbles::List::Styles.new.pagination.padding(0, 0, 0, 4)
    @styles_help = Crubbletea::Bubbles::List::Styles.new.help.padding(1, 0, 1, 4)
    @styles_quit = Crubbletea::Lipgloss::Style.new.margin(1, 0, 2, 4)

    styles = Crubbletea::Bubbles::List::Styles.new(
      title: @styles_title,
      selected_title: Crubbletea::Lipgloss::Style.new.padding(0, 0, 0, 2).foreground("170"),
      normal_title: Crubbletea::Lipgloss::Style.new.padding(0, 0, 0, 4),
      pagination: @styles_pagination,
      help: @styles_help,
    )

    @list = Crubbletea::Bubbles::List::Model.new(
      items: items,
      width: 20,
      height: 14,
      styles: styles,
      title: "What do you want for dinner?",
      show_status_bar: false,
      filtering_enabled: false,
      item_height: 1,
      item_spacing: 0,
      selected_prefix: "> ",
      normal_prefix: ""
    )
    @choice = nil
    @quitting = false
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {ListSimpleModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::WindowSizeMsg
      @list.set_size(msg.width, 14)
      return {self, nil}
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "q", "ctrl+c"
        @quitting = true
        return {self, Crubbletea.quit}
      when "enter"
        if sel = @list.selected
          @choice = sel.title.sub(/^\d+\.\s*/, "")
          return {self, Crubbletea.quit}
        end
      end
    end

    @list, selected, cmd = @list.update(msg)
    {self, cmd}
  end

  def view : Crubbletea::View
    if c = @choice
      return Crubbletea.new_view(@styles_quit.render("#{c}? Sounds good to me."))
    end
    if @quitting
      return Crubbletea.new_view(@styles_quit.render("Not hungry? That's cool."))
    end
    Crubbletea.new_view("\n" + @list.view)
  end
end

program = Crubbletea::Program(ListSimpleModel).new(ListSimpleModel.new)
program.run
