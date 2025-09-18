-- Plugin to use code formatters
return {
	"stevearc/conform.nvim",
	enabled = true,
	event = {
		"BufReadPre",
		"BufNewFile",
	},
	keys = {
		{
			"<leader>cf",
			function()
				require("conform").format({ async = true, lsp_fallback = true, timeout_ms = 500 })
			end,
			mode = "",
			desc = "[C]ode [F]ormat",
		},
	},
	opts = {
		notify_on_error = true,
		format_on_save = function(bufnr)
			local disable_filetypes = { c = true, cpp = true }
			-- local disable_filetypes = {}
			return {
				timeout_ms = 500,
				async = false,
				lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
			}
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			python = {
				-- To fix auto-fixable lint errors.
				"ruff_fix",
				-- To run the Ruff formatter.
				"ruff_format",
				-- To organize the imports.
				"ruff_organize_imports",
			},
			rust = { "rustfmt" },
			bash = { "beautysh" },
			sh = { "beautysh" },
			zsh = { "beautysh" },
			cpp = { "ament_uncrustify_pref", "clang-format", stop_after_first = true },
			c = { "ament_uncrustify_pref", "clang-format", stop_after_first = true },
			markdown = { "prettier" },
			yaml = { "prettier" },
			html = { "prettier" },
			typescript = { "prettier" },
			javascript = { "prettier" },
			typescriptreact = { "prettier" },
			javascriptreact = { "prettier" },
			json = { "prettier" },
		},
		formatters = {
			-- Prefer clang-format if a .clang-format file is present; otherwise allow ament_uncrustify
			ament_uncrustify_pref = {
				command = "ament_uncrustify",
				args = { "--reformat", "--language", "CPP", "$FILENAME" }, -- edits in place
				stdin = false,
				exit_codes = { 0, 1 }, -- 1 = divergences -> treat as success
				condition = function(ctx)
					-- Skip ament if a .clang-format is found in project root/upwards
					local has_clangfmt = vim.fs.find(
						".clang-format",
						{ upward = true, path = vim.fs.dirname(ctx.filename) }
					)[1] ~= nil
					if has_clangfmt then
						vim.notify("Skipping ament_uncrustify: .clang-format found", vim.log.levels.DEBUG)
						return false
					end
					-- Only run if ament_uncrustify is available
					return vim.fn.executable("ament_uncrustify") == 1
				end,
				-- log the output of ament_uncrustify to help debugging

				-- cwd = function(ctx)
				-- 	-- Optional: prefer ROS/colcon/pkg roots if present
				-- 	return vim.fs.root(ctx.buf, { "package.xml", "COLCON_IGNORE", "src", ".git", "CMakeLists.txt" })
				-- end,
			},

			-- (Optional) only run clang-format if it's installed
			["clang-format"] = {
				condition = function(_)
					-- Only run if clang-format is available
					return vim.fn.executable("clang-format") == 1
				end,
				-- You can also inject a config path if you want, but clang-format auto-discovers .clang-format
			},
		},
	},

	config = function(_, opts)
		require("conform").setup(opts)

		-- Reload buffer if ament_uncrustify edited the file on disk
		vim.api.nvim_create_autocmd("User", {
			pattern = "ConformFormatPost",
			callback = function()
				vim.cmd("checktime")
			end,
		})
	end,
}
