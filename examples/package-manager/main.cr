require "../../src/crubbletea"

struct TickMsg
  include Crubbletea::Msg
end

class PackageManagerModel
  include Crubbletea::Model

  getter spinner : Crubbletea::Bubbles::Spinner::Model
  getter progress : Crubbletea::Bubbles::Progress::Model
  getter packages : Array(String)
  getter index : Int32
  getter width : Int32
  getter height : Int32
  getter done : Bool

  def initialize
    @spinner = Crubbletea::Bubbles::Spinner::Model.new(
      spinner: Crubbletea::Bubbles::Spinner::LINE,
      style: Crubbletea::Lipgloss::Style.new.foreground("63")
    )
    @progress = Crubbletea::Bubbles::Progress::Model.new(width: 40, show_percentage: false)
    @packages = get_packages
    @index = 0
    @width = 80
    @height = 24
    @done = false
  end

  def init : Crubbletea::Cmd?
    Crubbletea.batch([
      download_and_install(@packages[@index]),
      @spinner.tick
    ] of Crubbletea::Cmd)
  end

  struct InstalledPkgMsg
    include Crubbletea::Msg
    getter pkg : String

    def initialize(@pkg : String)
    end
  end

  def update(msg) : {PackageManagerModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::WindowSizeMsg
      @width = msg.width
      @height = msg.height
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "escape", "q"
        return {self, Crubbletea.quit}
      end
    when InstalledPkgMsg
      pkg = @packages[@index]
      if @index >= @packages.size - 1
        @done = true
        return {self, Crubbletea.quit}
      end

      @index += 1
      pct = @index.to_f / @packages.size
      cmds = [
        @progress.set_percent(pct),
        download_and_install(@packages[@index])
      ] of Crubbletea::Cmd
      return {self, Crubbletea.batch(cmds)}
    when Crubbletea::Bubbles::Spinner::TickMsg
      @spinner, cmd = @spinner.update(msg)
      return {self, cmd}
    when Crubbletea::Bubbles::Progress::FrameMsg
      @progress, cmd = @progress.update(msg)
      return {self, cmd}
    end
    {self, nil}
  end

  def view : Crubbletea::View
    n = @packages.size

    if @done
      return Crubbletea.new_view(Crubbletea::Lipgloss::Style.new.margin(1, 2, 1, 2).render("Done! Installed #{n} packages.\n"))
    end

    w = n.to_s.size
    pkg_count = sprintf(" %*d/%*d", w, @index, w, n)

    spin = @spinner.view + " "
    prog = @progress.view

    cells_avail = {@width - Crubbletea::Lipgloss::ANSI.string_width(spin + prog + pkg_count), 0}.max
    pkg_name = Crubbletea::Lipgloss::Style.new.foreground("211").render(@packages[@index])
    info = Crubbletea::Lipgloss::Style.new.max_width(cells_avail).render("Installing #{pkg_name}")

    cells_remaining = {@width - Crubbletea::Lipgloss::ANSI.string_width(spin + info + prog + pkg_count), 0}.max
    gap = " " * cells_remaining

    Crubbletea.new_view(spin + info + gap + prog + pkg_count)
  end

  private def download_and_install(pkg : String) : Crubbletea::Cmd
    ->{
      sleep (Random.new.next_float * 0.5).seconds
      InstalledPkgMsg.new(pkg).as(Crubbletea::Msg)
    }
  end

  private def get_packages : Array(String)
    [
      "lipgloss==0.7.0", "bubbletea==0.25.0", "harmonica==0.2.0",
      "bubbles==0.18.0", "wish==1.2.0", "vhs==0.7.0",
      "skim==0.5.0", "aurora==2.0.0", "okapi==1.0.0",
      "tcell==2.7.0", "termenv==0.15.0", "mad==0.1.0",
    ]
  end
end

program = Crubbletea::Program(PackageManagerModel).new(PackageManagerModel.new)
program.run
