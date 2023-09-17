return {
  "ray-x/lsp_signature.nvim",
  tag='v0.2.0',
  event = "VeryLazy",
  opts = {
    hint_enable=false,
    select_signature_key = '<Tab>', -- cycle to next signature, e.g. '<M-n>' function overloading
  },
  config = function(_, opts)
    require'lsp_signature'.setup(opts)
  end
}
