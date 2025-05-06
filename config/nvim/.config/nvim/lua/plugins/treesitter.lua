-- This plugin is for improving text highlight

return{
	'nvim-treesitter/nvim-treesitter',
	build = ':TSUpdate',
	cmd= {'TSUpdateSync'},
	opts = {
		highlight = {enable= true},
		indent = {enable= true},
		ensure_installed= {
			'bash',
			'c',
			'cpp',
			'json',
			'lua',
			'luadoc',
			'luap',
			'markdown',
			'python',
			'vim',
			'vimdoc',
			'yaml',
		},
	},
	config = function(_, opts)
	    if type(opts.ensure_installed) == 'table' then
	      ---@type table<string, boolean>
	      local added = {}
	      opts.ensure_installed = vim.tbl_filter(function(lang)
		if added[lang] then
		  return false
		end
		added[lang] = true
		return true
	      end, opts.ensure_installed)
	    end
	    require('nvim-treesitter.configs').setup(opts)
    	end,
}
