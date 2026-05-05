require "../spec_helper"

describe Crubbletea::Lipgloss do
  describe ".hex_to_rgb" do
    it "parses #FF0000" do
      r, g, b = Crubbletea::Lipgloss.hex_to_rgb("#FF0000")
      r.should eq(255)
      g.should eq(0)
      b.should eq(0)
    end

    it "parses #00FF00" do
      r, g, b = Crubbletea::Lipgloss.hex_to_rgb("#00FF00")
      r.should eq(0)
      g.should eq(255)
      b.should eq(0)
    end

    it "parses #0000FF" do
      r, g, b = Crubbletea::Lipgloss.hex_to_rgb("#0000FF")
      r.should eq(0)
      g.should eq(0)
      b.should eq(255)
    end

    it "parses #FFFFFF" do
      r, g, b = Crubbletea::Lipgloss.hex_to_rgb("#FFFFFF")
      r.should eq(255)
      g.should eq(255)
      b.should eq(255)
    end

    it "parses #000000" do
      r, g, b = Crubbletea::Lipgloss.hex_to_rgb("#000000")
      r.should eq(0)
      g.should eq(0)
      b.should eq(0)
    end

    it "parses #808080" do
      r, g, b = Crubbletea::Lipgloss.hex_to_rgb("#808080")
      r.should eq(128)
      g.should eq(128)
      b.should eq(128)
    end

    it "parses mixed case hex" do
      r, g, b = Crubbletea::Lipgloss.hex_to_rgb("#Ff0000")
      r.should eq(255)
    end

    it "parses lowercase hex" do
      r, g, b = Crubbletea::Lipgloss.hex_to_rgb("#ff0000")
      r.should eq(255)
    end
  end

  describe ".rgb_to_ansi256" do
    it "maps black to 16" do
      Crubbletea::Lipgloss.rgb_to_ansi256(0, 0, 0).should eq(16)
    end

    it "maps white to 231" do
      Crubbletea::Lipgloss.rgb_to_ansi256(255, 255, 255).should eq(231)
    end

    it "maps pure red" do
      idx = Crubbletea::Lipgloss.rgb_to_ansi256(255, 0, 0)
      idx.should be >= 0
      idx.should be <= 255
    end

    it "maps pure green" do
      idx = Crubbletea::Lipgloss.rgb_to_ansi256(0, 255, 0)
      idx.should be >= 0
      idx.should be <= 255
    end

    it "maps pure blue" do
      idx = Crubbletea::Lipgloss.rgb_to_ansi256(0, 0, 255)
      idx.should be <= 255
    end

    it "maps near-black to 16" do
      Crubbletea::Lipgloss.rgb_to_ansi256(5, 5, 5).should eq(16)
    end

    it "maps near-white to 231" do
      Crubbletea::Lipgloss.rgb_to_ansi256(250, 250, 250).should eq(231)
    end
  end

  describe ".foreground" do
    it "returns empty for nil" do
      Crubbletea::Lipgloss.foreground(nil).should eq("")
    end

    it "returns reset for :default" do
      Crubbletea::Lipgloss.foreground(:default).should eq("\e[39m")
    end

    it "handles named ANSI colors" do
      Crubbletea::Lipgloss.foreground("black").should eq("\e[30m")
      Crubbletea::Lipgloss.foreground("red").should eq("\e[31m")
      Crubbletea::Lipgloss.foreground("green").should eq("\e[32m")
      Crubbletea::Lipgloss.foreground("yellow").should eq("\e[33m")
      Crubbletea::Lipgloss.foreground("blue").should eq("\e[34m")
      Crubbletea::Lipgloss.foreground("magenta").should eq("\e[35m")
      Crubbletea::Lipgloss.foreground("cyan").should eq("\e[36m")
      Crubbletea::Lipgloss.foreground("white").should eq("\e[37m")
    end

    it "handles symbol ANSI colors" do
      Crubbletea::Lipgloss.foreground(:red).should eq("\e[31m")
    end

    it "handles 256-color index" do
      Crubbletea::Lipgloss.foreground("196").should eq("\e[38;5;196m")
    end

    it "handles unknown color name" do
      Crubbletea::Lipgloss.foreground("foobar").should eq("")
    end
  end

  describe ".background" do
    it "returns empty for nil" do
      Crubbletea::Lipgloss.background(nil).should eq("")
    end

    it "returns reset for :default" do
      Crubbletea::Lipgloss.background(:default).should eq("\e[49m")
    end

    it "handles named ANSI colors" do
      Crubbletea::Lipgloss.background("black").should eq("\e[40m")
      Crubbletea::Lipgloss.background("red").should eq("\e[41m")
      Crubbletea::Lipgloss.background("blue").should eq("\e[44m")
    end

    it "handles 256-color index" do
      Crubbletea::Lipgloss.background("196").should eq("\e[48;5;196m")
    end
  end

  describe ".ansi_color_code" do
    it "returns code for known ANSI colors" do
      Crubbletea::Lipgloss.ansi_color_code("black").should eq(0)
      Crubbletea::Lipgloss.ansi_color_code("red").should eq(1)
      Crubbletea::Lipgloss.ansi_color_code("green").should eq(2)
      Crubbletea::Lipgloss.ansi_color_code("yellow").should eq(3)
      Crubbletea::Lipgloss.ansi_color_code("blue").should eq(4)
      Crubbletea::Lipgloss.ansi_color_code("magenta").should eq(5)
      Crubbletea::Lipgloss.ansi_color_code("cyan").should eq(6)
      Crubbletea::Lipgloss.ansi_color_code("white").should eq(7)
    end

    it "returns nil for unknown colors" do
      Crubbletea::Lipgloss.ansi_color_code("foobar").should be_nil
    end

    it "handles symbol input" do
      Crubbletea::Lipgloss.ansi_color_code(:red).should eq(1)
    end
  end
end
