return{
  'nvim-tree/nvim-tree.lua',
  -- dependencies={
  --   'nvim-tree/nvim-web-devicons',
  -- },
  config=function()
     -- disable netrw at the very start of your init.lua
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- set termguicolors to enable highlight groups
    vim.opt.termguicolors = true

    -- empty setup using defaults
    require("nvim-tree").setup()

    -- OR setup with some options
    require("nvim-tree").setup({
      sort_by = "case_sensitive",
      view = {
        width = 30,
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = true,
      },
    })
    require('nvim-web-devicons').setup()
    vim.keymap.set('n','<leader>pv', vim.cmd.Ex)
    vim.api.nvim_create_user_command('Trex',
    function()
      vim.cmd('NvimTreeToggle')
    end,{})

  end
}
