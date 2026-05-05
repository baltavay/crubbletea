require "../spec_helper"

module ExampleTest
  def self.key(key : String) : Crubbletea::KeyPressMsg
    ctrl = false
    alt = false
    rest = key

    if rest.starts_with?("ctrl+")
      ctrl = true
      rest = rest[5..]
    elsif rest.starts_with?("alt+")
      alt = true
      rest = rest[4..]
    end

    code = case rest
    when "up"          then Crubbletea::Key::Code::Up
    when "down"        then Crubbletea::Key::Code::Down
    when "left"        then Crubbletea::Key::Code::Left
    when "right"       then Crubbletea::Key::Code::Right
    when "enter"       then Crubbletea::Key::Code::Enter
    when "backspace"   then Crubbletea::Key::Code::Backspace
    when "tab"         then Crubbletea::Key::Code::Tab
    when "escape"      then Crubbletea::Key::Code::Escape
    when "space"       then Crubbletea::Key::Code::Space
    when "home"        then Crubbletea::Key::Code::Home
    when "end"         then Crubbletea::Key::Code::End
    when "insert"      then Crubbletea::Key::Code::Insert
    when "delete"      then Crubbletea::Key::Code::Delete
    when "pgup"        then Crubbletea::Key::Code::PgUp
    when "pgdown"      then Crubbletea::Key::Code::PgDown
    else                    Crubbletea::Key::Code::Unknown
    end

    k = Crubbletea::Key.new(text: rest, code: code, ctrl: ctrl, alt: alt)
    Crubbletea::KeyPressMsg.new(k)
  end

  def self.window_size(w : Int32, h : Int32) : Crubbletea::WindowSizeMsg
    Crubbletea::WindowSizeMsg.new(w, h)
  end

  def self.step(model, msg)
    model, cmd = model.update(msg)
    cmds = [] of Crubbletea::Cmd
    while cmd
      result = cmd.call
      cmds << ->{ result.as(Crubbletea::Msg) } if result
      model, next_cmd = model.update(result) if result
      cmd = next_cmd
    end
    {model, cmds}
  end

  def self.view_text(model) : String
    model.view.content
  end

  def self.strip_ansi(s : String) : String
    s.gsub(/\e\[[0-9;]*[A-Za-z]/, "")
      .gsub(/\e\][^\e]*\e\\/, "")
      .gsub(/\e\[[0-9;]*[A-Za-z]/, "")
      .gsub(/\e\[\?[0-9]+[hl]/, "")
  end

  def self.assert_view_contains(model, text : String, file = __FILE__, line = __LINE__)
    view_text(model).should contain(text), file: file, line: line
  end

  def self.assert_view_not_contains(model, text : String, file = __FILE__, line = __LINE__)
    view_text(model).should_not contain(text), file: file, line: line
  end

  def self.assert_cursor_at(model, x : Int32, y : Int32, file = __FILE__, line = __LINE__)
    v = model.view
    c = v.cursor
    c.should_not be_nil, "expected cursor at (#{x}, #{y}) but view has no cursor", file: file, line: line
    c = c.not_nil!
    c.position.x.should eq(x), "expected cursor.x=#{x}, got #{c.position.x}", file: file, line: line
    c.position.y.should eq(y), "expected cursor.y=#{y}, got #{c.position.y}", file: file, line: line
  end

  def self.assert_no_cursor(model, file = __FILE__, line = __LINE__)
    model.view.cursor.should be_nil, "expected no cursor but found one", file: file, line: line
  end

  def self.assert_cmd_type(cmd, type : T.class, file = __FILE__, line = __LINE__) forall T
    cmd.should_not be_nil, "expected cmd to produce #{T}, got nil", file: file, line: line
    result = cmd.not_nil!.call
    result.should be_a(T), "expected #{T}, got #{result.class}", file: file, line: line
  end

  def self.assert_cmd_nil(cmd, file = __FILE__, line = __LINE__)
    cmd.should be_nil, "expected nil cmd, got #{cmd.class}", file: file, line: line
  end

  def self.assert_quit(cmd, file = __FILE__, line = __LINE__)
    assert_cmd_type(cmd, Crubbletea::QuitMsg, file: file, line: line)
  end
end
