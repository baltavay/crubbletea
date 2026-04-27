require "../lipgloss"

class Crubbletea::Bubbles::FilePicker::Model
  getter current_dir : String
  getter width : Int32
  getter height : Int32
  getter cursor : String
  getter style : Lipgloss::Style
  getter selected_style : Lipgloss::Style
  getter dir_style : Lipgloss::Style
  getter allowed_types : Array(String)
  getter show_hidden : Bool

  @files : Array(FileEntry)
  @index : Int32
  @selected_file : String?
  @err : Exception?

  struct FileEntry
    getter name : String
    getter path : String
    getter directory : Bool
    getter size : Int64
    getter hidden : Bool

    def initialize(@name : String, @path : String, @directory : Bool, @size : Int64 = 0, @hidden : Bool = false)
    end
  end

  def initialize(
    @current_dir : String = Dir.current,
    @width : Int32 = 40,
    @height : Int32 = 10,
    @cursor : String = ">",
    @style : Lipgloss::Style = Lipgloss::Style.new,
    @selected_style : Lipgloss::Style = Lipgloss::Style.new.reverse(true),
    @dir_style : Lipgloss::Style = Lipgloss::Style.new.bold(true),
    @allowed_types : Array(String) = [] of String,
    @show_hidden : Bool = false
  )
    @files = [] of FileEntry
    @index = 0
    @selected_file = nil
    @err = nil
    scan_dir
  end

  def files : Array(FileEntry)
    @files
  end

  def index : Int32
    @index
  end

  def selected_file : String?
    @selected_file
  end

  def did_select? : Bool
    !@selected_file.nil?
  end

  def current_dir=(dir : String) : Nil
    if Dir.exists?(dir)
      @current_dir = dir
      @index = 0
      @selected_file = nil
      @err = nil
      scan_dir
    else
      @err = Exception.new("Directory not found: #{dir}")
    end
  end

  def update(msg : Crubbletea::Msg) : {Model, Crubbletea::Cmd}
    case msg
    when Crubbletea::KeyPressMsg
      key = msg.key
      case key.to_s
      when "up", "k"
        @index -= 1 if @index > 0
      when "down", "j"
        @index += 1 if @index < @files.size - 1
      when "enter"
        select_current
      when "backspace", "h"
        go_up
      when "home", "g"
        @index = 0
      when "end", "G"
        @index = {@files.size - 1, 0}.max
      end
    end
    {self, nil}
  end

  def view : String
    parts = [] of String
    parts << @style.render(@current_dir)

    if e = @err
      parts << "Error: #{e.message}"
    end

    visible = [] of String
    start = {@index - @height / 2, 0}.max
    start = {start, {@files.size - @height, 0}.max}.min if @files.size > @height

    (@height).times do |i|
      idx = start + i
      break if idx >= @files.size

      file = @files[idx]
      name = file.directory ? @dir_style.render(file.name + "/") : file.name

      if idx == @index
        visible << @selected_style.render(@cursor + " " + name)
      else
        visible << " " + " " + name
      end
    end

    parts << visible.join('\n')
    parts.join('\n')
  end

  private def select_current : Nil
    file = @files[@index]?
    return unless file

    if file.directory
      self.current_dir = file.path
    else
      if @allowed_types.empty? || @allowed_types.includes?(File.extname(file.name))
        @selected_file = file.path
      end
    end
  end

  private def go_up : Nil
    parent = File.dirname(@current_dir)
    self.current_dir = parent if parent != @current_dir
  end

  private def scan_dir : Nil
    @files = [] of FileEntry
    begin
      entries = Dir.entries(@current_dir).sort
      entries.each do |name|
        next if name == "."
        next if name.starts_with?('.') && !@show_hidden

        path = File.join(@current_dir, name)
        is_dir = Dir.exists?(path)

        if !@allowed_types.empty? && !is_dir
          ext = File.extname(name)
          next unless @allowed_types.includes?(ext)
        end

        size = File.size(path) rescue 0_i64
        hidden = name.starts_with?('.')
        @files << FileEntry.new(name, path, is_dir, size, hidden)
      end

      dirs = @files.select(&.directory).sort_by(&.name.downcase)
      files = @files.reject(&.directory).sort_by(&.name.downcase)
      @files = dirs + files
    rescue ex
      @err = ex
    end
  end
end
