require "../spec_helper"

describe Crubbletea::Lipgloss do
  describe ".width" do
    it "returns 0 for empty string" do
      Crubbletea::Lipgloss.width("").should eq(0)
    end

    it "returns length for simple string" do
      Crubbletea::Lipgloss.width("hello").should eq(5)
    end

    it "returns max width of multi-line string" do
      Crubbletea::Lipgloss.width("hi\nhello").should eq(5)
    end

    it "excludes ANSI escape codes" do
      Crubbletea::Lipgloss.width("\e[1mhello\e[0m").should eq(5)
    end

    it "measures CJK width correctly" do
      Crubbletea::Lipgloss.width("你好").should eq(4)
    end

    it "measures styled CJK width correctly" do
      Crubbletea::Lipgloss.width("\e[1m你好\e[0m").should eq(4)
    end
  end

  describe ".height" do
    it "returns 0 for empty string" do
      Crubbletea::Lipgloss.height("").should eq(0)
    end

    it "returns 1 for single line" do
      Crubbletea::Lipgloss.height("hello").should eq(1)
    end

    it "counts lines" do
      Crubbletea::Lipgloss.height("a\nb\nc").should eq(3)
    end
  end

  describe ".size" do
    it "returns width and height" do
      w, h = Crubbletea::Lipgloss.size("hi\nhello")
      w.should eq(5)
      h.should eq(2)
    end
  end

  describe ".join_horizontal" do
    it "returns empty for empty array" do
      Crubbletea::Lipgloss.join_horizontal(Crubbletea::Lipgloss::Style::Pos::Top, [] of String).should eq("")
    end

    it "returns single string unchanged" do
      Crubbletea::Lipgloss.join_horizontal(Crubbletea::Lipgloss::Style::Pos::Top, ["A"]).should eq("A")
    end

    it "joins at top (Go port)" do
      result = Crubbletea::Lipgloss.join_horizontal(Crubbletea::Lipgloss::Style::Pos::Top, ["A", "B\nB\nB\nB"])
      result.should eq("AB\n B\n B\n B")
    end

    it "joins at bottom (Go port)" do
      result = Crubbletea::Lipgloss.join_horizontal(Crubbletea::Lipgloss::Style::Pos::Bottom, ["A", "B\nB\nB\nB"])
      result.should eq(" B\n B\n B\nAB")
    end

    it "joins at center (Go port)" do
      result = Crubbletea::Lipgloss.join_horizontal(Crubbletea::Lipgloss::Style::Pos::Center, ["A", "B\nB\nB\nB"])
      result.should eq(" B\nAB\n B\n B")
    end

    it "pads shorter lines to column max width" do
      left = "A\nB"
      right = "XX\nYY"
      result = Crubbletea::Lipgloss.join_horizontal(Crubbletea::Lipgloss::Style::Pos::Top, [left, right])
      lines = result.split('\n')
      lines.size.should eq(2)
      lines[0].should eq("AXX")
      lines[1].should eq("BYY")
    end

    it "all lines have consistent width" do
      left = "hi"
      right = "longer\nline"
      result = Crubbletea::Lipgloss.join_horizontal(Crubbletea::Lipgloss::Style::Pos::Top, [left, right])
      lines = result.split('\n')
      widths = lines.map { |l| Crubbletea::Lipgloss::ANSI.string_width(l) }
      widths.each do |w|
        w.should eq(widths[0])
      end
    end

    it "handles hidden border box + normal border box (regression)" do
      focused = Crubbletea::Lipgloss::Style.new
        .width(15)
        .height(5)
        .align(Crubbletea::Lipgloss::Style::Pos::Center)
        .border(Crubbletea::Lipgloss::Border.normal)

      hidden = Crubbletea::Lipgloss::Style.new
        .width(15)
        .height(5)
        .align(Crubbletea::Lipgloss::Style::Pos::Center)
        .border(Crubbletea::Lipgloss::Border.hidden)

      left = focused.render("hi")
      right = hidden.render("yo")

      result = Crubbletea::Lipgloss.join_horizontal(Crubbletea::Lipgloss::Style::Pos::Top, [left, right])
      lines = result.split('\n')
      widths = lines.map { |l| Crubbletea::Lipgloss::ANSI.string_width(l) }
      widths.each do |w|
        w.should eq(widths[0])
      end
    end
  end

  describe ".join_vertical" do
    it "returns empty for empty array" do
      Crubbletea::Lipgloss.join_vertical(Crubbletea::Lipgloss::Style::Pos::Left, [] of String).should eq("")
    end

    it "returns single string unchanged" do
      Crubbletea::Lipgloss.join_vertical(Crubbletea::Lipgloss::Style::Pos::Left, ["A"]).should eq("A")
    end

    it "joins vertically aligned left (Go port)" do
      result = Crubbletea::Lipgloss.join_vertical(Crubbletea::Lipgloss::Style::Pos::Left, ["A", "BBBB"])
      result.should eq("A   \nBBBB")
    end

    it "joins vertically aligned right (Go port)" do
      result = Crubbletea::Lipgloss.join_vertical(Crubbletea::Lipgloss::Style::Pos::Right, ["A", "BBBB"])
      result.should eq("   A\nBBBB")
    end

    it "joins vertically aligned center (Go port)" do
      result = Crubbletea::Lipgloss.join_vertical(Crubbletea::Lipgloss::Style::Pos::Center, ["A", "BBBB"])
      result.should eq(" A  \nBBBB")
    end
  end
end
