return{
	'nvie/vim-flake8',
	config = function()
		vim.g.flake8_cmd= 'flake8 --config ~/.config/nvim/ament_flake8.ini'
    vim.g.flake8_show_in_gutter = 1
    vim.g.flake8_show_in_file = 1
    vim.g.flake8_show_quickfix = 1
    vim.api.nvim_create_autocmd(
      {"BufWritePost"},{
      pattern = "*.py",
      callback = function()
      vim.cmd('call flake8#Flake8()')
    end,
    })

	end
}
