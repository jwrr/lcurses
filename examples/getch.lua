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

  local s = ''
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
    stdscr:mvaddstr(0, 0, banner)

    if is_backspace_key then
      s = s:sub(1, -2)
    else
      s = s .. ch
    end
    stdscr:mvaddstr(1, 0, s)
    stdscr:clrtobot()
    stdscr:refresh()
  end

  local a = {}
  for k, v in pairs(curses) do
    if type(v) == "number" then a[#a+1] = k end
  end

  stdscr:mvaddstr(15, 20, "print out curses constants (y/n) ? ")
  stdscr:refresh()

  local c = stdscr:getch()
  if c < 256 then c = string.char(c) end

  curses.endwin()

  if c == "y" then
    table.sort(a, cmp)
    for i, k in ipairs(a) do
      printf(" %03d. %20s = 0x%08x (%d)",
        i, "curses." .. k, curses[k], curses[k])
    end
  end
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
