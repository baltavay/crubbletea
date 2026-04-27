require "math"

module Crubbletea::Ntcharts
  struct Point
    getter x : Int32
    getter y : Int32

    def initialize(@x : Int32 = 0, @y : Int32 = 0)
    end
  end

  struct Float64Point
    getter x : Float64
    getter y : Float64

    def initialize(@x : Float64 = 0.0, @y : Float64 = 0.0)
    end
  end

  BLOCK_CHARS = {' ', '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'}

  BRAILLE_CHARS = {
    {0x01, 0x02, 0x04, 0x40, 0x80}, # top row dots: ⠁⠂⠄⡀⢀
    {0x08, 0x10, 0x20, 0x04, 0x08}, # bottom row dots
  }

  BAR_CHARS = ['▏', '▎', '▍', '▌', '▋', '▊', '▉', '█']
end
