require "../../src/crubbletea"

CONTENT = <<-MD
# Today's Menu

## Appetizers

| Name        | Price | Notes                           |
| ---         | ---   | ---                             |
| Tsukemono   | $2    | Just an appetizer               |
| Tomato Soup | $4    | Made with San Marzano tomatoes  |
| Okonomiyaki | $4    | Takes a few minutes to make     |
| Curry       | $3    | We can add squash if you'd like |

## Seasonal Dishes

| Name                 | Price | Notes              |
| ---                  | ---   | ---                |
| Steamed bitter melon | $2    | Not so bitter      |
| Takoyaki             | $3    | Fun to eat         |
| Winter squash        | $3    | Today it's pumpkin |

## Desserts

| Name         | Price | Notes                 |
| ---          | ---   | ---                   |
| Dorayaki     | $4    | Looks good on rabbits |
| Banana Split | $5    | A classic             |
| Cream Puff   | $3    | Pretty creamy!        |

All our dishes are made in-house by Karen, our chef. Most of our ingredients are from our garden or the fish market down the street.

Some famous people that have eaten here lately:

* [x] René Redzepi
* [x] David Chang
* [ ] Jiro Ono (maybe some day)

Bon appétit!
MD

VIEWPORT_STYLE = Crubbletea::Lipgloss::Style.new
  .border(Crubbletea::Lipgloss::Border.rounded)
  .border_foreground("62")
  .padding(0, 2, 0, 0)

GLAMOUR_HELP_STYLE = Crubbletea::Lipgloss::Style.new.foreground("241")

class GlamourModel
  include Crubbletea::Model

  getter viewport : Crubbletea::Bubbles::Viewport::Model
  getter ready : Bool

  def initialize
    @viewport = Crubbletea::Bubbles::Viewport::Model.new(width: 78, height: 20)
    @ready = false
  end

  def init : Crubbletea::Cmd?
    Crubbletea.request_window_size
  end

  def update(msg) : {GlamourModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "q", "escape"
        return {self, Crubbletea.quit}
      end
    when Crubbletea::WindowSizeMsg
      unless @ready
        @viewport = Crubbletea::Bubbles::Viewport::Model.new(
          width: 78,
          height: 20
        )
        @viewport.content = Crubbletea::Markdown.render(CONTENT, 70)
        @ready = true
      else
        @viewport.width = msg.width
        @viewport.height = msg.height
      end
    end

    @viewport, cmd = @viewport.update(msg)
    {self, cmd}
  end

  def view : Crubbletea::View
    if @ready
      content = VIEWPORT_STYLE.render(@viewport.view) + GLAMOUR_HELP_STYLE.render("\n  ↑/↓: Navigate • q: Quit\n")
      Crubbletea.new_view(content)
    else
      Crubbletea.new_view("Loading...")
    end
  end
end

program = Crubbletea::Program(GlamourModel).new(GlamourModel.new)
program.run
