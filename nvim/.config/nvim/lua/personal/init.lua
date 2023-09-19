require('personal.remap')
require('personal.sets')

vim.cmd([[
augroup filetypedetect
  au! BufRead,BufNewFile *.launch setfiletype xml
augroup END
]])
