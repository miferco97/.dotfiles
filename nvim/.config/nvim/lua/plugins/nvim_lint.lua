return{

  'mfussenegger/nvim-lint',
  config = function()	

	require('lint').linters_by_ft =
  {
    cpp = {'cppcheck','cpplint'},
    python = {'pydocstyle', 'pylint'},
    cmake = {'cmakelint'},
  }

  local cpplint= require('lint').linters.cpplint
   -- filters = [
   --      # we do allow C++11
   --      '-build/c++11',
   --      # we consider passing non-const references to be ok
   --      '-runtime/references',
   --      # we wrap open curly braces for namespaces, classes and functions
   --      '-whitespace/braces',
   --      # we don't indent keywords like public, protected and private with one space
   --      '-whitespace/indent',
   --      # we allow closing parenthesis to be on the next line
   --      '-whitespace/parens',
   --      # we allow the developer to decide about whitespace after a semicolon
   --      '-whitespace/semicolon',
   --  ]
  cpplint.args = {
  '--linelength=100',
  '--filter=-build/c++11,-runtime/references,-whitespace/braces,-whitespace/indent,-whitespace/parens,-whitespace/semicolon,-build/header_guard',
  '--repository=include',
  '--root=include',
  '--exclude=build',
  }

  -- vim.api.nvim_create_autocmd(
  --   {"TextChanged", 
  --    -- "BufWritePost",
  --    -- "BufWritePre",
  --    -- "InsertLeave",
  --    -- "FocusGained",
  --    "BufEnter",
  --  }, 

  -- vim.api.nvim_create_autocmd(
  --   {"InsertLeave"},{
  --   callback = function()
  --   require("lint").try_lint()
  -- end,
  -- })

  -- vim.api.nvim_create_autocmd(
  --   {"BufEnter"},{
  --   callback = function()
  --   require("lint").try_lint()
  -- end,
  -- })

  vim.api.nvim_create_autocmd(
    {"BufWritePost"},{
    callback = function()
    require("lint").try_lint()
  end,
  })

	end
}
