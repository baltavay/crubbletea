lib CrubbleteaIoctl
  struct Winsize
    ws_row : UInt16
    ws_col : UInt16
    ws_xpixel : UInt16
    ws_ypixel : UInt16
  end

  fun ioctl(fd : Int32, request : UInt64, ...) : Int32
end

module Crubbletea::Termios
  VTIME = 5
  TIOCGWINSZ = 0x00005413_u64

  def self.get_state(fd : Int32) : LibC::Termios
    state = uninitialized LibC::Termios
    ret = LibC.tcgetattr(fd, pointerof(state))
    raise "tcgetattr failed" if ret != 0
    state
  end

  def self.set_state(fd : Int32, state : LibC::Termios) : Nil
    ret = LibC.tcsetattr(fd, LibC::TCSAFLUSH, pointerof(state))
    raise "tcsetattr failed" if ret != 0
  end

  def self.enter_raw(fd : Int32) : LibC::Termios
    old = get_state(fd)
    raw = old

    raw.c_iflag = raw.c_iflag & ~(LibC::BRKINT | LibC::ICRNL | LibC::INPCK | LibC::ISTRIP | LibC::IXON)
    raw.c_oflag = raw.c_oflag & ~LibC::OPOST
    raw.c_cflag = (raw.c_cflag & ~LibC::CS8) | LibC::CS8
    raw.c_lflag = raw.c_lflag & ~(LibC::ECHO | LibC::ICANON | LibC::ISIG | LibC::IEXTEN)
    raw.c_cc[LibC::VMIN] = 0_u8
    raw.c_cc[VTIME] = 1_u8

    set_state(fd, raw)
    old
  end

  def self.restore(fd : Int32, state : LibC::Termios) : Nil
    set_state(fd, state)
  end

  def self.window_size(fd : Int32) : {Int32, Int32}
    ws = uninitialized CrubbleteaIoctl::Winsize
    ret = CrubbleteaIoctl.ioctl(fd, TIOCGWINSZ, pointerof(ws))
    if ret != 0
      return {80, 24}
    end
    {ws.ws_col.to_i, ws.ws_row.to_i}
  end
end
