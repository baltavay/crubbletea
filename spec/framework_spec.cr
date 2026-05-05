require "./spec_helper"

describe "Crubbletea module" do
  it "has VERSION" do
    Crubbletea::VERSION.should eq("0.1.0")
  end

  it "test_mode defaults to false then can be toggled" do
    Crubbletea.test_mode = false
    Crubbletea.test_mode?.should be_false
    Crubbletea.test_mode = true
    Crubbletea.test_mode?.should be_true
    Crubbletea.test_mode = true
  end

  it ".quit returns a Cmd that produces QuitMsg" do
    cmd = Crubbletea.quit
    cmd.should be_a(Proc(Crubbletea::Msg))
    result = cmd.call
    result.should be_a(Crubbletea::QuitMsg)
  end

  it ".interrupt returns a Cmd that produces InterruptMsg" do
    cmd = Crubbletea.interrupt
    cmd.should be_a(Proc(Crubbletea::Msg))
    result = cmd.call
    result.should be_a(Crubbletea::InterruptMsg)
  end

  it ".suspend returns a Cmd that produces SuspendMsg" do
    cmd = Crubbletea.suspend
    cmd.should be_a(Proc(Crubbletea::Msg))
    result = cmd.call
    result.should be_a(Crubbletea::SuspendMsg)
  end

  it ".new_view creates a View with content" do
    v = Crubbletea.new_view("hello")
    v.should be_a(Crubbletea::View)
    v.content.should eq("hello")
    v.alt_screen.should be_false
  end

  it ".printf returns a Cmd with formatted PrintLineMsg" do
    cmd = Crubbletea.printf("value: %d", 42)
    cmd.should be_a(Proc(Crubbletea::Msg))
    result = cmd.call
    result.should be_a(Crubbletea::PrintLineMsg)
    msg = result.as(Crubbletea::PrintLineMsg)
    msg.body.should eq("value: 42")
  end
end

describe "Key struct" do
  it "constructs with defaults" do
    k = Crubbletea::Key.new
    k.text.should eq("")
    k.code.should eq(Crubbletea::Key::Code::Unknown)
    k.ctrl.should be_false
    k.alt.should be_false
    k.shift.should be_false
  end

  it "constructs with text" do
    k = Crubbletea::Key.new(text: "a")
    k.text.should eq("a")
  end

  it "constructs with code" do
    k = Crubbletea::Key.new(code: :enter)
    k.code.should eq(Crubbletea::Key::Code::Enter)
  end

  it "constructs with modifiers" do
    k = Crubbletea::Key.new(text: "c", ctrl: true, alt: true, shift: true)
    k.ctrl.should be_true
    k.alt.should be_true
    k.shift.should be_true
  end

  it ".to_s for plain key text" do
    Crubbletea::Key.new(text: "a").to_s.should eq("a")
  end

  it ".to_s for ctrl key" do
    Crubbletea::Key.new(text: "c", ctrl: true).to_s.should eq("ctrl+c")
  end

  it ".to_s for alt key" do
    Crubbletea::Key.new(text: "j", alt: true).to_s.should eq("alt+j")
  end

  it ".to_s for ctrl+alt+shift key" do
    Crubbletea::Key.new(text: "x", ctrl: true, alt: true, shift: true).to_s.should eq("ctrl+alt+shift+x")
  end

  it ".to_s for arrow keys" do
    Crubbletea::Key.new(code: :up).to_s.should eq("up")
    Crubbletea::Key.new(code: :down).to_s.should eq("down")
    Crubbletea::Key.new(code: :left).to_s.should eq("left")
    Crubbletea::Key.new(code: :right).to_s.should eq("right")
  end

  it ".to_s for special keys" do
    Crubbletea::Key.new(code: :enter).to_s.should eq("enter")
    Crubbletea::Key.new(code: :backspace).to_s.should eq("backspace")
    Crubbletea::Key.new(code: :home).to_s.should eq("home")
    Crubbletea::Key.new(code: :end).to_s.should eq("end")
    Crubbletea::Key.new(code: :delete).to_s.should eq("delete")
    Crubbletea::Key.new(code: :pg_up).to_s.should eq("pgup")
    Crubbletea::Key.new(code: :pg_down).to_s.should eq("pgdown")
    Crubbletea::Key.new(code: :tab).to_s.should eq("tab")
    Crubbletea::Key.new(code: :escape).to_s.should eq("escape")
    Crubbletea::Key.new(code: :space).to_s.should eq("space")
  end

  it ".to_s for function keys" do
    Crubbletea::Key.new(code: :f1).to_s.should eq("f1")
    Crubbletea::Key.new(code: :f2).to_s.should eq("f2")
    Crubbletea::Key.new(code: :f3).to_s.should eq("f3")
    Crubbletea::Key.new(code: :f4).to_s.should eq("f4")
    Crubbletea::Key.new(code: :f5).to_s.should eq("f5")
    Crubbletea::Key.new(code: :f6).to_s.should eq("f6")
    Crubbletea::Key.new(code: :f7).to_s.should eq("f7")
    Crubbletea::Key.new(code: :f8).to_s.should eq("f8")
    Crubbletea::Key.new(code: :f9).to_s.should eq("f9")
    Crubbletea::Key.new(code: :f10).to_s.should eq("f10")
    Crubbletea::Key.new(code: :f11).to_s.should eq("f11")
    Crubbletea::Key.new(code: :f12).to_s.should eq("f12")
  end

  it "equality works" do
    k1 = Crubbletea::Key.new(text: "a", ctrl: true)
    k2 = Crubbletea::Key.new(text: "a", ctrl: true)
    k1.should eq(k2)
  end

  it "inequality works" do
    k1 = Crubbletea::Key.new(text: "a")
    k2 = Crubbletea::Key.new(text: "b")
    k1.should_not eq(k2)
  end
end

describe "KeyPressMsg" do
  it "constructs with key" do
    k = Crubbletea::Key.new(text: "q")
    msg = Crubbletea::KeyPressMsg.new(k)
    msg.key.should eq(k)
  end

  it ".to_s delegates to key" do
    msg = Crubbletea::KeyPressMsg.new(Crubbletea::Key.new(text: "x", ctrl: true))
    msg.to_s.should eq("ctrl+x")
  end

  it "includes Msg" do
    msg = Crubbletea::KeyPressMsg.new(Crubbletea::Key.new)
    msg.is_a?(Crubbletea::Msg).should be_true
  end
