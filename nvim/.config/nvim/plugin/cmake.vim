
nnoremap <leader>cg :CMakeGenerate -D CMAKE_CXX_FLAGS=-std=c++17<CR>
nnoremap <leader>cb :CMakeBuild<CR>
nnoremap <leader>cr :CMakeRun<CR>
nnoremap <leader>cc :CMakeStop<CR>

" CMake

"  lua << EOF
" -- init.lua
" -- setup with all defaults
" -- each of these are documented in `:help nvim-tree.OPTION_NAME`
" -- nested options are documented by accessing them with `.` (eg: `:help nvim-tree.view.mappings.list`).
" require('cmake-tools').setup {
"   cmake_command = "cmake",
"   cmake_build_directory = "build",
"   cmake_build_type = "Debug",
"   cmake_generate_options = { "-D", "CMAKE_EXPORT_COMPILE_COMMANDS=1", "-D","CMAKE_CXX_FLAGS=-std=c++17"},
"   cmake_build_options = {"-D", "CMAKE_EXPORT_COMPILE_COMMANDS=1", "-D","CMAKE_CXX_FLAGS=-std=c++17"},
"   cmake_console_size = 10, -- cmake output window height
"   cmake_show_console = "always", -- "always", "only_on_error"
"   cmake_dap_configuration = { name = "cpp", type = "codelldb", request = "launch" }, -- dap configuration, optional
"   cmake_dap_open_command = require'dap'.repl.open, -- optional
" }

" EOF


