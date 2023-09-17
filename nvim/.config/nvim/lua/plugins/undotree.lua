-- Usefull util for having all your undo tree in a visual way 

return {
	'mbbill/undotree',
	config = function()
		vim.keymap.set('n','<F5>', vim.cmd.UndotreeToggle)
	end
}
