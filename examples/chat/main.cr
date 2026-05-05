require "../../src/crubbletea"

class ChatModel
  include Crubbletea::Model

  getter viewport : Crubbletea::Bubbles::Viewport::Model
  getter textarea : Crubbletea::Bubbles::TextArea::Model
  getter messages : Array(String)

  @sender_style : Crubbletea::Lipgloss::Style

  def initialize
    @sender_style = Crubbletea::Lipgloss::Style.new
      .foreground("#af00af")

    @textarea = Crubbletea::Bubbles::TextArea::Model.new(
      placeholder: "Send a message...",
      prompt: "┃ ",
      width: 30,
      height: 3,
      char_limit: 280
    )
    @textarea.focus

    @viewport = Crubbletea::Bubbles::Viewport::Model.new(
      width: 30,
      height: 5
    )
    @viewport.content = "Welcome to the chat room!\nType a message and press Enter to send."
    @viewport.goto_bottom

    @messages = [] of String
  end

  def init : Crubbletea::Cmd?
    nil
  end

  def update(msg) : {ChatModel, Crubbletea::Cmd?}
    case msg
    when Crubbletea::WindowSizeMsg
      w = msg.width
      h = msg.height
      @viewport.width = w
      @textarea.width = w
      @viewport.height = h - @textarea.height
      unless @messages.empty?
        content = Crubbletea::Lipgloss::Style.new.width(@viewport.width).render(@messages.join('\n'))
        @viewport.content = content
      end
      @viewport.goto_bottom
    when Crubbletea::KeyPressMsg
      case msg.key.to_s
      when "ctrl+c", "escape"
        return {self, Crubbletea.quit}
      when "enter"
        @messages << "#{@sender_style.render("You: ")}#{@textarea.value}"
        content = Crubbletea::Lipgloss::Style.new.width(@viewport.width).render(@messages.join('\n'))
        @viewport.content = content
        @textarea.value = ""
        @textarea.set_cursor(0, 0)
        @viewport.goto_bottom
        return {self, nil}
      end
    end

    @textarea, cmd = @textarea.update(msg)
    {self, cmd}
  end

  def view : Crubbletea::View
    viewport_view = @viewport.view
    v = Crubbletea.new_view("#{viewport_view}\n#{@textarea.view}")
    if @textarea.focused?
      v.cursor = Crubbletea::Cursor.new(@textarea.visible_cursor_col, @viewport.height + @textarea.visible_cursor_row)
    end
    v.alt_screen = true
    v
  end
end

program = Crubbletea::Program(ChatModel).new(ChatModel.new)
program.run
