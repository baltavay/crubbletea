require "../../src/crubbletea"
require "http/client"
require "file"

struct ProgressMsg
  include Crubbletea::Msg
  getter ratio : Float64

  def initialize(@ratio : Float64)
  end
end

struct ProgressErrMsg
  include Crubbletea::Msg
  getter error : Exception

  def initialize(@error : Exception)
  end
end

struct DownloadDoneMsg
  include Crubbletea::Msg
end

class ProgressDownloadModel
  include Crubbletea::Model

  getter progress : Crubbletea::Bubbles::Progress::Model
  getter err : Exception?
  getter done : Bool

  def initialize
    @progress = Crubbletea::Bubbles::Progress::Model.new
    @err = nil
    @done = false
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {ProgressDownloadModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "escape", "q"
        return {self, Crubbletea.quit}
      end
    when ProgressMsg
      cmd = @progress.set_percent(msg.ratio)
      @done = true if msg.ratio >= 1.0
      return {self, cmd}
    when ProgressErrMsg
      @err = msg.error
    when DownloadDoneMsg
      @done = true
    when Crubbletea::WindowSizeMsg
      @progress.width = msg.width - 4 - 4
      @progress.width = {@progress.width, 80}.min
    when Crubbletea::Bubbles::Progress::FrameMsg
      @progress, cmd = @progress.update(msg)
      return {self, cmd}
    end
    {self, nil}
  end

  def view : Crubbletea::View
    pad = " " * 2
    help_style = Crubbletea::Lipgloss::Style.new.foreground("#626262")
    s = "\n#{pad}#{@progress.view}\n\n#{pad}#{help_style.render("Press any key to quit")}"
    Crubbletea.new_view(s)
  end
end

program = Crubbletea::Program(ProgressDownloadModel).new(ProgressDownloadModel.new)

if ARGV.size < 1 && !Crubbletea.test_mode?
  puts "Usage: crystal examples/progress-download/main.cr -- <url>"
  puts "Example: crystal examples/progress-download/main.cr -- https://example.com/file.zip"
  exit 1
end

url = ARGV[0]? || ""
channel = Channel(Float64).new

spawn do
  begin
      HTTP::Client.get(url) do |response|
        total = response.headers["Content-Length"]?.try(&.to_i) || 0
        downloaded = 0
        File.open("output", "w") do |file|
          buf = Bytes.new(4096)
          loop do
            n = response.body_io.read(buf)
            break if n == 0
            file.write(buf[0...n])
            downloaded += n
            if total > 0
              channel.send(downloaded.to_f / total)
            end
          end
      end
    end
    channel.send(1.0)
  rescue e
    program.send(ProgressErrMsg.new(e).as(Crubbletea::Msg))
  end
end

spawn do
  loop do
    ratio = channel.receive
    program.send(ProgressMsg.new(ratio).as(Crubbletea::Msg))
  end
end

program.run unless Crubbletea.test_mode?
