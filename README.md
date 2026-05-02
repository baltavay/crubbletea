# crubbletea

> **Work in progress.** Many features are incomplete or broken. Expect bugs, missing functionality, and API changes.

A port of [Bubble Tea](https://github.com/charmbracelet/bubbletea) (Go) to [Crystal](https://crystal-lang.org/) — a framework for building TUIs

This includes ports of the Bubble Tea companion libraries as well:

- **[Bubbles](https://github.com/charmbracelet/bubbles)** → `Crubbletea::Bubbles` — UI components (text input, spinner, progress, list, table, etc.)
- **[Lipgloss](https://github.com/charmbracelet/lipgloss)** → `Crubbletea::Lipgloss` — terminal styling and layout
- **[ntcharts](https://github.com/NimbleMark/ntcharts)** → `Crubbletea::Ntcharts` — data visualization (line charts, bar charts, sparklines, heatmaps)

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     crubbletea:
       github: baltavay/crubbletea
   ```

2. Run `shards install`

## Quick Start

```crystal
require "crubbletea"

class Counter
  include Crubbletea::Model

  @count : Int32

  def initialize(@count = 0)
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg : Crubbletea::Msg) : {Counter, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.code
      when .up?, .k? then {@count += 1, nil}
      when .down?, .j? then {@count -= 1, nil}
      when .q?, .ctrl_c? then {self, Crubbletea.quit}
      else {self, nil}
      end
    else
      {self, nil}
    end
  end

  def view : Crubbletea::View
    Crubbletea.new_view("  Count: #{@count}\n\n  ↑/k increment  ↓/j decrement  q quit")
  end
end

Crubbletea::Program(Counter).new(Counter.new).run
```

## Architecture

Include `Crubbletea::Model` in your class and implement three methods:

| Method    | Signature                          | Description                                    |
|-----------|------------------------------------|------------------------------------------------|
| `init`    | `-> Cmd?`                          | Return initial commands (or `nil`)             |
| `update`  | `Msg -> {Model, Cmd?}`             | Handle a message, return updated model + command |
| `view`    | `-> View`                          | Render the current state as a string view      |

### Messages

Messages are the core event type. Built-in messages include:

- **`KeyPressMsg`** — keyboard input with `Key` struct (code, modifiers)
- **`MouseClickMsg`**, **`MouseReleaseMsg`**, **`MouseWheelMsg`**, **`MouseMotionMsg`** — mouse events
- **`WindowSizeMsg`** — terminal resize (width, height)
- **`QuitMsg`**, **`InterruptMsg`** — program exit signals
- **`FocusMsg`**, **`BlurMsg`**, **`PasteMsg`**, **`ClearScreenMsg`** — other terminal events

Create custom messages by including `Crubbletea::Msg`:

```crystal
struct MyCustomMsg
  include Crubbletea::Msg
  getter data : String

  def initialize(@data : String)
  end
end
```

### Commands

Commands are `Proc(Msg)?` — async operations that produce messages:

```crystal
Crubbletea.tick(1.second) { |t| TickMsg.new }
Crubbletea.every(100.milliseconds) { |t| TickMsg.new }
Crubbletea.batch([cmd1, cmd2, cmd3])
Crubbletea.sequence([cmd1, cmd2])
Crubbletea.quit
Crubbletea.clear_screen
```

### Views

`Crubbletea::View` wraps a string with optional metadata:

```crystal
view = Crubbletea::View.new(
  content: "Hello",
  alt_screen: false,
  cursor: Crubbletea::Cursor.new(x: 5, y: 0),
  window_title: "My App",
  mouse_mode: Crubbletea::MouseMode::CellMotion,
  report_focus: false
)
```

## Lipgloss — Styling & Layout (port of [Lipgloss](https://github.com/charmbracelet/lipgloss))

```crystal
style = Crubbletea::Lipgloss::Style.new
  .bold(true)
  .foreground(Crubbletea::Lipgloss::Color.new(0, 255, 0))
  .background(Crubbletea::Lipgloss::Color.new_hex("#1a1a2e"))
  .padding(1, 2)
  .border(Crubbletea::Lipgloss::Border.new(Crubbletea::Lipgloss::BorderType::Rounded))
  .width(40)
  .align(Crubbletea::Lipgloss::Style::Pos::Center)

styled = style.render("Hello, World!")

# Layout
joined = Crubbletea::Lipgloss.join_horizontal(Crubbletea::Lipgloss::Style::Pos::Center, [left, right])
stacked = Crubbletea::Lipgloss.join_vertical(Crubbletea::Lipgloss::Style::Pos::Center, [top, bottom])
```

### Lipgloss Layout Components

- **`Lipgloss::Table`** — styled tables
- **`Lipgloss::Tree`** — tree views
- **`Lipgloss::List`** — ordered/unordered lists
- **`Lipgloss::Whitespace`** — spacer utility

## Bubbles — UI Components (port of [Bubbles](https://github.com/charmbracelet/bubbles))

| Component | Module | Description |
|-----------|--------|-------------|
| Text Input | `Bubbles::TextInput::Model` | Single-line text input with placeholder, echo modes, cursor |
| Text Area | `Bubbles::TextArea::Model` | Multi-line text editor with line numbers |
| Spinner | `Bubbles::Spinner::Model` | Loading spinner (LINE, DOT, MINI_DOT, PULSE, GLOBE, etc.) |
| Progress | `Bubbles::Progress::Model` | Animated progress bar with spring physics |
| Table | `Bubbles::TableModel` | Selectable data table |
| List | `Bubbles::List::Model` | Filterable, paginated item list |
| Viewport | `Bubbles::Viewport::Model` | Scrollable content area with soft wrap |
| Paginator | `Bubbles::Paginator::Model` | Pagination control |
| Timer | `Bubbles::Timer::Model` | Countdown timer |
| Stopwatch | `Bubbles::Stopwatch::Model` | Stopwatch |
| Help | `Bubbles::Help::Model` | Keybinding help display |
| File Picker | `Bubbles::FilePicker::Model` | File/directory browser |
| Cursor | `Bubbles::Cursor::Model` | Cursor style management |
| Key | `Bubbles::Key::Model` | Key binding helper |

## Ntcharts — Data Visualization (port of [ntcharts](https://github.com/NimbleMark/ntcharts))

- **`Ntcharts::Sparkline`** — inline sparkline charts
- **`Ntcharts::LineChart`** — line charts on a canvas
- **`Ntcharts::BarChart`** — bar charts
- **`Ntcharts::HeatMap`** — heat map visualization
- **`Ntcharts::Canvas`** — braille-based drawing canvas

## Other Utilities

- **`Harmonica`** — spring physics for smooth animations (Spring, Projectile)
- **`Zone`** — screen region tracking for click/mouse handling

## Program Options

```crystal
# With message filter
program = Crubbletea::Program(MyModel).new(model) do |msg|
  # transform or filter messages before update
  msg
end

# Send messages from outside
program.send(CustomMsg.new)

# Graceful shutdown
program.kill
```

## Requirements

- Crystal >= 1.19.1
- Unix-like OS (uses termios for raw terminal mode)

## Development

```bash
git clone https://github.com/baltavay/crubbletea
cd crubbletea
crystal spec
```

## Contributing

1. Fork it (<https://github.com/baltavay/crubbletea/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

MIT — see [LICENSE](LICENSE)

## Contributors

- [Mansurov Maksatbek](https://github.com/baltavay) — creator and maintainer
