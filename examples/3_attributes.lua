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
  curses.echo(false)  -- not noecho !
  curses.nl(true)     -- not nonl !


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


  local banner_width = 2*width + 1
  local window_banner = curses.newwin(1, banner_width, 0, 0)
  local banner = "Enter Ctrl-Q to quit"
  banner = banner .. string.rep(" ", banner_width - banner:len())
  window_banner:attron(curses.A_REVERSE)
  window_banner:mvaddstr(0, 0, banner)
  window_banner:attroff(curses.A_REVERSE)
  window_banner:refresh()

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
    banner = rpad(banner, banner_width)
    print_win(window_banner, banner, curses.A_REVERSE)

    if is_backspace_key then
      s = s:sub(1, -2)
    else
      s = s .. ch
    end
    print_win(window2, s, curses.A_UNDERLINE)
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