end

describe "KeyReleaseMsg" do
  it "constructs with key" do
    k = Crubbletea::Key.new(code: :enter)
    msg = Crubbletea::KeyReleaseMsg.new(k)
    msg.key.should eq(k)
  end

  it ".to_s delegates to key" do
    msg = Crubbletea::KeyReleaseMsg.new(Crubbletea::Key.new(code: :space))
    msg.to_s.should eq("space")
  end

  it "includes Msg" do
    msg = Crubbletea::KeyReleaseMsg.new(Crubbletea::Key.new)
    msg.is_a?(Crubbletea::Msg).should be_true
  end
end

describe "Mouse struct" do
  it "constructs with defaults" do
    m = Crubbletea::Mouse.new
    m.x.should eq(0)
    m.y.should eq(0)
    m.button.should eq(Crubbletea::MouseButton::None)
    m.ctrl.should be_false
    m.alt.should be_false
    m.shift.should be_false
  end

  it "constructs with position and button" do
    m = Crubbletea::Mouse.new(x: 10, y: 20, button: :left)
    m.x.should eq(10)
    m.y.should eq(20)
    m.button.should eq(Crubbletea::MouseButton::Left)
  end

  it "MouseButton enum values" do
    Crubbletea::MouseButton::None.value.should eq(0)
    Crubbletea::MouseButton::Left.value.should eq(1)
    Crubbletea::MouseButton::Middle.value.should eq(2)
    Crubbletea::MouseButton::Right.value.should eq(3)
    Crubbletea::MouseButton::WheelUp.value.should eq(4)
    Crubbletea::MouseButton::WheelDown.value.should eq(5)
    Crubbletea::MouseButton::WheelLeft.value.should eq(6)
    Crubbletea::MouseButton::WheelRight.value.should eq(7)
  end

  it ".to_s formats correctly" do
    m = Crubbletea::Mouse.new(x: 5, y: 3, button: :left, ctrl: true)
    s = m.to_s
    s.should contain("ctrl")
    s.should contain("left")
    s.should contain("5,3")
  end
end

describe "Mouse messages" do
  it "MouseClickMsg" do
    m = Crubbletea::Mouse.new(x: 1, y: 2, button: :left)
    msg = Crubbletea::MouseClickMsg.new(m)
    msg.mouse.should eq(m)
    msg.to_s.should eq("click: #{m}")
    msg.is_a?(Crubbletea::Msg).should be_true
  end

  it "MouseReleaseMsg" do
    m = Crubbletea::Mouse.new(x: 3, y: 4, button: :right)
    msg = Crubbletea::MouseReleaseMsg.new(m)
    msg.mouse.should eq(m)
    msg.to_s.should eq("release: #{m}")
    msg.is_a?(Crubbletea::Msg).should be_true
  end

  it "MouseWheelMsg" do
    m = Crubbletea::Mouse.new(x: 0, y: 0, button: :wheel_up)
    msg = Crubbletea::MouseWheelMsg.new(m)
    msg.mouse.should eq(m)
    msg.to_s.should eq("wheel: #{m}")
    msg.is_a?(Crubbletea::Msg).should be_true
  end

  it "MouseMotionMsg" do
    m = Crubbletea::Mouse.new(x: 10, y: 10, button: :none)
    msg = Crubbletea::MouseMotionMsg.new(m)
    msg.mouse.should eq(m)
    msg.to_s.should eq("motion: #{m}")
    msg.is_a?(Crubbletea::Msg).should be_true
  end
end

describe "Msg types" do
  it "FocusMsg" do
    msg = Crubbletea::FocusMsg.new
    msg.is_a?(Crubbletea::Msg).should be_true
  end

  it "BlurMsg" do
    msg = Crubbletea::BlurMsg.new
    msg.is_a?(Crubbletea::Msg).should be_true
  end

  it "QuitMsg" do
    msg = Crubbletea::QuitMsg.new
    msg.is_a?(Crubbletea::Msg).should be_true
  end

  it "InterruptMsg" do
    msg = Crubbletea::InterruptMsg.new
    msg.is_a?(Crubbletea::Msg).should be_true
  end

  it "WindowSizeMsg" do
    msg = Crubbletea::WindowSizeMsg.new(120, 40)
    msg.width.should eq(120)
    msg.height.should eq(40)
    msg.is_a?(Crubbletea::Msg).should be_true
  end

  it "SuspendMsg" do
    msg = Crubbletea::SuspendMsg.new
    msg.is_a?(Crubbletea::Msg).should be_true
  end

  it "ResumeMsg" do
    msg = Crubbletea::ResumeMsg.new
    msg.is_a?(Crubbletea::Msg).should be_true
  end

  it "ClearScreenMsg" do
    msg = Crubbletea::ClearScreenMsg.new
    msg.is_a?(Crubbletea::Msg).should be_true
  end

  it "PrintLineMsg" do
    msg = Crubbletea::PrintLineMsg.new("hello world")
    msg.body.should eq("hello world")
    msg.is_a?(Crubbletea::Msg).should be_true
  end

  it "BatchMsg" do
    cmds = [Crubbletea.quit, Crubbletea.interrupt].map(&.as(Proc(Crubbletea::Msg)))
    msg = Crubbletea::BatchMsg.new(cmds)
    msg.cmds.size.should eq(2)
    msg.is_a?(Crubbletea::Msg).should be_true
  end

  it "SequenceMsg" do
    cmds = [Crubbletea.quit, Crubbletea.suspend].map(&.as(Proc(Crubbletea::Msg)))
    msg = Crubbletea::SequenceMsg.new(cmds)
    msg.cmds.size.should eq(2)
    msg.is_a?(Crubbletea::Msg).should be_true
  end

  it "EscapePendingMsg" do
    msg = Crubbletea::EscapePendingMsg.new
    msg.is_a?(Crubbletea::Msg).should be_true
  end

  it "FlushRenderMsg" do
    msg = Crubbletea::FlushRenderMsg.new
    msg.is_a?(Crubbletea::Msg).should be_true
  end

  it "CapabilityMsg" do
    msg = Crubbletea::CapabilityMsg.new("kitty", "yes")
    msg.name.should eq("kitty")
    msg.value.should eq("yes")
    msg.is_a?(Crubbletea::Msg).should be_true
  end

  it "KeyboardEnhancementsMsg" do
    msg = Crubbletea::KeyboardEnhancementsMsg.new(true)
    msg.supported.should be_true
    msg.is_a?(Crubbletea::Msg).should be_true
  end

  it "KeyboardEnhancementsMsg defaults" do
    msg = Crubbletea::KeyboardEnhancementsMsg.new
    msg.supported.should be_false
  end

  it "MouseMode enum" do
    Crubbletea::MouseMode::None.value.should eq(0)
    Crubbletea::MouseMode::CellMotion.value.should eq(1)
    Crubbletea::MouseMode::AllMotion.value.should eq(2)
  end

  it "PasteMsg" do
    msg = Crubbletea::PasteMsg.new("clipboard text")
    msg.content.should eq("clipboard text")
    msg.to_s.should eq("clipboard text")
  end

  it "CursorPositionMsg" do
    msg = Crubbletea::CursorPositionMsg.new(5, 10)
    msg.x.should eq(5)
    msg.y.should eq(10)
  end

  it "ExecFinishedMsg without error" do
    msg = Crubbletea::ExecFinishedMsg.new
    msg.err.should be_nil
  end

  it "ExecFinishedMsg with error" do
    err = Exception.new("boom")
    msg = Crubbletea::ExecFinishedMsg.new(err)
    msg.err.should eq(err)
  end

  it "BackgroundColorMsg" do
    msg = Crubbletea::BackgroundColorMsg.new("#FFFFFF")
    msg.hex.should eq("#FFFFFF")
    msg.dark?.should be_false
  end

  it "BackgroundColorMsg dark detection" do
    msg = Crubbletea::BackgroundColorMsg.new("#000000")
    msg.dark?.should be_true
  end

  it "ColorProfileMsg" do
    msg = Crubbletea::ColorProfileMsg.new(:truecolor)
    msg.profile.should eq(:truecolor)
  end
