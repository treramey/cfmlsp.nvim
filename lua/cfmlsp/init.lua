local C = {}

-- Some basic dependency checking
if not package.loaded["lspconfig"] then
	print("This plugin needs 'neovim/nvim-lspconfig' to work.")
	return {}
end

local lspconfig = require("lspconfig")
local configs = require("lspconfig.configs")

local capabilities
if vim.fn.has("nvim-0.11") == 1 then
	capabilities = vim.lsp.protocol.make_client_capabilities()
else
	capabilities = vim.lsp.protocol.make_client_capabilities()
end
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
	properties = {
		"documentation",
		"detail",
		"additionalTextEdits",
	},
}
capabilities.textDocument.definition = {
	dynamicRegistration = true,
	linkSupport = true
}

local get_plugin_path = function()
	local current_file = debug.getinfo(1).source:sub(2)
	return current_file:match("(.*/)") .. "../../"
end

local system_execute = function(command)
	local handle = io.popen(command)
	if handle == nil then
		error("Command (" .. command .. ") could not be executed.")
	end

	local result = handle:read("*a")
	handle:close()

	return result
end

-- The main setup function
function C.setup()
	-- Add cfml filetypes
	if vim.filetype and vim.filetype.add then
		vim.filetype.add({
			extension = {
				cfm = "cfml",
				cfc = "cfscript",
				cfs = "cfscript",
			},
		})
	else
		vim.cmd([[
			autocmd BufRead,BufNewFile *.cfm setfiletype cfml
			autocmd BufRead,BufNewFile *.cfc setfiletype cfscript
			autocmd BufRead,BufNewFile *.cfs setfiletype cfscript
		]])
	end

	local lsp_dir = get_plugin_path() .. "lsp"

	if not configs.cfmlsp then
		configs.cfmlsp = {
			default_config = {
				cmd = { lsp_dir .. "/lsp" },
				root_dir = lspconfig.util.root_pattern(".git", ".config"),
				filetypes = { "cfml", "cfscript" },
				on_new_config = function(new_config, new_root_dir)
					local source_config_path = lsp_dir .. "/profile.xml"
					local target_config_path = new_root_dir .. "/.cfmlsp"
					local profile_file = target_config_path .. "/profile.xml"

					new_config.init_options = {
						profile = {
							name = "profile",
							location = ".cfmlsp",
						},
						globalStoragePath = {
							uri = target_config_path,
						},
					}

					-- Copy default profile.xml if it doesn't exist yet
					local file = io.open(profile_file, "r")
					if file ~= nil then
						io.close(file)
					else
						system_execute("mkdir -p " .. target_config_path)
						system_execute("cp " .. source_config_path .. " " .. profile_file)
					end
				end,
			},
		}
	end

	lspconfig.cfmlsp.setup({ capabilities = capabilities })
end

return C
