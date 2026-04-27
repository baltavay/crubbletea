struct Crubbletea::InputParser
  private enum State
    Normal
    Escape
    Csi
    Ss3
    Utf8
  end

  @state : State = :normal
  @csi_params : String = ""
  @utf8_buf : Bytes = Bytes.new(4)
  @utf8_len : Int32 = 0
  @utf8_expected : Int32 = 0

  def parse(byte : UInt8) : Msg?
    case @state
    in State::Normal
      parse_normal(byte)
    in State::Escape
      parse_escape(byte)
    in State::Csi
      parse_csi(byte)
    in State::Ss3
      parse_ss3(byte)
    in State::Utf8
      parse_utf8(byte)
    end
  end

  def in_escape_state? : Bool
    @state == State::Escape
  end

  def flush_escape : Msg?
    return nil unless @state == State::Escape
    @state = State::Normal
    KeyPressMsg.new(Key.new(code: :escape))
  end

  def reset : Nil
    @state = State::Normal
    @csi_params = ""
    @utf8_len = 0
    @utf8_expected = 0
  end

  private def start_utf8(byte : UInt8) : Msg?
    @utf8_buf[0] = byte
    @utf8_len = 1
    if (byte & 0xE0) == 0xC0
      @utf8_expected = 2
    elsif (byte & 0xF0) == 0xE0
      @utf8_expected = 3
    elsif (byte & 0xF8) == 0xF0
      @utf8_expected = 4
    else
      return KeyPressMsg.new(Key.new(text: "?"))
    end
    @state = State::Utf8
    nil
  end

  private def parse_utf8(byte : UInt8) : Msg?
    @utf8_buf[@utf8_len] = byte
    @utf8_len += 1
    if @utf8_len >= @utf8_expected
      @state = State::Normal
      slice = @utf8_buf[0...@utf8_len]
      begin
        ch = String.new(slice)[0]?
        if ch
          KeyPressMsg.new(Key.new(text: ch.to_s))
        else
          nil
        end
      rescue
        nil
      end
    else
      nil
    end
  end

  private def parse_normal(byte : UInt8) : Msg?
    case byte
    when 0x1b
      @state = State::Escape
      @csi_params = ""
      nil
    when 0x0d
      KeyPressMsg.new(Key.new(code: :enter))
    when 0x0a, 0x0c
      KeyPressMsg.new(Key.new(code: :enter))
    when 0x7f, 0x08
      KeyPressMsg.new(Key.new(code: :backspace))
    when 0x09
      KeyPressMsg.new(Key.new(code: :tab))
    when 0x20
      KeyPressMsg.new(Key.new(code: :space, text: " "))
    when 0x01..0x1a
      KeyPressMsg.new(Key.new(text: (byte + 0x60).chr.to_s, ctrl: true))
    else
      if byte >= 0x20 && byte < 0x7f
        KeyPressMsg.new(Key.new(text: byte.chr.to_s))
      elsif byte >= 0x80
        start_utf8(byte)
      else
        nil
      end
    end
  end

  private def parse_escape(byte : UInt8) : Msg?
    case byte
    when 0x5b
      @state = State::Csi
      @csi_params = ""
      nil
    when 0x4f
      @state = State::Ss3
      nil
    when 0x1b
      KeyPressMsg.new(Key.new(code: :escape))
    else
      @state = State::Normal
      KeyPressMsg.new(Key.new(code: :escape))
    end
  end

  private def parse_csi(byte : UInt8) : Msg?
    if byte >= 0x30 && byte <= 0x3f
      @csi_params += byte.chr
      return nil
    end

    @state = State::Normal
    params = parse_csi_params(@csi_params)
    final = byte.chr

    case final
    when 'A'
      make_key(Key::Code::Up, params)
    when 'B'
      make_key(Key::Code::Down, params)
    when 'C'
      make_key(Key::Code::Right, params)
    when 'D'
      make_key(Key::Code::Left, params)
    when 'H'
      make_key(Key::Code::Home, params)
    when 'F'
      make_key(Key::Code::End, params)
    when 'Z'
      KeyPressMsg.new(Key.new(code: :tab, shift: true))
    when 'M'
      parse_sgr_mouse_click(params)
    when 'm'
      parse_sgr_mouse_release(params)
    when '~'
      parse_tilde_key(params)
    when 'I'
      FocusMsg.new.as(Msg)
    when 'O'
      BlurMsg.new.as(Msg)
    else
      nil
    end
  end

  private def parse_ss3(byte : UInt8) : Msg?
    @state = State::Normal
    case byte
    when 0x41 then KeyPressMsg.new(Key.new(code: :up))
    when 0x42 then KeyPressMsg.new(Key.new(code: :down))
    when 0x43 then KeyPressMsg.new(Key.new(code: :right))
    when 0x44 then KeyPressMsg.new(Key.new(code: :left))
    when 0x48 then KeyPressMsg.new(Key.new(code: :home))
    when 0x46 then KeyPressMsg.new(Key.new(code: :end))
    when 0x50 then KeyPressMsg.new(Key.new(code: :f1))
    when 0x51 then KeyPressMsg.new(Key.new(code: :f2))
    when 0x52 then KeyPressMsg.new(Key.new(code: :f3))
    when 0x53 then KeyPressMsg.new(Key.new(code: :f4))
    else nil
    end
  end

  private def parse_tilde_key(params : Array(Int32)) : Msg?
    code = params[0]? || 0
    mod = params[1]? || 1
    ctrl = mod == 5 || mod == 6 || mod == 7 || mod == 8
    alt = mod == 3 || mod == 4 || mod == 7 || mod == 8
    shift = mod == 2 || mod == 4 || mod == 6 || mod == 8

    key_code = case code
    when 2  then Key::Code::Insert
    when 3  then Key::Code::Delete
    when 5  then Key::Code::PgUp
    when 6  then Key::Code::PgDown
    when 1, 7, 8, 9 then Key::Code::Home
    when 4  then Key::Code::End
    when 11 then Key::Code::F1
    when 12 then Key::Code::F2
    when 13 then Key::Code::F3
    when 14 then Key::Code::F4
    when 15 then Key::Code::F5
    when 17 then Key::Code::F6
    when 18 then Key::Code::F7
    when 19 then Key::Code::F8
    when 20 then Key::Code::F9
    when 21 then Key::Code::F10
    when 23 then Key::Code::F11
    when 24 then Key::Code::F12
    else         Key::Code::Unknown
    end

    KeyPressMsg.new(Key.new(code: key_code, ctrl: ctrl, alt: alt, shift: shift))
  end

  private def make_key(code : Key::Code, params : Array(Int32)) : Msg?
    mod = params[1]? || 1
    ctrl = mod == 5 || mod == 6 || mod == 7 || mod == 8
    alt = mod == 3 || mod == 4 || mod == 7 || mod == 8
    shift = mod == 2 || mod == 4 || mod == 6 || mod == 8
    KeyPressMsg.new(Key.new(code: code, ctrl: ctrl, alt: alt, shift: shift))
  end

  private def parse_sgr_mouse_click(params : Array(Int32)) : Msg?
    return nil unless params.size >= 3
    btn_code = params[0]
    x = {params[1] - 1, 0}.max
    y = {params[2] - 1, 0}.max

    button = parse_mouse_button(btn_code)
    ctrl = (btn_code & 0x10) != 0
    alt = (btn_code & 0x08) != 0
    shift = (btn_code & 0x04) != 0

    mouse = Mouse.new(x: x, y: y, button: button, ctrl: ctrl, alt: alt, shift: shift)
    if button.wheel_up? || button.wheel_down? || button.wheel_left? || button.wheel_right?
      MouseWheelMsg.new(mouse).as(Msg)
    else
      MouseClickMsg.new(mouse).as(Msg)
    end
  end

  private def parse_sgr_mouse_release(params : Array(Int32)) : Msg?
    return nil unless params.size >= 3
    btn_code = params[0]
    x = {params[1] - 1, 0}.max
    y = {params[2] - 1, 0}.max

    button = parse_mouse_button(btn_code)
    ctrl = (btn_code & 0x10) != 0
    alt = (btn_code & 0x08) != 0
    shift = (btn_code & 0x04) != 0

    MouseReleaseMsg.new(Mouse.new(x: x, y: y, button: button, ctrl: ctrl, alt: alt, shift: shift)).as(Msg)
  end

  private def parse_mouse_button(code : Int32) : MouseButton
    base = code & 0x03
    case base
    when 0 then MouseButton::Left
    when 1 then MouseButton::Middle
    when 2 then MouseButton::Right
    else        MouseButton::None
    end
  end

  private def parse_csi_params(s : String) : Array(Int32)
    return [] of Int32 if s.empty?
    s.split(';').map { |p| p.to_i? || 0 }
  end
end
