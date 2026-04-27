require "../spec_helper"

def key_press(text : String, code : Crubbletea::Key::Code = Crubbletea::Key::Code::Unknown, ctrl : Bool = false, alt : Bool = false) : Crubbletea::KeyPressMsg
  Crubbletea::KeyPressMsg.new(Crubbletea::Key.new(text: text, code: code, ctrl: ctrl, alt: alt))
end

describe Crubbletea::Bubbles::TextInput do
  describe "Model" do
    it "defaults to empty value" do
      ti = Crubbletea::Bubbles::TextInput::Model.new
      ti.value.should eq("")
      ti.cursor_pos.should eq(0)
      ti.focused?.should be_false
    end

    describe "focus/blur" do
      it "focuses and blurs" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti.focus
        ti.focused?.should be_true

        ti.blur
        ti.focused?.should be_false
      end

      it "responds to FocusMsg" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti, _ = ti.update(Crubbletea::FocusMsg.new)
        ti.focused?.should be_true
      end

      it "responds to BlurMsg" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti.focus
        ti, _ = ti.update(Crubbletea::BlurMsg.new)
        ti.focused?.should be_false
      end
    end

    describe "value" do
      it "sets value and moves cursor to end" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti.value = "hello"
        ti.value.should eq("hello")
        ti.cursor_pos.should eq(5)
      end
    end

    describe "insert_char" do
      it "inserts character at cursor position" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti.insert_char('a')
        ti.value.should eq("a")
        ti.cursor_pos.should eq(1)

        ti.insert_char('b')
        ti.value.should eq("ab")
        ti.cursor_pos.should eq(2)
      end

      it "respects char_limit" do
        ti = Crubbletea::Bubbles::TextInput::Model.new(char_limit: 3)
        ti.insert_char('a')
        ti.insert_char('b')
        ti.insert_char('c')
        ti.value.should eq("abc")
        ti.insert_char('d')
        ti.value.should eq("abc")
      end
    end

    describe "delete_char_backward" do
      it "deletes character before cursor" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti.value = "abc"
        ti.cursor_pos = 2
        ti.delete_char_backward
        ti.value.should eq("ac")
        ti.cursor_pos.should eq(1)
      end

      it "does nothing at start" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti.value = "abc"
        ti.cursor_pos = 0
        ti.delete_char_backward
        ti.value.should eq("abc")
      end
    end

    describe "delete_char_forward" do
      it "deletes character at cursor" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti.value = "abc"
        ti.cursor_pos = 1
        ti.delete_char_forward
        ti.value.should eq("ac")
        ti.cursor_pos.should eq(1)
      end

      it "does nothing at end" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti.value = "abc"
        ti.cursor_pos = 3
        ti.delete_char_forward
        ti.value.should eq("abc")
      end
    end

    describe "cursor movement" do
      it "moves left" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti.value = "abc"
        ti.move_left
        ti.cursor_pos.should eq(2)
      end

      it "moves right" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti.value = "abc"
        ti.cursor_pos = 0
        ti.move_right
        ti.cursor_pos.should eq(1)
      end

      it "moves to start" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti.value = "abc"
        ti.move_to_start
        ti.cursor_pos.should eq(0)
      end

      it "moves to end" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti.value = "abc"
        ti.cursor_pos = 0
        ti.move_to_end
        ti.cursor_pos.should eq(3)
      end

      it "cursor_pos clamps to valid range" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti.value = "ab"
        ti.cursor_pos = 10
        ti.cursor_pos.should eq(2)
        ti.cursor_pos = -1
        ti.cursor_pos.should eq(0)
      end
    end

    describe "word movement" do
      it "moves word left" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti.value = "hello world"
        ti.move_to_end
        ti.word_left
        ti.cursor_pos.should eq(6)
      end

      it "moves word right" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti.value = "hello world"
        ti.move_to_start
        ti.word_right
        ti.cursor_pos.should eq(6)
      end
    end

    describe "update with key messages" do
      it "inserts characters when focused" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti.focus

        ti, _ = ti.update(key_press("h"))
        ti, _ = ti.update(key_press("i"))
        ti.value.should eq("hi")
        ti.cursor_pos.should eq(2)
      end

      it "ignores keys when not focused" do
        ti = Crubbletea::Bubbles::TextInput::Model.new

        ti, _ = ti.update(key_press("h"))
        ti.value.should eq("")
      end

      it "handles backspace" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti.focus
        ti, _ = ti.update(key_press("a"))
        ti, _ = ti.update(key_press("b"))
        ti, _ = ti.update(key_press("", code: Crubbletea::Key::Code::Backspace))
        ti.value.should eq("a")
      end

      it "handles left/right arrows" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti.focus
        ti, _ = ti.update(key_press("a"))
        ti, _ = ti.update(key_press("b"))
        ti, _ = ti.update(key_press("left", code: Crubbletea::Key::Code::Left))
        ti.cursor_pos.should eq(1)
        ti, _ = ti.update(key_press("right", code: Crubbletea::Key::Code::Right))
        ti.cursor_pos.should eq(2)
      end

      it "handles home/end" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti.focus
        ti, _ = ti.update(key_press("a"))
        ti, _ = ti.update(key_press("b"))
        ti, _ = ti.update(key_press("home", code: Crubbletea::Key::Code::Home))
        ti.cursor_pos.should eq(0)
        ti, _ = ti.update(key_press("end", code: Crubbletea::Key::Code::End))
        ti.cursor_pos.should eq(2)
      end

      it "handles ctrl+u to delete before cursor" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti.focus
        ti, _ = ti.update(key_press("a"))
        ti, _ = ti.update(key_press("b"))
        ti, _ = ti.update(key_press("c"))
        ti.cursor_pos.should eq(3)
        ti.cursor_pos = 1
        ti, _ = ti.update(key_press("u", ctrl: true))
        ti.value.should eq("bc")
        ti.cursor_pos.should eq(0)
      end

      it "handles ctrl+k to delete after cursor" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti.focus
        ti, _ = ti.update(key_press("a"))
        ti, _ = ti.update(key_press("b"))
        ti, _ = ti.update(key_press("c"))
        ti.cursor_pos = 1
        ti, _ = ti.update(key_press("k", ctrl: true))
        ti.value.should eq("a")
      end
    end

    describe "echo_mode" do
      it "shows value in normal mode" do
        ti = Crubbletea::Bubbles::TextInput::Model.new
        ti.value = "secret"
        ti.focus
        v = ti.view
        v.should contain("secret")
      end

      it "shows asterisks in password mode" do
        ti = Crubbletea::Bubbles::TextInput::Model.new(echo_mode: :password)
        ti.value = "secret"
        ti.focus
        v = ti.view
        v.should_not contain("secret")
        v.should contain("******")
      end

      it "shows nothing in none mode" do
        ti = Crubbletea::Bubbles::TextInput::Model.new(echo_mode: :none)
        ti.value = "secret"
        ti.focus
        v = ti.view
        v.should_not contain("secret")
      end
    end

    describe "view" do
      it "shows prompt" do
        ti = Crubbletea::Bubbles::TextInput::Model.new(prompt: "> ")
        ti.focus
        ti.view.should start_with("> ")
      end

      it "shows placeholder when empty" do
        ti = Crubbletea::Bubbles::TextInput::Model.new(placeholder: "enter text...")
        ti.focus
        ti.view.should contain("enter text...")
      end
    end
  end
end
