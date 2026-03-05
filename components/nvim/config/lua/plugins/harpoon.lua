return{
  'ThePrimeagen/harpoon',
	config = function()
		vim.keymap.set('n','<C-e>',require("harpoon.ui").toggle_quick_menu)
    vim.keymap.set('n','<C-a>',require("harpoon.mark").add_file)
    vim.keymap.set('n','<C-n>',require("harpoon.ui").nav_next)
	end
}
