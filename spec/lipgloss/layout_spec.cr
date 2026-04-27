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

    it "joins two strings horizontally at top" do
      result = Crubbletea::Lipgloss.join_horizontal(Crubbletea::Lipgloss::Style::Pos::Top, ["A", "B\nB\nB\nB"])
      lines = result.split('\n')
      lines.size.should eq(4)
      lines[0].should contain("A")
      lines[0].should contain("B")
    end

    it "joins two strings horizontally at bottom" do
      result = Crubbletea::Lipgloss.join_horizontal(Crubbletea::Lipgloss::Style::Pos::Bottom, ["A", "B\nB\nB\nB"])
      lines = result.split('\n')
      lines.size.should eq(4)
      lines[-1].should contain("A")
    end

    it "joins two strings horizontally at center" do
      result = Crubbletea::Lipgloss.join_horizontal(Crubbletea::Lipgloss::Style::Pos::Center, ["A", "B\nB\nB\nB"])
      lines = result.split('\n')
      lines.size.should eq(4)
    end
  end

  describe ".join_vertical" do
    it "returns empty for empty array" do
      Crubbletea::Lipgloss.join_vertical(Crubbletea::Lipgloss::Style::Pos::Left, [] of String).should eq("")
    end

    it "returns single string unchanged" do
      Crubbletea::Lipgloss.join_vertical(Crubbletea::Lipgloss::Style::Pos::Left, ["A"]).should eq("A")
    end

    it "joins vertically aligned left" do
      result = Crubbletea::Lipgloss.join_vertical(Crubbletea::Lipgloss::Style::Pos::Left, ["A", "BBBB"])
      result.should eq("A   \nBBBB")
    end

    it "joins vertically aligned right" do
      result = Crubbletea::Lipgloss.join_vertical(Crubbletea::Lipgloss::Style::Pos::Right, ["A", "BBBB"])
      result.should eq("   A\nBBBB")
    end

    it "joins vertically aligned center" do
      result = Crubbletea::Lipgloss.join_vertical(Crubbletea::Lipgloss::Style::Pos::Center, ["A", "BBBB"])
      result.should eq(" A  \nBBBB")
    end
  end
end