end

describe "View struct" do
  it "new_view creates a View" do
    v = Crubbletea.new_view("hello")
    v.content.should eq("hello")
  end

  it "has content property" do
    v = Crubbletea::View.new("test content")
    v.content.should eq("test content")
    v.content = "new content"
    v.content.should eq("new content")
  end

  it "alt_screen defaults to false and can be set" do
    v = Crubbletea::View.new("x")
    v.alt_screen.should be_false
    v.alt_screen = true
    v.alt_screen.should be_true
  end

  it "window_title defaults to empty and can be set" do
    v = Crubbletea::View.new("x")
    v.window_title.should eq("")
    v.window_title = "My App"
    v.window_title.should eq("My App")
  end

  it "cursor defaults to nil and can be set" do
    v = Crubbletea::View.new("x")
    v.cursor.should be_nil
    c = Crubbletea::Cursor.new(5, 3)
    v.cursor = c
    v.cursor.should eq(c)
  end

  it "mouse_mode defaults to none and can be set" do
    v = Crubbletea::View.new("x")
    v.mouse_mode.should eq(Crubbletea::MouseMode::None)
    v.mouse_mode = Crubbletea::MouseMode::CellMotion
    v.mouse_mode.should eq(Crubbletea::MouseMode::CellMotion)
  end

  it "report_focus defaults to false and can be set" do
    v = Crubbletea::View.new("x")
    v.report_focus.should be_false
    v.report_focus = true
    v.report_focus.should be_true
  end

  it "progress_bar can be set" do
    v = Crubbletea::View.new("x")
    v.progress_bar.should be_nil
    pb = Crubbletea::ProgressBar.new(1, 50)
    v.progress_bar = pb
    v.progress_bar.should_not be_nil
    v.progress_bar.not_nil!.state.should eq(1)
    v.progress_bar.not_nil!.value.should eq(50)
  end

  it "keyboard_enhancements can be set" do
    v = Crubbletea::View.new("x")
    v.keyboard_enhancements.should be_nil
    ke = Crubbletea::KeyboardEnhancements.new(true)
    v.keyboard_enhancements = ke
    v.keyboard_enhancements.should_not be_nil
    v.keyboard_enhancements.not_nil!.report_event_types.should be_true
  end

  it "foreground_color and background_color can be set" do
    v = Crubbletea::View.new("x")
    v.foreground_color.should eq("")
    v.foreground_color = "#FFFFFF"
    v.foreground_color.should eq("#FFFFFF")
    v.background_color = "#000000"
    v.background_color.should eq("#000000")
  end
end

describe "Cursor struct" do
  it "Position constructs with x, y" do
    p = Crubbletea::Position.new(5, 10)
    p.x.should eq(5)
    p.y.should eq(10)
  end

  it "Position defaults to 0,0" do
    p = Crubbletea::Position.new
    p.x.should eq(0)
    p.y.should eq(0)
  end

  it "CursorShape enum values" do
    Crubbletea::CursorShape::Block.value.should eq(0)
    Crubbletea::CursorShape::Underline.value.should eq(1)
    Crubbletea::CursorShape::Bar.value.should eq(2)
  end

  it "Cursor defaults to position 0,0 block blink" do
    c = Crubbletea::Cursor.new
    c.position.x.should eq(0)
    c.position.y.should eq(0)
    c.shape.should eq(Crubbletea::CursorShape::Block)
    c.blink.should be_true
  end

  it "Cursor.new with position" do
    c = Crubbletea::Cursor.new(Crubbletea::Position.new(3, 7))
    c.position.x.should eq(3)
    c.position.y.should eq(7)
  end

  it "Cursor.new with x, y" do
    c = Crubbletea::Cursor.new(4, 9)
    c.position.x.should eq(4)
    c.position.y.should eq(9)
  end

  it "Cursor.new with x, y, shape, blink" do
    c = Crubbletea::Cursor.new(2, 5, :underline, false)
    c.position.x.should eq(2)
    c.position.y.should eq(5)
    c.shape.should eq(Crubbletea::CursorShape::Underline)
    c.blink.should be_false
  end
end

