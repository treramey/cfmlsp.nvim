-- Test script for compatibility with different Neovim versions
-- Save this file and run: nvim -u NONE -l test_compatibility.lua

local function print_header(text)
  print(string.rep("=", 50))
  print(text)
  print(string.rep("=", 50))
end

-- Test Neovim version detection
print_header("Neovim Version Info")
print("Neovim version: " .. vim.version().major .. "." .. vim.version().minor)
print("Has nvim-0.11: " .. tostring(vim.fn.has('nvim-0.11') == 1))
print("Has nvim-0.8: " .. tostring(vim.fn.has('nvim-0.8') == 1))

-- Test filetype API availability
print_header("Filetype API Availability")
print("vim.filetype exists: " .. tostring(vim.filetype ~= nil))
if vim.filetype then
  print("vim.filetype.add exists: " .. tostring(type(vim.filetype.add) == "function"))
end

-- Test LSP protocol API
print_header("LSP Protocol API")
print("vim.lsp.protocol exists: " .. tostring(vim.lsp.protocol ~= nil))
if vim.lsp.protocol then
  print("vim.lsp.protocol.make_client_capabilities exists: " .. 
      tostring(type(vim.lsp.protocol.make_client_capabilities) == "function"))
  
  -- Test capability generation
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  print("Capabilities generated: " .. tostring(type(capabilities) == "table"))
  print("Sample capability fields:")
  print("  textDocument: " .. tostring(capabilities.textDocument ~= nil))
  if capabilities.textDocument then
    print("  completion: " .. tostring(capabilities.textDocument.completion ~= nil))
  end
end

-- Exit Neovim after displaying results
print("\nTest completed. Press Enter to exit...")
vim.fn.input("")
vim.cmd("quit!")