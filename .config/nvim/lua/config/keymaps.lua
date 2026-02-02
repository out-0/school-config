local map = vim.keymap.set

-- 1. Disable LazyVim/Snacks Conflicts
pcall(vim.keymap.del, { "n", "x" }, "<leader>gB")
pcall(vim.keymap.del, { "n", "x" }, "<leader>gY")

-- 2. Basic Edits (Move lines & Clipboard)
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Up" })
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Copy to System Clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Copy Line to System Clipboard" })

-- 3. Harpoon 2 Keymaps (SAFE CHECK)
local status_ok, harpoon = pcall(require, "harpoon")
if status_ok then
    -- Basic Navigation
    map("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Harpoon: Add File" })
    map("n", "<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon: Menu" })
    
    -- Quick Select (Leader + 1, 2, 3, 4)
    map("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon: File 1" })
    map("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon: File 2" })
    map("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon: File 3" })
    map("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon: File 4" })
end

-- 4. Python/Ruff Format
map("n", "<leader>cf", function()
  vim.lsp.buf.format({ name = "ruff" })
  print("🧹 Code cleaned via Ruff")
end, { desc = "Format Py with Ruff" })
