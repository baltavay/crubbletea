require "../spec_helper"

describe Crubbletea::Lipgloss::Style do
  describe "#render" do
    it "renders plain text unchanged" do
      style = Crubbletea::Lipgloss::Style.new
      style.render("foo").should eq("foo")
    end

    it "renders bold" do
      style = Crubbletea::Lipgloss::Style.new.bold(true)
      style.render("hello").should eq("\e[1mhello\e[0m")
    end

    it "renders italic" do
      style = Crubbletea::Lipgloss::Style.new.italic(true)
      style.render("hello").should eq("\e[3mhello\e[0m")
    end

    it "renders underline" do
      style = Crubbletea::Lipgloss::Style.new.underline(true)
      style.render("hello").should eq("\e[4mhello\e[0m")
    end

    it "renders blink" do
      style = Crubbletea::Lipgloss::Style.new.blink(true)
      style.render("hello").should eq("\e[5mhello\e[0m")
    end

    it "renders faint" do
      style = Crubbletea::Lipgloss::Style.new.faint(true)
      style.render("hello").should eq("\e[2mhello\e[0m")
    end

    it "renders strikethrough" do
      style = Crubbletea::Lipgloss::Style.new.strikethrough(true)
      style.render("hello").should eq("\e[9mhello\e[0m")
    end

    it "renders reverse" do
      style = Crubbletea::Lipgloss::Style.new.reverse(true)
      style.render("hello").should eq("\e[7mhello\e[0m")
    end

    it "returns empty for empty input without dimensions" do
      style = Crubbletea::Lipgloss::Style.new
      style.render("").should eq("")
    end

    it "renders multiline with style on each line" do
      style = Crubbletea::Lipgloss::Style.new.bold(true)
      result = style.render("hello\nworld")
      result.should eq("\e[1mhello\e[0m\n\e[1mworld\e[0m")
    end

    it "renders inline on single line" do
      style = Crubbletea::Lipgloss::Style.new.bold(true).inline(true)
      result = style.render("hello\nworld")
      result.should contain("\e[1m")
    end
  end

  describe "chaining" do
    it "chains multiple style properties" do
      style = Crubbletea::Lipgloss::Style.new.bold(true).italic(true)
      result = style.render("hi")
      result.should contain("\e[1m")
      result.should contain("\e[3m")
    end

    it "returns new style (immutable)" do
      s1 = Crubbletea::Lipgloss::Style.new
      s2 = s1.bold(true)
      s1.should_not eq(s2)
    end
  end

  describe "padding" do
    it "adds uniform padding" do
      style = Crubbletea::Lipgloss::Style.new.padding(1)
      result = style.render("X")
      lines = result.split('\n')
      lines.size.should eq(3)
      lines[0].should contain(" ")
      lines[1].should contain("X")
      lines[2].should contain(" ")
    end

    it "adds asymmetric padding" do
      style = Crubbletea::Lipgloss::Style.new.padding(0, 3)
      result = style.render("TEST")
      result.should eq("   TEST   ")
    end

    it "getter methods return padding values" do
      style = Crubbletea::Lipgloss::Style.new.padding(1, 2, 3, 4)
      style.get_padding_top.should eq(1)
      style.get_padding_right.should eq(2)
      style.get_padding_bottom.should eq(3)
      style.get_padding_left.should eq(4)
      style.get_horizontal_padding.should eq(6)
      style.get_vertical_padding.should eq(4)
    end
  end

  describe "margin" do
    it "getter methods return margin values" do
      style = Crubbletea::Lipgloss::Style.new.margin(1, 2, 3, 4)
      style.get_margin_top.should eq(1)
      style.get_margin_right.should eq(2)
      style.get_margin_bottom.should eq(3)
      style.get_margin_left.should eq(4)
      style.get_horizontal_margin.should eq(6)
      style.get_vertical_margin.should eq(4)
    end

    it "adds left margin" do
      style = Crubbletea::Lipgloss::Style.new.margin(0, 0, 0, 1)
      result = style.render("foo")
      result.should start_with(" ")
    end

    it "adds right margin" do
      style = Crubbletea::Lipgloss::Style.new.margin(0, 1, 0, 0)
      result = style.render("foo")
      result.should end_with(" ")
    end
  end

  describe "width" do
    it "sets content width" do
      style = Crubbletea::Lipgloss::Style.new.width(20)
      result = style.render("hi")
      Crubbletea::Lipgloss::ANSI.string_width(result).should be >= 20
    end

    it "truncates content wider than width" do
      style = Crubbletea::Lipgloss::Style.new.width(5)
      result = style.render("hello world")
      Crubbletea::Lipgloss::ANSI.string_width(result).should be <= 5
    end

    it "getter returns width" do
      style = Crubbletea::Lipgloss::Style.new.width(42)
      style.get_width.should eq(42)
    end
  end

  describe "height" do
    it "sets content height" do
      style = Crubbletea::Lipgloss::Style.new.height(5)
      result = style.render("hi")
      result.split('\n').size.should eq(5)
    end

    it "getter returns height" do
      style = Crubbletea::Lipgloss::Style.new.height(10)
      style.get_height.should eq(10)
    end
  end

  describe "align" do
    it "aligns right" do
      style = Crubbletea::Lipgloss::Style.new.width(10).align(Crubbletea::Lipgloss::Style::Pos::Right)
      result = style.render("hi")
      Crubbletea::Lipgloss::ANSI.string_width(result).should eq(10)
      result.should start_with(" " * 8)
    end

    it "aligns center" do
      style = Crubbletea::Lipgloss::Style.new.width(10).align(Crubbletea::Lipgloss::Style::Pos::Center)
      result = style.render("hi")
      Crubbletea::Lipgloss::ANSI.string_width(result).should eq(10)
    end
  end

  describe "inherit" do
    it "inherits bold from other" do
      parent = Crubbletea::Lipgloss::Style.new.bold(true)
      child = Crubbletea::Lipgloss::Style.new.inherit(parent)
      child.render("hi").should eq("\e[1mhi\e[0m")
    end

    it "does not override existing properties" do
      parent = Crubbletea::Lipgloss::Style.new.bold(true).italic(true)
      child = Crubbletea::Lipgloss::Style.new.bold(false).italic(true).inherit(parent)
      result = child.render("hi")
      result.should_not contain("\e[1m")
      result.should contain("\e[3m")
    end
  end

  describe "border" do
    it "renders rounded border" do
      border = Crubbletea::Lipgloss::Border.rounded
      style = Crubbletea::Lipgloss::Style.new.border(border)
      result = style.render("hi")
      result.should contain("╭")
      result.should contain("╮")
      result.should contain("╰")
      result.should contain("╯")
      result.should contain("│")
    end

    it "renders normal border" do
      border = Crubbletea::Lipgloss::Border.normal
      style = Crubbletea::Lipgloss::Style.new.border(border)
      result = style.render("hi")
      result.should contain("┌")
      result.should contain("┐")
      result.should contain("└")
      result.should contain("┘")
    end

    it "reports border sides" do
      border = Crubbletea::Lipgloss::Border.normal
      style = Crubbletea::Lipgloss::Style.new.border(border)
      style.has_border_top?.should be_true
      style.has_border_bottom?.should be_true
      style.has_border_left?.should be_true
      style.has_border_right?.should be_true
    end

    it "can disable individual sides" do
      border = Crubbletea::Lipgloss::Border.normal
      style = Crubbletea::Lipgloss::Style.new.border(border).border_top(false)
      style.has_border_top?.should be_false
      style.has_border_bottom?.should be_true
    end

    it "frame size accounts for border and padding" do
      border = Crubbletea::Lipgloss::Border.normal
      style = Crubbletea::Lipgloss::Style.new.border(border).padding(1, 2)
      style.get_horizontal_frame_size.should eq(6)
      style.get_vertical_frame_size.should eq(4)
    end
  end

  describe "foreground/background colors" do
    it "renders foreground with ANSI color name" do
      style = Crubbletea::Lipgloss::Style.new.foreground("red")
      result = style.render("hi")
      result.should contain("\e[31m")
    end

    it "renders foreground with symbol color" do
      style = Crubbletea::Lipgloss::Style.new.foreground(:red)
      result = style.render("hi")
      result.should contain("\e[31m")
    end

    it "renders background with ANSI color name" do
      style = Crubbletea::Lipgloss::Style.new.background("blue")
      result = style.render("hi")
      result.should contain("\e[44m")
    end

    it "renders with 256-color index" do
      style = Crubbletea::Lipgloss::Style.new.foreground("196")
      result = style.render("hi")
      result.should contain("\e[38;5;196m")
    end

    it "getter returns foreground" do
      style = Crubbletea::Lipgloss::Style.new.foreground("red")
      style.get_foreground.should eq("red")
    end

    it "getter returns background" do
      style = Crubbletea::Lipgloss::Style.new.background("blue")
      style.get_background.should eq("blue")
    end
  end

  describe "Border types" do
    it ".normal has correct characters" do
      b = Crubbletea::Lipgloss::Border.normal
      b.top.should eq("─")
      b.left.should eq("│")
      b.top_left.should eq("┌")
    end

    it ".rounded has correct characters" do
      b = Crubbletea::Lipgloss::Border.rounded
      b.top_left.should eq("╭")
      b.top_right.should eq("╮")
    end

    it ".double has correct characters" do
      b = Crubbletea::Lipgloss::Border.double
      b.top.should eq("═")
      b.left.should eq("║")
    end

    it ".thick has correct characters" do
      b = Crubbletea::Lipgloss::Border.thick
      b.top.should eq("━")
      b.left.should eq("┃")
    end

    it ".block has correct characters" do
      b = Crubbletea::Lipgloss::Border.block
      b.top.should eq("█")
    end

    it ".hidden has empty characters" do
      b = Crubbletea::Lipgloss::Border.hidden
      b.top.should eq("")
      b.left.should eq("")
    end
  end
end
