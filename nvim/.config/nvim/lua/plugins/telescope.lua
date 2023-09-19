return{
  'nvim-telescope/telescope.nvim',
  dependencies = {
	  'nvim-lua/plenary.nvim',
  },
  config = function()	 
	local builtin = require('telescope.builtin')
	vim.keymap.set('n','<leader>ff',builtin.find_files,{})
	vim.keymap.set('n','<C-p>',builtin.git_files,{})
	vim.keymap.set('n','fg',builtin.live_grep,{})

	vim.keymap.set('n','<leader>fs',function() 
  require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})
  end,{})
	vim.keymap.set('n','<leader>fw',function() 
  require('telescope.builtin').grep_string({ search = vim.fn.expand("<cword>") })
  end,{})

	end
}
