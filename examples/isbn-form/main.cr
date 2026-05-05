require "../../src/crubbletea"

INPUT_STYLE = Crubbletea::Lipgloss::Style.new
  .foreground("#E0A458")
  .width(30)
CONTINUE_STYLE = Crubbletea::Lipgloss::Style.new
  .foreground("#87A96B")
VALID_STYLE = Crubbletea::Lipgloss::Style.new
  .foreground("#6B8E23")
ERR_STYLE = Crubbletea::Lipgloss::Style.new
  .foreground("#DE3163")

BANNED_TITLE_WORDS = %w[very bad words that should not appear in book titles]

def isbn13_validator(s : String) : String?
  s = s.gsub("-", "")
  return "ISBN is of wrong length" if s.size != 13
  return "ISBN contains invalid characters" unless s.each_char.all?(&.number?)
  gs1 = s[0...3]
  return "ISBN has invalid GS1 prefix" unless {"978", "979"}.includes?(gs1)
  sum = s.each_char.with_index.sum { |c, i| (c - '0') * (i.odd? ? 3 : 1) }
  return "ISBN has invalid check digit" if sum % 10 != 0
  nil
end

def book_title_validator(s : String) : String?
  s = s.strip
  return "Book title is empty" if s.empty?
  BANNED_TITLE_WORDS.each do |w|
    return "Book title contains banned word #{w.inspect}" if s.includes?(w)
  end
  nil
end

class IsbnFormModel
  include Crubbletea::Model

  getter isbn_input : Crubbletea::Bubbles::TextInput::Model
  getter title_input : Crubbletea::Bubbles::TextInput::Model
  getter focused_input : Int32
  getter isbn_err : String?
  getter title_err : String?

  def initialize
    @isbn_input = Crubbletea::Bubbles::TextInput::Model.new(
      placeholder: "978-X-XXX-XXXXX-X",
      char_limit: 17,
      width: 30,
      prompt: ""
    )
    @isbn_input.focus

    @title_input = Crubbletea::Bubbles::TextInput::Model.new(
      placeholder: "Title",
      char_limit: 100,
      width: 100,
      prompt: ""
    )

    @focused_input = 0
    @isbn_err = nil
    @title_err = nil
  end

  def can_find_book? : Bool
    val = @isbn_input.value
    return false if val.empty? || isbn13_validator(val)
    tval = @title_input.value
    return false if tval.empty? || book_title_validator(tval)
    true
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {IsbnFormModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "up", "down"
        if @focused_input == 0
          @focused_input = 1
          @title_input.focus
          @isbn_input.blur
        else
          @focused_input = 0
          @isbn_input.focus
          @title_input.blur
        end
      when "enter"
        return {self, Crubbletea.quit} if can_find_book?
      when "ctrl+c", "escape"
        return {self, Crubbletea.quit}
      end
    end

    cmd1 : Crubbletea::Cmd? = nil
    cmd2 : Crubbletea::Cmd? = nil
    @isbn_input, cmd1 = @isbn_input.update(msg)
    @title_input, cmd2 = @title_input.update(msg)

    isbn_val = @isbn_input.value
    @isbn_err = isbn_val.empty? ? nil : isbn13_validator(isbn_val)

    title_val = @title_input.value
    @title_err = title_val.empty? ? nil : book_title_validator(title_val)

    cmds = [cmd1, cmd2].compact.map(&.as(Crubbletea::Cmd))
    {self, cmds.empty? ? nil : Crubbletea.batch(cmds)}
  end

  def view : Crubbletea::View
    continue_text = can_find_book? ? CONTINUE_STYLE.render("Find ->") : ""

    isbn_error = ""
    isbn_val = @isbn_input.value
    if !isbn_val.empty?
      isbn_error = @isbn_err ? ERR_STYLE.render(@isbn_err.not_nil!) : VALID_STYLE.render("Valid ISBN")
    end

    title_error = ""
    title_val = @title_input.value
    if !title_val.empty?
      title_error = @title_err ? ERR_STYLE.render(@title_err.not_nil!) : VALID_STYLE.render("Valid title")
    end

    v = Crubbletea.new_view(
      " Search book:\n" +
      " #{INPUT_STYLE.render("ISBN")}\n" +
      " #{@isbn_input.view}\n" +
      " #{isbn_error}\n" +
      "\n" +
      " #{INPUT_STYLE.render("Title")}\n" +
      " #{@title_input.view}\n" +
      " #{title_error}\n" +
      "\n" +
      " #{continue_text}\n"
    )
    focused = @focused_input == 0 ? @isbn_input : @title_input
    if focused.focused?
      row = @focused_input == 0 ? 2 : 6
      v.cursor = Crubbletea::Cursor.new(2 + focused.visible_cursor_pos, row)
    end
    v
  end
end

program = Crubbletea::Program(IsbnFormModel).new(IsbnFormModel.new)
program.run
