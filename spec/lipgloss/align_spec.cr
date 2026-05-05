require "../spec_helper"

describe Crubbletea::Lipgloss do
  describe ".place_vertical" do
    it "places single line at top in height 2" do
      result = Crubbletea::Lipgloss.place_vertical(2, Crubbletea::Lipgloss::Style::Pos::Top, "Foo")
      result.split('\n').size.should eq(2)
      result.should start_with("Foo")
    end

    it "places single line at bottom in height 5" do
      result = Crubbletea::Lipgloss.place_vertical(5, Crubbletea::Lipgloss::Style::Pos::Bottom, "Foo")
      lines = result.split('\n')
      lines.size.should eq(5)
      lines.last.should eq("Foo")
    end

    it "places single line at center in height 5" do
      result = Crubbletea::Lipgloss.place_vertical(5, Crubbletea::Lipgloss::Style::Pos::Center, "Foo")
      lines = result.split('\n')
      lines.size.should eq(5)
      lines[2].should eq("Foo")
    end

    it "places 2 lines at bottom in height 5" do
      result = Crubbletea::Lipgloss.place_vertical(5, Crubbletea::Lipgloss::Style::Pos::Bottom, "Foo\nBar")
      lines = result.split('\n')
      lines.size.should eq(5)
      lines[3].should eq("Foo")
      lines[4].should eq("Bar")
    end

    it "places 2 lines at center in height 5" do
      result = Crubbletea::Lipgloss.place_vertical(5, Crubbletea::Lipgloss::Style::Pos::Center, "Foo\nBar")
      lines = result.split('\n')
      lines.size.should eq(5)
      lines[1].should eq("Foo")
      lines[2].should eq("Bar")
    end

    it "places 2 lines at top in height 5" do
      result = Crubbletea::Lipgloss.place_vertical(5, Crubbletea::Lipgloss::Style::Pos::Top, "Foo\nBar")
      lines = result.split('\n')
      lines.size.should eq(5)
      lines[0].should eq("Foo")
      lines[1].should eq("Bar")
    end

    it "places 3 lines at bottom in height 5" do
      result = Crubbletea::Lipgloss.place_vertical(5, Crubbletea::Lipgloss::Style::Pos::Bottom, "Foo\nBar\nBaz")
      lines = result.split('\n')
      lines.size.should eq(5)
      lines[2].should eq("Foo")
      lines[3].should eq("Bar")
      lines[4].should eq("Baz")
    end

    it "places 3 lines at center in height 5" do
      result = Crubbletea::Lipgloss.place_vertical(5, Crubbletea::Lipgloss::Style::Pos::Center, "Foo\nBar\nBaz")
      lines = result.split('\n')
      lines.size.should eq(5)
      lines[1].should eq("Foo")
      lines[2].should eq("Bar")
      lines[3].should eq("Baz")
    end

    it "returns content unchanged when height equals line count (bottom)" do
      result = Crubbletea::Lipgloss.place_vertical(3, Crubbletea::Lipgloss::Style::Pos::Bottom, "Foo\nBar\nBaz")
      lines = result.split('\n')
      lines.size.should eq(3)
      lines[0].should eq("Foo")
      lines[1].should eq("Bar")
      lines[2].should eq("Baz")
    end

    it "returns content unchanged when height equals line count (center)" do
      result = Crubbletea::Lipgloss.place_vertical(3, Crubbletea::Lipgloss::Style::Pos::Center, "Foo\nBar\nBaz")
      lines = result.split('\n')
      lines.size.should eq(3)
      lines[0].should eq("Foo")
    end

    it "returns content unchanged when height equals line count (top)" do
      result = Crubbletea::Lipgloss.place_vertical(3, Crubbletea::Lipgloss::Style::Pos::Top, "Foo\nBar\nBaz")
      lines = result.split('\n')
      lines.size.should eq(3)
      lines[0].should eq("Foo")
    end

    it "handles content with internal blank lines" do
      result = Crubbletea::Lipgloss.place_vertical(5, Crubbletea::Lipgloss::Style::Pos::Bottom, "Foo\n\n\n\nBar")
      lines = result.split('\n')
      lines.size.should eq(5)
      lines[0].should eq("Foo")
      lines[4].should eq("Bar")
    end

    it "centers in odd extra space" do
      result = Crubbletea::Lipgloss.place_vertical(9, Crubbletea::Lipgloss::Style::Pos::Center, "Foo\nBar\nBaz")
      lines = result.split('\n')
      lines.size.should eq(9)
      lines[3].should eq("Foo")
      lines[4].should eq("Bar")
      lines[5].should eq("Baz")
    end

    it "centers in even extra space" do
      result = Crubbletea::Lipgloss.place_vertical(10, Crubbletea::Lipgloss::Style::Pos::Center, "Foo\nBar\nBaz")
      lines = result.split('\n')
      lines.size.should eq(10)
      lines[3].should eq("Foo")
    end
  end

  describe ".place_horizontal" do
    it "places text at left" do
      result = Crubbletea::Lipgloss.place_horizontal(10, Crubbletea::Lipgloss::Style::Pos::Left, "hi")
      Crubbletea::Lipgloss::ANSI.string_width(result).should eq(10)
      result.should start_with("hi")
    end

    it "places text at right" do
      result = Crubbletea::Lipgloss.place_horizontal(10, Crubbletea::Lipgloss::Style::Pos::Right, "hi")
      Crubbletea::Lipgloss::ANSI.string_width(result).should eq(10)
      result.should end_with("hi")
    end

    it "places text at center" do
      result = Crubbletea::Lipgloss.place_horizontal(10, Crubbletea::Lipgloss::Style::Pos::Center, "hi")
      Crubbletea::Lipgloss::ANSI.string_width(result).should eq(10)
    end
  end
end