describe "Commands" do
  it ".clear_screen cmd returns ClearScreenMsg" do
    cmd = Crubbletea.clear_screen
    cmd.call.should be_a(Crubbletea::ClearScreenMsg)
  end

  it ".request_window_size cmd returns WindowSizeMsg" do
    cmd = Crubbletea.request_window_size
    cmd.call.should be_a(Crubbletea::WindowSizeMsg)
  end

  it ".batch with multiple cmds returns BatchMsg" do
    cmds = [Crubbletea.quit, Crubbletea.interrupt].map(&.as(Crubbletea::Cmd))
    cmd = Crubbletea.batch(cmds)
    cmd.should_not be_nil
    result = cmd.not_nil!.call
    result.should be_a(Crubbletea::BatchMsg)
    batch = result.as(Crubbletea::BatchMsg)
    batch.cmds.size.should eq(2)
  end

  it ".batch with single cmd returns that cmd directly" do
    cmds = [Crubbletea.quit].map(&.as(Crubbletea::Cmd))
    cmd = Crubbletea.batch(cmds)
    cmd.should_not be_nil
    result = cmd.not_nil!.call
    result.should be_a(Crubbletea::QuitMsg)
  end

  it ".batch with empty cmds returns nil" do
    cmds = [] of Crubbletea::Cmd
    cmd = Crubbletea.batch(cmds)
    cmd.should be_nil
  end

  it ".sequence with multiple cmds returns SequenceMsg" do
    cmds = [Crubbletea.quit, Crubbletea.suspend].map(&.as(Crubbletea::Cmd))
    cmd = Crubbletea.sequence(cmds)
    cmd.should_not be_nil
    result = cmd.not_nil!.call
    result.should be_a(Crubbletea::SequenceMsg)
    seq = result.as(Crubbletea::SequenceMsg)
    seq.cmds.size.should eq(2)
  end

  it ".sequence with single cmd returns that cmd directly" do
    cmds = [Crubbletea.interrupt].map(&.as(Crubbletea::Cmd))
    cmd = Crubbletea.sequence(cmds)
    cmd.should_not be_nil
    result = cmd.not_nil!.call
    result.should be_a(Crubbletea::InterruptMsg)
  end

  it ".sequence with empty cmds returns nil" do
    cmds = [] of Crubbletea::Cmd
    cmd = Crubbletea.sequence(cmds)
    cmd.should be_nil
  end

  it ".tick returns cmd that calls block" do
    cmd = Crubbletea.tick(1.millisecond) { |t| Crubbletea::QuitMsg.new.as(Crubbletea::Msg) }
    result = cmd.call
    result.should be_a(Crubbletea::QuitMsg)
  end

  it ".tick passes Time to block" do
    captured = nil.as(Time?)
    cmd = Crubbletea.tick(1.millisecond) { |t| captured = t; Crubbletea::QuitMsg.new.as(Crubbletea::Msg) }
    cmd.call
    captured.should_not be_nil
  end

  it ".exec_process cmd returns ExecFinishedMsg" do
    cmd = Crubbletea.exec_process("true")
    result = cmd.call
    result.should be_a(Crubbletea::ExecFinishedMsg)
  end
end

