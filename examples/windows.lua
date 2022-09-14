local curses = require "curses"


local function printf (fmt, ...)
  return print (string.format (fmt, ...))
end

-- ===========================================================================
-- ===========================================================================

local function main ()
  local stdscr = curses.initscr()

--   curses.cbreak()
  curses.raw()
  curses.echo(false)  -- not noecho !
  curses.nl(true)     -- not nonl !

  stdscr:clear()
  stdscr:mvaddstr(0, 0, "Enter Ctrl-Q to quit\n")
  stdscr:refresh()

  local height = 20
  local width = 40
  local starty = 1
  local startx = 0
  window1_box = curses.newwin(height, width, starty, startx)
  window1 = curses.newwin(height-2, width-2, starty+1, startx+1)
  startx = 41
  window2_box = curses.newwin(height, width, starty, startx)
  window2 = curses.newwin(height-2, width-2, starty+1, startx+1)
  window_banner = curses.newwin(1, 2*width, 0, 0)

  window1_box:box(0, 0)
  window2_box:box(0, 0)
  window1_box:refresh()
  window2_box:refresh()

  local s = '' 
  window1:mvaddstr(0, 0, s)
  window1:refresh()

  local is_quit_key = false

  while not is_quit_key do
    local c = stdscr:getch()
    is_valid_key = (c <= 255)
    is_enter_key = (c == 10)
    is_quit_key  = (c == 17)
    is_backspace_key  = (c == 8) or (c == 127)
    local ch = is_valid_key and string.char(c) or ''

    local ch_banner = ch
    if is_enter_key then
      ch_banner = '<cr>'
    elseif is_backspace_key then
      ch_banner = '<bs>'
    end
    banner = "Enter Ctrl-Q to quit, '" .. ch_banner  .. "' (" .. tostring(c)  ..  ')                 '
    window_banner:mvaddstr(0, 0, banner)

    if is_backspace_key then
      s = s:sub(1, -2)
    else
      s = s .. ch
    end

    window2:mvaddstr(0, 0, s)
    window2:clrtobot()
    
    window1:mvaddstr(0, 0, s)
    window1:clrtobot()

    window_banner:refresh()
    window2:refresh()
    window1:refresh()

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
