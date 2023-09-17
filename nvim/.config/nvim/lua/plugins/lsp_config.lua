-- create config function

return {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    dependencies = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},             -- Required
      {'williamboman/mason.nvim'},           -- Optional
      {'williamboman/mason-lspconfig.nvim'}, -- Optional

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},     -- Required
      {'hrsh7th/cmp-nvim-lsp'}, -- Required
      {'L3MON4D3/LuaSnip'},     -- Required

    },
    config = function()
      local lsp_zero= require('lsp-zero')
      lsp_zero.preset('recommended')

      lsp_zero.set_preferences({
            suggest_lsp_servers = false,
            sign_icons = {
                error = 'E',
                warn = 'W',
                hint = 'H',
                info = 'I'
            }
        })

      local cmp = require('cmp')
      local cmp_action = require('lsp-zero').cmp_action()

--      cmp_mappings['<Tab>'] = nil
--     cmp_mappings['<S-Tab>'] = nil

      cmp.setup({
        sources= {
          {name = 'nvim_lsp'},
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
          },
          mapping = cmp.mapping.preset.insert({
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<CR>'] = cmp.mapping.confirm({select=true}),
            ['<C-f>'] = cmp_action.luasnip_jump_forward(),
            ['<C-b>'] = cmp_action.luasnip_jump_backward(),
            ['<C-u>'] = cmp.mapping.scroll_docs(-4),
            ['<C-d>'] = cmp.mapping.scroll_docs(4),
            ['<Tab>'] = nil
          }),
        })

      lsp_zero.on_attach(function(client, bufnr)
        -- see :help lsp-zero-keybindings
        -- to learn the available actions
        --lsp_zero.default_keymaps({buffer = bufnr})
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "gh", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
      end)

      require('mason').setup({})
      require('mason-lspconfig').setup({
        ensure_installed={
          'clangd',
          'lua_ls',
          'pyright',
        },
      handlers = {
        lsp_zero.default_setup,
       }
     })

   end

}