describe "Renderer" do
  it "constructs with IO" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    r.should_not be_nil
  end

  it "constructs with custom width/height" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io, 120, 40)
    r.should_not be_nil
  end

  it "render hides cursor on inline first render" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    v = Crubbletea.new_view("hello\n")
    r.render(v)
    output = io.to_s
    output.should contain("\e[?25l")
  end

  it "render writes content lines" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    v = Crubbletea.new_view("line1\nline2\n")
    r.render(v)
    output = io.to_s
    output.should contain("line1")
    output.should contain("line2")
  end

  it "render skips identical views" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    v1 = Crubbletea.new_view("same\n")
    r.render(v1)
    io.clear
    v2 = Crubbletea.new_view("same\n")
    r.render(v2)
    io.to_s.empty?.should be_true
  end

  it "force_render re-renders even identical view" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    v = Crubbletea.new_view("hello\n")
    r.render(v)
    io.clear
    r.force_render(v)
    io.to_s.size.should be > 0
  end

  it "render enters alt screen" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    v = Crubbletea.new_view("alt content\n")
    v.alt_screen = true
    r.render(v)
    output = io.to_s
    output.should contain("\e[?1049h")
  end

  it "render exits alt screen when switching back" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    v_alt = Crubbletea.new_view("alt\n")
    v_alt.alt_screen = true
    r.render(v_alt)
    io.clear
    v_inline = Crubbletea.new_view("inline\n")
    r.render(v_inline)
    output = io.to_s
    output.should contain("\e[?1049l")
  end

  it "render applies cursor style for block blink" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    c = Crubbletea::Cursor.new(0, 0, :block, true)
    v = Crubbletea.new_view("hi\n")
    v.cursor = c
    r.render(v)
    output = io.to_s
    output.should contain("\e[1 q")
    output.should contain("\e[?25h")
  end

  it "render applies cursor style for block no blink" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    c = Crubbletea::Cursor.new(0, 0, :block, false)
    v = Crubbletea.new_view("hi\n")
    v.cursor = c
    r.render(v)
    output = io.to_s
    output.should contain("\e[2 q")
  end

  it "render applies cursor style for underline blink" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    c = Crubbletea::Cursor.new(0, 0, :underline, true)
    v = Crubbletea.new_view("hi\n")
    v.cursor = c
    r.render(v)
    output = io.to_s
    output.should contain("\e[3 q")
  end

  it "render applies cursor style for underline no blink" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    c = Crubbletea::Cursor.new(0, 0, :underline, false)
    v = Crubbletea.new_view("hi\n")
    v.cursor = c
    r.render(v)
    output = io.to_s
    output.should contain("\e[4 q")
  end

  it "render applies cursor style for bar blink" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    c = Crubbletea::Cursor.new(0, 0, :bar, true)
    v = Crubbletea.new_view("hi\n")
    v.cursor = c
    r.render(v)
    output = io.to_s
    output.should contain("\e[5 q")
  end

  it "render applies cursor style for bar no blink" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    c = Crubbletea::Cursor.new(0, 0, :bar, false)
    v = Crubbletea.new_view("hi\n")
    v.cursor = c
    r.render(v)
    output = io.to_s
    output.should contain("\e[6 q")
  end

  it "render sets window title" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    v = Crubbletea.new_view("hi\n")
    v.window_title = "Test Title"
    r.render(v)
    output = io.to_s
    output.should contain("\e]0;Test Title\e\\")
  end

  it "render enables mouse cell motion" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    v = Crubbletea.new_view("hi\n")
    v.mouse_mode = Crubbletea::MouseMode::CellMotion
    r.render(v)
    output = io.to_s
    output.should contain("\e[?1000h")
    output.should contain("\e[?1006h")
  end

  it "render enables mouse all motion" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    v = Crubbletea.new_view("hi\n")
    v.mouse_mode = Crubbletea::MouseMode::AllMotion
    r.render(v)
    output = io.to_s
    output.should contain("\e[?1003h")
    output.should contain("\e[?1006h")
  end

  it "render disables mouse when switching from cell to none" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    v1 = Crubbletea.new_view("hi\n")
    v1.mouse_mode = Crubbletea::MouseMode::CellMotion
    r.render(v1)
    io.clear
    v2 = Crubbletea.new_view("hi2\n")
    v2.mouse_mode = Crubbletea::MouseMode::None
    r.render(v2)
    output = io.to_s
    output.should contain("\e[?1000l")
  end

  it "render enables focus reporting" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    v = Crubbletea.new_view("hi\n")
    v.report_focus = true
    r.render(v)
    output = io.to_s
    output.should contain("\e[?1004h")
  end

  it "render sets progress bar" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    v = Crubbletea.new_view("hi\n")
    v.progress_bar = Crubbletea::ProgressBar.new(1, 75)
    r.render(v)
    output = io.to_s
    output.should contain("\e]9;4;1;75\e\\")
  end

  it "render enables kitty keyboard" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    v = Crubbletea.new_view("hi\n")
    v.keyboard_enhancements = Crubbletea::KeyboardEnhancements.new(true)
    r.render(v)
    output = io.to_s
    output.should contain("\e[?1u")
  end

  it "resize updates dimensions" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io, 80, 24)
    r.resize(120, 40)
    v = Crubbletea::View.new("x\n")
    v.alt_screen = true
    r.render(v)
  end

  it "close shows cursor and resets style" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    v = Crubbletea.new_view("hi\n")
    r.render(v)
    r.close
    output = io.to_s
    output.should contain("\e[0 q")
    output.should contain("\e[?25h")
  end

  it "close exits alt screen if active" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    v = Crubbletea.new_view("hi\n")
    v.alt_screen = true
    r.render(v)
    io.clear
    r.close
    output = io.to_s
    output.should contain("\e[?1049l")
  end

  it "close disables mouse if active" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    v = Crubbletea.new_view("hi\n")
    v.mouse_mode = Crubbletea::MouseMode::AllMotion
    r.render(v)
    io.clear
    r.close
    output = io.to_s
    output.should contain("\e[?1000l")
  end

  it "close clears window title if set" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    v = Crubbletea.new_view("hi\n")
    v.window_title = "Title"
    r.render(v)
    io.clear
    r.close
    output = io.to_s
    output.should contain("\e]0;\e\\")
  end

  it "render sets foreground color" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    v = Crubbletea.new_view("hi\n")
    v.foreground_color = "#FF0000"
    r.render(v)
    output = io.to_s
    output.should contain("\e]10;#FF0000\e\\")
  end

  it "render sets background color" do
    io = IO::Memory.new
    r = Crubbletea::Renderer.new(io)
    v = Crubbletea.new_view("hi\n")
    v.background_color = "#000000"
    r.render(v)
    output = io.to_s
    output.should contain("\e]11;#000000\e\\")
  end
end

describe "ANSI module" do
  it ".cursor_up" do
    Crubbletea::ANSI.cursor_up(3).should eq("\e[3A")
  end

  it ".cursor_up returns empty for non-positive" do
    Crubbletea::ANSI.cursor_up(0).should eq("")
  end

  it ".cursor_down" do
    Crubbletea::ANSI.cursor_down(2).should eq("\e[2B")
  end

  it ".cursor_down returns empty for non-positive" do
    Crubbletea::ANSI.cursor_down(-1).should eq("")
  end

  it ".cursor_right" do
    Crubbletea::ANSI.cursor_right(5).should eq("\e[5C")
  end

  it ".cursor_left" do
    Crubbletea::ANSI.cursor_left(4).should eq("\e[4D")
  end

  it ".cursor_move uses 1-based coordinates" do
    Crubbletea::ANSI.cursor_move(0, 0).should eq("\e[1;1H")
    Crubbletea::ANSI.cursor_move(5, 10).should eq("\e[11;6H")
  end

  it ".hide_cursor" do
    Crubbletea::ANSI.hide_cursor.should eq("\e[?25l")
  end

  it ".show_cursor" do
    Crubbletea::ANSI.show_cursor.should eq("\e[?25h")
  end

  it ".erase_line_right" do
    Crubbletea::ANSI.erase_line_right.should eq("\e[K")
  end

  it ".clear_line" do
    Crubbletea::ANSI.clear_line.should eq("\e[2K")
  end

  it ".clear_screen" do
    Crubbletea::ANSI.clear_screen.should eq("\e[2J")
  end

  it ".enter_alt_screen" do
    Crubbletea::ANSI.enter_alt_screen.should eq("\e[?1049h")
  end

  it ".exit_alt_screen" do
    Crubbletea::ANSI.exit_alt_screen.should eq("\e[?1049l")
  end

  it ".set_cursor_style_block_blink" do
    Crubbletea::ANSI.set_cursor_style_block_blink.should eq("\e[1 q")
  end

  it ".set_cursor_style_block" do
    Crubbletea::ANSI.set_cursor_style_block.should eq("\e[2 q")
  end

  it ".set_window_title" do
    Crubbletea::ANSI.set_window_title("Test").should eq("\e]0;Test\e\\")
  end

  it ".enable_mouse_cell" do
    s = Crubbletea::ANSI.enable_mouse_cell
    s.should contain("\e[?1000h")
    s.should contain("\e[?1006h")
  end

  it ".enable_mouse_all" do
    s = Crubbletea::ANSI.enable_mouse_all
    s.should contain("\e[?1003h")
    s.should contain("\e[?1006h")
  end

  it ".disable_mouse" do
    s = Crubbletea::ANSI.disable_mouse
    s.should contain("\e[?1000l")
    s.should contain("\e[?1003l")
    s.should contain("\e[?1006l")
  end

  it ".enable_focus" do
    Crubbletea::ANSI.enable_focus.should eq("\e[?1004h")
  end

  it ".disable_focus" do
    Crubbletea::ANSI.disable_focus.should eq("\e[?1004l")
  end

  it ".reset_cursor_style" do
    Crubbletea::ANSI.reset_cursor_style.should eq("\e[0 q")
  end

  it ".enable_kitty_keyboard" do
    Crubbletea::ANSI.enable_kitty_keyboard.should eq("\e[?1u")
  end

  it ".disable_kitty_keyboard" do
    Crubbletea::ANSI.disable_kitty_keyboard.should eq("\e[?0u")
  end

  it ".cursor_home" do
    Crubbletea::ANSI.cursor_home.should eq("\e[H")
  end

  it ".clear_below" do
    Crubbletea::ANSI.clear_below.should eq("\e[J")
  end

  it ".scroll_up" do
    Crubbletea::ANSI.scroll_up(5).should eq("\e[5S")
  end

  it ".insert_line" do
    Crubbletea::ANSI.insert_line(3).should eq("\e[3L")
  end

  it ".set_foreground_color" do
    Crubbletea::ANSI.set_foreground_color("#ABCDEF").should eq("\e]10;#ABCDEF\e\\")
  end

  it ".set_background_color" do
    Crubbletea::ANSI.set_background_color("#123456").should eq("\e]11;#123456\e\\")
  end

  it ".set_progress_bar" do
    Crubbletea::ANSI.set_progress_bar(1, 50).should eq("\e]9;4;1;50\e\\")
  end

  it ".begin_synced_update" do
    Crubbletea::ANSI.begin_synced_update.should eq("\e[?2026h")
  end

  it ".end_synced_update" do
    Crubbletea::ANSI.end_synced_update.should eq("\e[?2026l")
  end

  it ".enable_bracketed_paste" do
    Crubbletea::ANSI.enable_bracketed_paste.should eq("\e[?2004h")
  end

  it ".disable_bracketed_paste" do
    Crubbletea::ANSI.disable_bracketed_paste.should eq("\e[?2004l")
  end
