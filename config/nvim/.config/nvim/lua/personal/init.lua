require('personal.remap')
require('personal.sets')

vim.cmd([[
augroup filetypedetect
  au! BufRead,BufNewFile *.launch setfiletype xml
augroup END
]])


-- -- Example: Map <leader>x to execute a shell command with buffer path using Lua
-- vim.api.nvim_set_keymap('n', '<leader>sc', ':lua ExecuteShellCommand()<CR>', { noremap = true, silent = true })

-- -- Function to execute shell command with buffer path
-- function ExecuteShellCommand()
--     local command = 'echo "File path: ' .. buffer_path .. '"'
--     vim.fn.system(command)
-- end

-- vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
--   pattern = {"*.cpp", "*.hpp", "*.c", "*.h", "*.lua"},
--   buffer_path = vim.fn.expand('%:p')
--   command = "echo 'Entering a C or C++ file : ' .. buffer_path",
-- })


-- vim.api.nvim_create_autocmd({"BufWritePre"}, {
--   pattern = {"*.cpp", "*.hpp", "*.c", "*.h"},
--   callback = function() 
--     buffer_path = vim.fn.expand('%:p')
--     job_id = vim.fn.jobstart({'ament_uncrustify', '--reformat', buffer_path}, {
--       on_exit = function(job_id, data, event)
--         print('Job ' .. job_id .. ' exited with event ' .. event)
--       end
--     })
--   end
-- })

-- vim.api.nvim_create_autocmd({"BufWritePost"},
--     {
--     pattern = {"*.cpp", "*.hpp", "*.c", "*.h"},
--         callback = function()
--             vim.cmd("silent ! ament_uncrustify --reformat %")
--             -- vim.cmd("edit")
--         end,
--     }
-- )
