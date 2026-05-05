require "./lipgloss"

class Crubbletea::Compositor
  @width : Int32
  @height : Int32
  @layers : Array(Layer)
  @cells : Array(Array(Cell))

  struct Cell
    getter char : Char
    getter style : String

    def initialize(@char : Char = ' ', @style : String = "")
    end
  end

  def initialize(@width : Int32, @height : Int32)
    @layers = [] of Layer
    @cells = Array(Array(Cell)).new(@height) { Array(Cell).new(@width) { Cell.new } }
  end

  def new_layer(content : String, x : Int32 = 0, y : Int32 = 0, z : Int32 = 0, id : String = "") : Layer
    Layer.new(content, x, y, z, id)
  end

  def add_layer(layer : Layer) : Nil
    @layers << layer
  end

  def remove_layer(id : String) : Nil
    @layers.reject! { |l| l.id == id }
  end

  def layer(id : String) : Layer?
    @layers.find { |l| l.id == id }
  end

  def hit(x : Int32, y : Int32) : Layer?
    @layers.select { |l|
      x >= l.x && x < l.x + l.width && y >= l.y && y < l.y + l.height
    }.max_by?(&.z)
  end

  def render : String
    grid = Array(Array(Char)).new(@height) { Array(Char).new(@width, ' ') }
    styled = Array(Array(String)).new(@height) { Array(String).new(@width, "") }

    @layers.sort_by(&.z).each do |layer|
      lines = layer.content.split('\n')
      lines.each_with_index do |line, row|
        cy = layer.y + row
        next if cy < 0 || cy >= @height

        cx = layer.x
        style = ""
        char_idx = 0

        while char_idx < line.size
          c = line[char_idx]
          if c == '\e'
            seq_start = char_idx
            char_idx += 1
            while char_idx < line.size
              sc = line[char_idx]
              char_idx += 1
              if (sc >= 'A' && sc <= 'Z') || (sc >= 'a' && sc <= 'z') || sc == '~'
                break
              end
            end
            style = line[seq_start...char_idx]
            next
          end

          if cx >= 0 && cx < @width
            cw = Crubbletea::Lipgloss::ANSI.char_width(c)
            cw.times do |offset|
              idx = cx + offset
              if idx >= 0 && idx < @width
                grid[cy][idx] = offset == 0 ? c : ' '
                styled[cy][idx] = style
              end
            end
          end
          cx += Crubbletea::Lipgloss::ANSI.char_width(c)
          char_idx += 1
        end
      end
    end

    s = String::Builder.new
    @height.times do |y|
      last_style = ""
      @width.times do |x|
        ch = grid[y][x]
        st = styled[y][x]
        if st != last_style
          s << "\e[0m" if last_style != ""
          s << st
          last_style = st
        end
        s << ch
      end
      if last_style != ""
        s << "\e[0m"
        last_style = ""
      end
      s << '\n' if y < @height - 1
    end
    s.to_s
  end
end

struct Crubbletea::Layer
  getter content : String
  getter x : Int32
  getter y : Int32
  getter z : Int32
  getter id : String
  getter width : Int32
  getter height : Int32

  def initialize(@content : String, @x : Int32 = 0, @y : Int32 = 0, @z : Int32 = 0, @id : String = "")
    lines = @content.split('\n')
    @height = lines.size
    @width = lines.map { |l| Lipgloss::ANSI.string_width(l) }.max
  end
end