end

describe "Lipgloss::Style" do
  it ".new creates default style" do
    s = Crubbletea::Lipgloss::Style.new
    s.get_width.should eq(0)
    s.get_height.should eq(0)
  end

  it ".foreground sets color" do
    s = Crubbletea::Lipgloss::Style.new.foreground("red")
    s.get_foreground.should eq("red")
  end

  it ".background sets color" do
    s = Crubbletea::Lipgloss::Style.new.background("blue")
    s.get_background.should eq("blue")
  end

  it ".bold returns new style" do
    s = Crubbletea::Lipgloss::Style.new.bold
    rendered = s.render("hello")
    rendered.should contain("\e[1m")
    rendered.should contain("\e[0m")
  end

  it ".italic returns new style" do
    s = Crubbletea::Lipgloss::Style.new.italic
    rendered = s.render("hello")
    rendered.should contain("\e[3m")
  end

  it ".faint returns new style" do
    s = Crubbletea::Lipgloss::Style.new.faint
    rendered = s.render("hello")
    rendered.should contain("\e[2m")
  end

  it ".underline returns new style" do
    s = Crubbletea::Lipgloss::Style.new.underline
    rendered = s.render("hello")
    rendered.should contain("\e[4m")
  end

  it ".reverse returns new style" do
    s = Crubbletea::Lipgloss::Style.new.reverse
    rendered = s.render("hello")
    rendered.should contain("\e[7m")
  end

  it ".width sets width" do
    s = Crubbletea::Lipgloss::Style.new.width(20)
    s.get_width.should eq(20)
  end

  it ".height sets height" do
    s = Crubbletea::Lipgloss::Style.new.height(5)
    s.get_height.should eq(5)
  end

  it ".padding sets all padding" do
    s = Crubbletea::Lipgloss::Style.new.padding(2)
    s.get_padding_top.should eq(2)
    s.get_padding_right.should eq(2)
    s.get_padding_bottom.should eq(2)
    s.get_padding_left.should eq(2)
  end

  it ".margin sets all margin" do
    s = Crubbletea::Lipgloss::Style.new.margin(3)
    s.get_margin_top.should eq(3)
    s.get_margin_right.should eq(3)
    s.get_margin_bottom.should eq(3)
    s.get_margin_left.should eq(3)
  end

  it ".render produces ANSI for bold+italic" do
    s = Crubbletea::Lipgloss::Style.new.bold.italic
    rendered = s.render("test")
    rendered.should contain("\e[1m")
    rendered.should contain("\e[3m")
    rendered.should contain("\e[0m")
  end

  it ".render returns empty for empty string with no dimensions" do
    s = Crubbletea::Lipgloss::Style.new
    s.render("").should eq("")
  end

  it ".inline mode" do
    s = Crubbletea::Lipgloss::Style.new.bold.inline
    rendered = s.render("x")
    rendered.should contain("\e[1m")
  end

  it "chaining is immutable" do
    base = Crubbletea::Lipgloss::Style.new
    bold = base.bold
    italic = base.italic
    bold.render("a").should contain("\e[1m")
    bold.render("a").should_not contain("\e[3m")
    italic.render("a").should contain("\e[3m")
    italic.render("a").should_not contain("\e[1m")
  end

  it ".render with foreground color symbol" do
    s = Crubbletea::Lipgloss::Style.new.foreground(:red)
    rendered = s.render("hello")
    rendered.should contain("\e[")
  end

  it ".render with width pads content" do
    s = Crubbletea::Lipgloss::Style.new.width(10)
    rendered = s.render("hi")
    Crubbletea::Lipgloss::ANSI.string_width(Crubbletea::Lipgloss::ANSI.strip(rendered.split('\n')[0])).should be >= 2
  end
end

