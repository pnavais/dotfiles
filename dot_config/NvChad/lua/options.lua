require "nvchad.options"

-- add yours here!

local o = vim.o
o.cursorlineopt = 'both' -- to enable cursorline!

-- Restores cursor on exit
o.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"
  .. ",a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor"
  .. ",sm:block-blinkwait175-blinkoff150-blinkon175"

