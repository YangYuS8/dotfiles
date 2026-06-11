-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

map({ "n", "i", "x", "s" }, "<C-s>", function()
  vim.cmd.write()
end, { desc = "Save File" })

map("n", "<C-p>", function()
  Snacks.picker.files({ cwd = LazyVim.root() })
end, { desc = "Find Files (VS Code)" })

map("n", "<C-S-p>", function()
  Snacks.picker.commands()
end, { desc = "Command Palette (VS Code)" })

map("n", "<C-b>", function()
  Snacks.picker.explorer({ cwd = LazyVim.root() })
end, { desc = "Explorer (VS Code)" })

map("n", "<C-S-f>", function()
  Snacks.picker.grep({ cwd = LazyVim.root() })
end, { desc = "Search in Files (VS Code)" })

map({ "n", "t" }, "<C-`>", function()
  Snacks.terminal.focus(nil, { cwd = LazyVim.root() })
end, { desc = "Terminal (VS Code)" })

map("n", "<C-/>", function()
  Snacks.terminal(nil, { cwd = LazyVim.root() })
end, { desc = "Terminal (Root Dir)" })

map("n", "<C-_>", function()
  Snacks.terminal(nil, { cwd = LazyVim.root() })
end, { desc = "Terminal (Root Dir)" })

map("n", "<F2>", function()
  vim.lsp.buf.rename()
end, { desc = "Rename Symbol" })

map({ "n", "x" }, "<C-.>", function()
  vim.lsp.buf.code_action()
end, { desc = "Code Action" })

map({ "n", "x" }, "<leader>.", function()
  vim.lsp.buf.code_action()
end, { desc = "Code Action" })

map("n", "<leader>Go", function()
  vim.lsp.buf.code_action({
    apply = true,
    context = { only = { "source.organizeImports" }, diagnostics = {} },
  })
end, { desc = "Go: Organize Imports" })

map("n", "<F5>", function()
  require("dap").continue()
end, { desc = "Debug: Start/Continue" })

map("n", "<S-F5>", function()
  require("dap").terminate()
end, { desc = "Debug: Stop" })

map("n", "<F9>", function()
  require("dap").toggle_breakpoint()
end, { desc = "Debug: Toggle Breakpoint" })

map("n", "<F10>", function()
  require("dap").step_over()
end, { desc = "Debug: Step Over" })

map("n", "<F11>", function()
  require("dap").step_into()
end, { desc = "Debug: Step Into" })

map("n", "<S-F11>", function()
  require("dap").step_out()
end, { desc = "Debug: Step Out" })

map("n", "<leader>Gt", function()
  require("neotest").run.run()
end, { desc = "Go: Test Nearest" })

map("n", "<leader>GT", function()
  require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "Go: Test File" })

map("n", "<leader>Gd", function()
  require("neotest").run.run({ strategy = "dap" })
end, { desc = "Go: Debug Nearest Test" })
