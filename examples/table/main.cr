require "../../src/crubbletea"

COLUMNS = ["Rank", "City", "Country", "Population"]

TABLE_ROWS = [
  ["1", "Tokyo", "Japan", "37,274,000"],
  ["2", "Delhi", "India", "32,065,760"],
  ["3", "Shanghai", "China", "28,516,904"],
  ["4", "Dhaka", "Bangladesh", "22,478,116"],
  ["5", "São Paulo", "Brazil", "22,429,800"],
  ["6", "Mexico City", "Mexico", "22,085,140"],
  ["7", "Cairo", "Egypt", "21,750,020"],
  ["8", "Beijing", "China", "21,333,332"],
  ["9", "Mumbai", "India", "20,961,472"],
  ["10", "Osaka", "Japan", "19,059,856"],
  ["11", "Chongqing", "China", "16,874,740"],
  ["12", "Karachi", "Pakistan", "16,839,950"],
  ["13", "Istanbul", "Turkey", "15,636,243"],
  ["14", "Kinshasa", "DR Congo", "15,628,085"],
  ["15", "Lagos", "Nigeria", "15,387,639"],
  ["16", "Buenos Aires", "Argentina", "15,369,919"],
  ["17", "Kolkata", "India", "15,133,888"],
  ["18", "Manila", "Philippines", "14,406,059"],
  ["19", "Tianjin", "China", "14,011,828"],
  ["20", "Guangzhou", "China", "13,964,637"],
]

class TableModel
  include Crubbletea::Model

  getter selected_row : Int32
  property selected_city : String?
  getter focused : Bool

  def initialize
    @selected_row = 0
    @selected_city = nil
    @focused = true
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {TableModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case
      when msg.key.code == Crubbletea::Key::Code::Escape
        @focused = !@focused
      when msg.key.code == Crubbletea::Key::Code::Enter
        if TABLE_ROWS[@selected_row]?
          @selected_city = TABLE_ROWS[@selected_row][1]
          return {self, Crubbletea.quit}
        end
      when msg.key.to_s == "ctrl+c", msg.key.to_s == "q"
        return {self, Crubbletea.quit}
      when msg.key.to_s == "up", msg.key.to_s == "k"
        @selected_row -= 1 if @selected_row > 0
      when msg.key.to_s == "down", msg.key.to_s == "j"
        @selected_row += 1 if @selected_row < TABLE_ROWS.size - 1
      end
    end
    {self, nil}
  end

  def view : Crubbletea::View
    base = Crubbletea::Lipgloss::Style.new.padding(0, 1)
    border_fg = @focused ? "240" : "240"

    table = Crubbletea::Lipgloss::TableRenderer.new
      .headers("Rank", "City", "Country", "Population")
      .rows(TABLE_ROWS)
      .border(Crubbletea::Lipgloss::Border.normal)
      .border_style(Crubbletea::Lipgloss::Style.new.foreground(border_fg))
      .border_header(true)
      .style_func(->(row : Int32, col : Int32) : Crubbletea::Lipgloss::Style {
        if row == -1
          base.bold(false)
        elsif row == @selected_row
          base.foreground("229").background("57")
        else
          base
        end
      })

    s = table.render
    s += "\n  ↑/↓: navigate • enter: select • esc: toggle focus • q: quit\n"
    Crubbletea.new_view(s)
  end
end

model = TableModel.new
program = Crubbletea::Program(TableModel).new(model)
program.run

if city = model.selected_city
  puts "Let's go to #{city}!"
end