describe "Lipgloss::ANSI" do
  it ".string_width measures ASCII correctly" do
    Crubbletea::Lipgloss::ANSI.string_width("hello").should eq(5)
  end

  it ".string_width ignores ANSI escape sequences" do
    Crubbletea::Lipgloss::ANSI.string_width("\e[1mhello\e[0m").should eq(5)
  end

  it ".string_width handles multiline" do
    Crubbletea::Lipgloss::ANSI.string_width("hi\nworld").should eq(5)
  end

  it ".char_width returns 1 for ASCII" do
    Crubbletea::Lipgloss::ANSI.char_width('a').should eq(1)
  end

  it ".char_width returns 2 for wide chars" do
    Crubbletea::Lipgloss::ANSI.char_width('世').should eq(2)
  end

  it ".truncate short string unchanged" do
    Crubbletea::Lipgloss::ANSI.truncate("hi", 10).should eq("hi")
  end

  it ".truncate long string" do
    result = Crubbletea::Lipgloss::ANSI.truncate("hello world", 5)
    stripped = Crubbletea::Lipgloss::ANSI.strip(result)
    stripped.size.should be <= 5
  end

  it ".truncate returns tail for zero width" do
    Crubbletea::Lipgloss::ANSI.truncate("hello", 0).should eq("hello")
  end

  it ".strip removes ANSI codes" do
    Crubbletea::Lipgloss::ANSI.strip("\e[1m\e[31mhello\e[0m").should eq("hello")
  end

  it ".strip leaves plain text unchanged" do
    Crubbletea::Lipgloss::ANSI.strip("plain text").should eq("plain text")
  end
end

