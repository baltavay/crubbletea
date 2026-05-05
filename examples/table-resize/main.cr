require "../../src/crubbletea"

HEADERS = ["#", "NAME", "TYPE 1", "TYPE 2", "JAPANESE", "OFFICIAL ROM."]

TABLE_RESIZE_ROWS = [
  ["1", "Bulbasaur", "Grass", "Poison", "フシギダネ", "Bulbasaur"],
  ["2", "Ivysaur", "Grass", "Poison", "フシギソウ", "Ivysaur"],
  ["3", "Venusaur", "Grass", "Poison", "フシギバナ", "Venusaur"],
  ["4", "Charmander", "Fire", "", "ヒトカゲ", "Hitokage"],
  ["5", "Charmeleon", "Fire", "", "リザード", "Lizardo"],
  ["6", "Charizard", "Fire", "Flying", "リザードン", "Lizardon"],
  ["7", "Squirtle", "Water", "", "ゼニガメ", "Zenigame"],
  ["8", "Wartortle", "Water", "", "カメール", "Kameil"],
  ["9", "Blastoise", "Water", "", "カメックス", "Kamex"],
  ["10", "Caterpie", "Bug", "", "キャタピー", "Caterpie"],
  ["11", "Metapod", "Bug", "", "トランセル", "Trancell"],
  ["12", "Butterfree", "Bug", "Flying", "バタフリー", "Butterfree"],
  ["13", "Weedle", "Bug", "Poison", "ビードル", "Beedle"],
  ["14", "Kakuna", "Bug", "Poison", "コクーン", "Cocoon"],
  ["15", "Beedrill", "Bug", "Poison", "スピアー", "Spear"],
  ["16", "Pidgey", "Normal", "Flying", "ポッポ", "Poppo"],
  ["17", "Pidgeotto", "Normal", "Flying", "ピジョン", "Pigeon"],
  ["18", "Pidgeot", "Normal", "Flying", "ピジョット", "Pigeot"],
  ["19", "Rattata", "Normal", "", "コラッタ", "Koratta"],
  ["20", "Raticate", "Normal", "", "ラッタ", "Ratta"],
  ["21", "Spearow", "Normal", "Flying", "オニスズメ", "Onisuzume"],
  ["22", "Fearow", "Normal", "Flying", "オニドリル", "Onidrill"],
  ["23", "Ekans", "Poison", "", "アーボ", "Arbo"],
  ["24", "Arbok", "Poison", "", "アーボック", "Arbok"],
  ["25", "Pikachu", "Electric", "", "ピカチュウ", "Pikachu"],
  ["26", "Raichu", "Electric", "", "ライチュウ", "Raichu"],
  ["27", "Sandshrew", "Ground", "", "サンド", "Sand"],
  ["28", "Sandslash", "Ground", "", "サンドパン", "Sandpan"],
]

TYPE_COLORS = {
  "Bug"      => "#D7FF87",
  "Electric" => "#FDFF90",
  "Fire"     => "#FF7698",
  "Flying"   => "#FF87D7",
  "Grass"    => "#75FBAB",
  "Ground"   => "#FF875F",
  "Normal"   => "#929292",
  "Poison"   => "#7D5AFC",
  "Water"    => "#00E2C7",
}

DIM_TYPE_COLORS = {
  "Bug"      => "#97AD64",
  "Electric" => "#FCFF5F",
  "Fire"     => "#BA5F75",
  "Flying"   => "#C97AB2",
  "Grass"    => "#59B980",
  "Ground"   => "#C77252",
  "Normal"   => "#727272",
  "Poison"   => "#634BD0",
  "Water"    => "#439F8E",
}

class TableResizeModel
  include Crubbletea::Model

  getter table : Crubbletea::Lipgloss::TableRenderer

  def initialize
    base = Crubbletea::Lipgloss::Style.new.padding(0, 1)
    @table = Crubbletea::Lipgloss::TableRenderer.new
      .headers("#", "NAME", "TYPE 1", "TYPE 2", "JAPANESE", "OFFICIAL ROM.")
      .rows(TABLE_RESIZE_ROWS)
      .border(Crubbletea::Lipgloss::Border.thick)
      .border_style(Crubbletea::Lipgloss::Style.new.foreground("#585858"))
      .style_func(->(row : Int32, col : Int32) : Crubbletea::Lipgloss::Style {
        if row == 0
          base.foreground("#d0d0d0").bold(true)
        elsif row > 0 && row <= TABLE_RESIZE_ROWS.size
          data = TABLE_RESIZE_ROWS[row - 1]
          if data[1] == "Pikachu"
            base.foreground("#01BE85").background("#00432F")
          elsif col == 2 || col == 3
            colors = row.even? ? DIM_TYPE_COLORS : TYPE_COLORS
            cell_val = col < data.size ? data[col] : ""
            if c = colors[cell_val]?
              base.foreground(c)
            else
              row.even? ? base.foreground("#8a8a8a") : base.foreground("#d0d0d0")
            end
          elsif row.even?
            base.foreground("#8a8a8a")
          else
            base.foreground("#d0d0d0")
          end
        else
          base
        end
      })
  end

  def init : Crubbletea::Cmd?
    Crubbletea.request_window_size
  end

  def update(msg) : {TableResizeModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::WindowSizeMsg
      @table = @table.width(msg.width).height(msg.height)
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "q", "ctrl+c"
        return {self, Crubbletea.quit}
      end
    end
    {self, nil}
  end

  def view : Crubbletea::View
    v = Crubbletea.new_view("\n#{@table.render}\n")
    v.alt_screen = true
    v
  end
end

program = Crubbletea::Program(TableResizeModel).new(TableResizeModel.new)
program.run
