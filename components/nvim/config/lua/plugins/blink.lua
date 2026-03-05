-- Plugin which gives auto-completion capabilities. Another plugin is nvim-cmp
return {
  {
    "saghen/blink.cmp",
    version = "0.13.0",
    enabled = true,
    dependencies = { "rafamadriz/friendly-snippets", "moyiz/blink-emoji.nvim" },

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = "enter" },

      appearance = {
        nerd_font_variant = "mono",
      },

      cmdline = {
        enabled = false,
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "emoji" },

        providers = {
          emoji = {
            module = "blink-emoji",
            name = "Emoji",
            score_offset = 15,  -- Tune by preference
            opts = { insert = true }, -- Insert emoji (default) or complete its name

            should_show_items = function()
              return vim.tbl_contains(
              -- Enable emoji completion only for git commits and markdown.
              -- By default, enabled for all file-types.
                { "gitcommit", "markdown" },
                vim.o.filetype
              )
            end,
          },
        },
      },

      signature = { enabled = true },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