describe "InputParser" do
  it "parses enter key" do
    parser = Crubbletea::InputParser.new
    result = parser.parse(0x0d)
    result.should be_a(Crubbletea::KeyPressMsg)
    msg = result.as(Crubbletea::KeyPressMsg)
    msg.key.code.should eq(Crubbletea::Key::Code::Enter)
  end

  it "parses backspace key" do
    parser = Crubbletea::InputParser.new
    result = parser.parse(0x7f)
    result.should be_a(Crubbletea::KeyPressMsg)
    msg = result.as(Crubbletea::KeyPressMsg)
    msg.key.code.should eq(Crubbletea::Key::Code::Backspace)
  end

  it "parses tab key" do
    parser = Crubbletea::InputParser.new
    result = parser.parse(0x09)
    result.should be_a(Crubbletea::KeyPressMsg)
    msg = result.as(Crubbletea::KeyPressMsg)
    msg.key.code.should eq(Crubbletea::Key::Code::Tab)
  end

  it "parses space key" do
    parser = Crubbletea::InputParser.new
    result = parser.parse(0x20)
    result.should be_a(Crubbletea::KeyPressMsg)
    msg = result.as(Crubbletea::KeyPressMsg)
    msg.key.code.should eq(Crubbletea::Key::Code::Space)
    msg.key.text.should eq(" ")
  end

  it "parses printable ASCII char" do
    parser = Crubbletea::InputParser.new
    result = parser.parse('a'.ord.to_u8)
    result.should be_a(Crubbletea::KeyPressMsg)
    msg = result.as(Crubbletea::KeyPressMsg)
    msg.key.text.should eq("a")
  end

  it "parses ctrl+char" do
    parser = Crubbletea::InputParser.new
    result = parser.parse(0x01)
    result.should be_a(Crubbletea::KeyPressMsg)
    msg = result.as(Crubbletea::KeyPressMsg)
    msg.key.ctrl.should be_true
    msg.key.text.should eq("a")
  end

  it "parses escape key via double escape" do
    parser = Crubbletea::InputParser.new
    parser.parse(0x1b)
    result = parser.parse(0x1b)
    result.should be_a(Crubbletea::KeyPressMsg)
    msg = result.as(Crubbletea::KeyPressMsg)
    msg.key.code.should eq(Crubbletea::Key::Code::Escape)
  end

  it "parses escape then non-bracket returns escape" do
    parser = Crubbletea::InputParser.new
    parser.parse(0x1b)
    result = parser.parse('x'.ord.to_u8)
    result.should be_a(Crubbletea::KeyPressMsg)
    msg = result.as(Crubbletea::KeyPressMsg)
    msg.key.code.should eq(Crubbletea::Key::Code::Escape)
  end

  it "parses CSI up arrow" do
    parser = Crubbletea::InputParser.new
    parser.parse(0x1b)
    parser.parse(0x5b)
    result = parser.parse('A'.ord.to_u8)
    result.should be_a(Crubbletea::KeyPressMsg)
    msg = result.as(Crubbletea::KeyPressMsg)
    msg.key.code.should eq(Crubbletea::Key::Code::Up)
  end

  it "parses CSI down arrow" do
    parser = Crubbletea::InputParser.new
    parser.parse(0x1b)
    parser.parse(0x5b)
    result = parser.parse('B'.ord.to_u8)
    result.should be_a(Crubbletea::KeyPressMsg)
    msg = result.as(Crubbletea::KeyPressMsg)
    msg.key.code.should eq(Crubbletea::Key::Code::Down)
  end

  it "parses CSI right arrow" do
    parser = Crubbletea::InputParser.new
    parser.parse(0x1b)
    parser.parse(0x5b)
    result = parser.parse('C'.ord.to_u8)
    result.should be_a(Crubbletea::KeyPressMsg)
    msg = result.as(Crubbletea::KeyPressMsg)
    msg.key.code.should eq(Crubbletea::Key::Code::Right)
  end

  it "parses CSI left arrow" do
    parser = Crubbletea::InputParser.new
    parser.parse(0x1b)
    parser.parse(0x5b)
    result = parser.parse('D'.ord.to_u8)
    result.should be_a(Crubbletea::KeyPressMsg)
    msg = result.as(Crubbletea::KeyPressMsg)
    msg.key.code.should eq(Crubbletea::Key::Code::Left)
  end

  it "parses CSI home" do
    parser = Crubbletea::InputParser.new
    parser.parse(0x1b)
    parser.parse(0x5b)
    result = parser.parse('H'.ord.to_u8)
    result.should be_a(Crubbletea::KeyPressMsg)
    msg = result.as(Crubbletea::KeyPressMsg)
    msg.key.code.should eq(Crubbletea::Key::Code::Home)
  end

  it "parses CSI end" do
    parser = Crubbletea::InputParser.new
    parser.parse(0x1b)
    parser.parse(0x5b)
    result = parser.parse('F'.ord.to_u8)
    result.should be_a(Crubbletea::KeyPressMsg)
    msg = result.as(Crubbletea::KeyPressMsg)
    msg.key.code.should eq(Crubbletea::Key::Code::End)
  end

  it "parses CSI focus event" do
    parser = Crubbletea::InputParser.new
    parser.parse(0x1b)
    parser.parse(0x5b)
    result = parser.parse('I'.ord.to_u8)
    result.should be_a(Crubbletea::FocusMsg)
  end

  it "parses CSI blur event" do
    parser = Crubbletea::InputParser.new
    parser.parse(0x1b)
    parser.parse(0x5b)
    result = parser.parse('O'.ord.to_u8)
    result.should be_a(Crubbletea::BlurMsg)
  end

  it "parses SS3 F1-F4" do
    {'P' => Crubbletea::Key::Code::F1, 'Q' => Crubbletea::Key::Code::F2, 'R' => Crubbletea::Key::Code::F3, 'S' => Crubbletea::Key::Code::F4}.each do |final, expected_code|
      parser = Crubbletea::InputParser.new
      parser.parse(0x1b)
      parser.parse(0x4f)
      result = parser.parse(final.ord.to_u8)
      result.should be_a(Crubbletea::KeyPressMsg)
      msg = result.as(Crubbletea::KeyPressMsg)
      msg.key.code.should eq(expected_code)
    end
  end

  it "parses delete via tilde (code 3)" do
    parser = Crubbletea::InputParser.new
    parser.parse(0x1b)
    parser.parse(0x5b)
    "3".each_byte { |b| parser.parse(b) }
    result = parser.parse('~'.ord.to_u8)
    result.should be_a(Crubbletea::KeyPressMsg)
    msg = result.as(Crubbletea::KeyPressMsg)
    msg.key.code.should eq(Crubbletea::Key::Code::Delete)
  end

  it "parses pgup via tilde (code 5)" do
    parser = Crubbletea::InputParser.new
    parser.parse(0x1b)
    parser.parse(0x5b)
    "5".each_byte { |b| parser.parse(b) }
    result = parser.parse('~'.ord.to_u8)
    result.should be_a(Crubbletea::KeyPressMsg)
    msg = result.as(Crubbletea::KeyPressMsg)
    msg.key.code.should eq(Crubbletea::Key::Code::PgUp)
  end

  it "parses pgdown via tilde (code 6)" do
    parser = Crubbletea::InputParser.new
    parser.parse(0x1b)
    parser.parse(0x5b)
    "6".each_byte { |b| parser.parse(b) }
    result = parser.parse('~'.ord.to_u8)
    result.should be_a(Crubbletea::KeyPressMsg)
    msg = result.as(Crubbletea::KeyPressMsg)
    msg.key.code.should eq(Crubbletea::Key::Code::PgDown)
  end

  it "parses shift+tab" do
    parser = Crubbletea::InputParser.new
    parser.parse(0x1b)
    parser.parse(0x5b)
    result = parser.parse('Z'.ord.to_u8)
    result.should be_a(Crubbletea::KeyPressMsg)
    msg = result.as(Crubbletea::KeyPressMsg)
    msg.key.code.should eq(Crubbletea::Key::Code::Tab)
    msg.key.shift.should be_true
  end

  it "parses SGR mouse click" do
    parser = Crubbletea::InputParser.new
    parser.parse(0x1b)
    parser.parse(0x5b)
    "<0;5;10".each_byte { |b| parser.parse(b) }
    result = parser.parse('M'.ord.to_u8)
    result.should be_a(Crubbletea::MouseClickMsg)
    msg = result.as(Crubbletea::MouseClickMsg)
    msg.mouse.x.should eq(4)
    msg.mouse.y.should eq(9)
    msg.mouse.button.should eq(Crubbletea::MouseButton::Left)
  end

  it "parses SGR mouse release" do
    parser = Crubbletea::InputParser.new
    parser.parse(0x1b)
    parser.parse(0x5b)
    "<0;3;3".each_byte { |b| parser.parse(b) }
    result = parser.parse('m'.ord.to_u8)
    result.should be_a(Crubbletea::MouseReleaseMsg)
    msg = result.as(Crubbletea::MouseReleaseMsg)
    msg.mouse.button.should eq(Crubbletea::MouseButton::Left)
  end

  it "in_escape_state? reports correctly" do
    parser = Crubbletea::InputParser.new
    parser.in_escape_state?.should be_false
    parser.parse(0x1b)
    parser.in_escape_state?.should be_true
  end

  it "flush_escape returns escape key" do
    parser = Crubbletea::InputParser.new
    parser.parse(0x1b)
    result = parser.flush_escape
    result.should be_a(Crubbletea::KeyPressMsg)
    msg = result.as(Crubbletea::KeyPressMsg)
    msg.key.code.should eq(Crubbletea::Key::Code::Escape)
    parser.in_escape_state?.should be_false
  end

  it "flush_escape returns nil when not in escape state" do
    parser = Crubbletea::InputParser.new
    parser.flush_escape.should be_nil
  end

  it "reset clears state" do
    parser = Crubbletea::InputParser.new
    parser.parse(0x1b)
    parser.in_escape_state?.should be_true
    parser.reset
    parser.in_escape_state?.should be_false
  end
end

class FrameworkTestModel
  include Crubbletea::Model

  @count : Int32 = 0

  def init
    nil
  end

      def update(msg)
        if msg.is_a?(Crubbletea::KeyPressMsg) && msg.key.code.enter?
          @count += 1
        end
        nil
      end

  def view : Crubbletea::View
    Crubbletea.new_view("count: #{@count}\n")
  end

  def count
    @count
  end
end

describe "Model module" do
  it "can be included in a class" do
    m = FrameworkTestModel.new
    m.init
    m.count.should eq(0)
    m.update(Crubbletea::KeyPressMsg.new(Crubbletea::Key.new(code: :enter)))
    m.count.should eq(1)
    v = m.view
    v.should be_a(Crubbletea::View)
    v.content.should contain("count: 1")
  end
end
