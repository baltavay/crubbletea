require "../../src/crubbletea"

FPS = 60
FREQUENCY = 7.5
DAMPING = 0.15
ASTERISK = "*"

struct FrameMsg
  include Crubbletea::Msg
end

class CellBuffer
  getter cells : Array(String)
  getter stride : Int32

  def initialize(@stride : Int32, height : Int32)
    @cells = Array(String).new(@stride * height, " ")
  end

  def set(x : Int32, y : Int32) : Nil
    i = y * @stride + x
    return if i >= @cells.size || x < 0 || y < 0 || x >= width || y >= height
    @cells[i] = ASTERISK
  end

  def wipe : Nil
    @cells.fill(" ")
  end

  def width : Int32
    @stride
  end

  def height : Int32
    @cells.size // @stride
  end

  def ready? : Bool
    !@cells.empty?
  end

  def to_s : String
    String::Builder.new.tap do |b|
      @cells.each_with_index do |cell, i|
        b << '\n' if i > 0 && i % @stride == 0 && i < @cells.size - 1
        b << cell
      end
    end.to_s
  end
end

def draw_ellipse(cb : CellBuffer, xc : Float64, yc : Float64, rx : Float64, ry : Float64) : Nil
  x = 0.0
  y = ry
  d1 = ry * ry - rx * rx * ry + 0.25 * rx * rx
  dx = 2.0 * ry * ry * x
  dy = 2.0 * rx * rx * y

  while dx < dy
    cb.set((x + xc).to_i, (y + yc).to_i)
    cb.set((-x + xc).to_i, (y + yc).to_i)
    cb.set((x + xc).to_i, (-y + yc).to_i)
    cb.set((-x + xc).to_i, (-y + yc).to_i)
    if d1 < 0
      x += 1
      dx = dx + (2 * ry * ry)
      d1 = d1 + dx + (ry * ry)
    else
      x += 1
      y -= 1
      dx = dx + (2 * ry * ry)
      dy = dy - (2 * rx * rx)
      d1 = d1 + dx - dy + (ry * ry)
    end
  end

  d2 = ((ry * ry) * ((x + 0.5) * (x + 0.5))) + ((rx * rx) * ((y - 1) * (y - 1))) - (rx * rx * ry * ry)

  while y >= 0
    cb.set((x + xc).to_i, (y + yc).to_i)
    cb.set((-x + xc).to_i, (y + yc).to_i)
    cb.set((x + xc).to_i, (-y + yc).to_i)
    cb.set((-x + xc).to_i, (-y + yc).to_i)
    if d2 > 0
      y -= 1
      dy = dy - (2 * rx * rx)
      d2 = d2 + (rx * rx) - dy
    else
      y -= 1
      x += 1
      dx = dx + (2 * ry * ry)
      dy = dy - (2 * rx * rx)
      d2 = d2 + dx - dy + (rx * rx)
    end
  end
end

class CellbufferModel
  include Crubbletea::Model

  getter cells : CellBuffer

  @target_x : Float64
  @target_y : Float64
  @x : Float64
  @y : Float64
  @x_vel : Float64
  @y_vel : Float64

  def initialize
    @cells = CellBuffer.new(0, 0)
    @target_x = 0.0
    @target_y = 0.0
    @x = 0.0
    @y = 0.0
    @x_vel = 0.0
    @y_vel = 0.0
  end

  def init : Crubbletea::Cmd?
    Crubbletea.tick((1.0 / FPS).seconds) { |t| FrameMsg.new.as(Crubbletea::Msg) }
  end

  def update(msg) : {CellbufferModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      return {self, Crubbletea.quit}
    when Crubbletea::WindowSizeMsg
      unless @cells.ready?
        @target_x = msg.width.to_f / 2
        @target_y = msg.height.to_f / 2
        @x = @target_x
        @y = @target_y
      end
      @cells = CellBuffer.new(msg.width, msg.height)
      return {self, nil}
    when Crubbletea::MouseClickMsg, Crubbletea::MouseMotionMsg
      if @cells.ready?
        @target_x = msg.mouse.x.to_f
        @target_y = msg.mouse.y.to_f
      end
    when FrameMsg
      if @cells.ready?
        @cells.wipe

        dx = @target_x - @x
        spring_x = 2.0 * Math::PI * FREQUENCY * dx
        damp_x = 2.0 * DAMPING * Math.sqrt(2.0 * Math::PI * FREQUENCY) * @x_vel
        @x_vel += (spring_x - damp_x) * (1.0 / FPS)
        @x += @x_vel * (1.0 / FPS)

        dy = @target_y - @y
        spring_y = 2.0 * Math::PI * FREQUENCY * dy
        damp_y = 2.0 * DAMPING * Math.sqrt(2.0 * Math::PI * FREQUENCY) * @y_vel
        @y_vel += (spring_y - damp_y) * (1.0 / FPS)
        @y += @y_vel * (1.0 / FPS)

        draw_ellipse(@cells, @x, @y, 16, 8)
      end
      return {self, Crubbletea.tick((1.0 / FPS).seconds) { |t| FrameMsg.new.as(Crubbletea::Msg) }}
    end
    {self, nil}
  end

  def view : Crubbletea::View
    v = Crubbletea.new_view(@cells.to_s)
    v.alt_screen = true
    v.mouse_mode = :cell_motion
    v
  end
end

program = Crubbletea::Program(CellbufferModel).new(CellbufferModel.new)
program.run
