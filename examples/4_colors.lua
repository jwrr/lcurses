-- Copyright 2022 jwrr.com
--
-- THE MIT LICENSE
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local curses = require "curses"


local function printf (fmt, ...)
  return print (string.format (fmt, ...))
end

-- ===========================================================================
-- ===========================================================================


local function print_win(win, str, attr)
  attr = attr or curses.A_NORMAL
  win:attron(attr)
  win:mvaddstr(0, 0, str)
  win:attroff(attr)
  win:clrtobot()
  win:refresh()
end


local function rainbow_win(win, str, attr)
  attr = attr or curses.A_NORMAL
  win:attron(attr)
  win:mvaddstr(0, 0, '')
  for i = 1, #str do
    -- iterate 1 to 7 (skip 0 which is black / invisible)
    local attr_tmp = (i % 7) + 1
    win:attron(attr_tmp)
    local c = str:sub(i,i)
    win:addstr(c)
  end

  win:attroff(attr)
  win:clrtobot()
  win:refresh()
end


local function rpad(str, len)
  return str .. string.rep(" ", len - #str)
end


local function main ()
  local stdscr = curses.initscr()
  stdscr:clear()
  stdscr:refresh()

--   curses.cbreak()
  curses.raw()
  curses.echo(false)
  curses.nl(true)


  local height = 20
  local width = 40
  local starty = 1
  local startx = 0
  local window1_box = curses.newwin(height, width, starty, startx)
  local window1 = curses.newwin(height-2, width-2, starty+1, startx+1)
  startx = 41
  local window2_box = curses.newwin(height, width, starty, startx)
  local window2 = curses.newwin(height-2, width-2, starty+1, startx+1)
  window1_box:box(0, 0)
  window2_box:box(0, 0)
  window1_box:refresh()
  window2_box:refresh()


  local full_width = 2*width + 1
  local window_banner = curses.newwin(1, full_width, 0, 0)
  local banner = "Enter Ctrl-Q to quit"
  banner = banner .. string.rep(" ", full_width - banner:len())
  window_banner:attron(curses.A_REVERSE)
  window_banner:mvaddstr(0, 0, banner)
  window_banner:attroff(curses.A_REVERSE)
  window_banner:refresh()


  starty = starty + height
  startx = 0
  height = 5
  local window3_box = curses.newwin(height, full_width, starty, startx)
  local window3     = curses.newwin(height-2, full_width-2, starty+1, startx+1)
  window3_box:box(0, 0)
  window3_box:refresh()

  starty = starty + height
  startx = 0
  height = 5
  local window4_box = curses.newwin(height, full_width, starty, startx)
  local window4     = curses.newwin(height-2, full_width-2, starty+1, startx+1)
  
  window4_box:box(0, 0)
  window4_box:refresh()

  curses.start_color();
  curses.init_pair(1, curses.COLOR_BLUE,   curses.COLOR_YELLOW) -- curses.COLOR_RED, curses.COLOR_GREEN)
  curses.init_pair(2, curses.COLOR_RED,   curses.COLOR_BLACK) -- curses.COLOR_RED, curses.COLOR_GREEN)
  curses.init_pair(3, curses.COLOR_GREEN, curses.COLOR_BLACK) -- curses.COLOR_RED, curses.COLOR_GREEN)
  curses.init_pair(4, curses.COLOR_WHITE,  curses.COLOR_BLACK) -- curses.COLOR_RED, curses.COLOR_GREEN)
  curses.init_pair(5, 15,  0) -- curses.COLOR_RED, curses.COLOR_GREEN)
  window_banner:attron(curses.color_pair(1))
  window4:attron(curses.color_pair(2))
  -- window3:attron(curses.color_pair(5))
  window2:attron(curses.color_pair(4))
  window1:attron(curses.color_pair(3))

  local s = ''
  window1:mvaddstr(0, 0, s)
  window1:refresh()

  local is_quit_key = false

  while not is_quit_key do
    local c = stdscr:getch()
    is_quit_key  = (c == 17)
    local is_valid_key = (c <= 255)
    local is_enter_key = (c == 10)
    local is_backspace_key  = (c == 8) or (c == 127)
    local ch = is_valid_key and string.char(c) or ''

    local ch_banner = ch
    if is_enter_key then
      ch_banner = '<cr>'
    elseif is_backspace_key then
      ch_banner = '<bs>'
    end
    banner = "Enter Ctrl-Q to quit, '" .. ch_banner  .. "' (" .. tostring(c)  ..  ')'
    banner = rpad(banner, full_width)
    print_win(window_banner, banner, curses.A_REVERSE)

    if is_backspace_key then
      s = s:sub(1, -2)
    else
      s = s .. ch
    end
    print_win(window2, s, curses.A_NORMAL)
    print_win(window3, s, curses.A_NORMAL)
    print_win(window4, s, curses.A_NORMAL)
    print_win(window1, s, curses.A_NORMAL)

--     stdscr:mvaddstr(1, 0, s)
--     stdscr:clrtobot()
--     stdscr:refresh()
  end
  curses.endwin()
end


-- To display Lua errors, we must close curses to return to
-- normal terminal mode, and then write the error to stdout.
local function err(err)
  curses.endwin()
  print "Caught an error:"
  print(debug.traceback(err, 2))
  os.exit(2)
end

xpcall(main, err)
