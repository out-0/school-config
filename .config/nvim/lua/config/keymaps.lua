-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Keymaps are automatically loaded on the VeryLazy event
local map = vim.keymap.set

-------------------------------------------------------------------------------
-- 1. CLEANUP: Disable LazyVim/Snacks Conflicts
-------------------------------------------------------------------------------
-- These are the ones that were hijacking your <leader>g
pcall(vim.keymap.del, { "n", "x" }, "<leader>gB")
pcall(vim.keymap.del, { "n", "x" }, "<leader>gY")

-------------------------------------------------------------------------------
-- 2. BASIC EDITS (The "Old" Logic)
-------------------------------------------------------------------------------
-- Move lines (Standard 42/LazyVim style)
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Up" })

-- Better Clipboard behavior
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Copy to System Clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Copy Line to System Clipboard" })

-------------------------------------------------------------------------------
-- 3. HARPOON (Modern require syntax)
-------------------------------------------------------------------------------
local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

map("n", "<leader>ha", function() mark.add_file() end, { desc = "Harpoon Add File" })
map("n", "<leader>ht", function() ui.toggle_quick_menu() end, { desc = "Harpoon Menu" })
map("n", "<leader>hn", function() ui.nav_next() end, { desc = "Harpoon Next" })
map("n", "<leader>hp", function() ui.nav_prev() end, { desc = "Harpoon Prev" })
map("n", "<leader>hd", function() mark.rm_file() end, { desc = "Harpoon Remove" })

-------------------------------------------------------------------------------
-- 4. GEMINI AI (The Overrider)
-------------------------------------------------------------------------------
-- Normal mode: Simple Chat
-- Added "&& exit" so the window closes when you type 'exit' or hit Ctrl+D
--map("n", "<leader>gc", "<cmd>vsplit | term gemini -i 'Fuck you' && exit<cr>", { desc = "Gemini: Open Chat" })

-- Visual mode: Explain Code
--map("x", "<leader>g", function()
    -- Yank selection
--    vim.cmd('noau normal! "vy')
--    local text = vim.fn.getreg("v")
    
    -- Strip characters that break the terminal command
--    text = text:gsub("'", ""):gsub("\n", " ")

    -- Launch Gemini with a direct prompt
    -- We add "&& exit" at the very end of the string inside the term command
--    local cmd = "vsplit | term gemini -i 'Briefly explain this code: " .. text .. "' && exit"
--    vim.cmd(cmd)
--
--    vim.cmd("startinsert")
--end, { desc = "Gemini: Explain Code" })


-- Terminal Mode: Allow Space + w + direction to switch windows
-- We use vim.keymap.set directly for better reliability in 't' mode
--vim.keymap.set("t", "<Space>wh", [[<C-\><C-n><C-w>h]], { desc = "Terminal: Move Left" })
--vim.keymap.set("t", "<Space>wj", [[<C-\><C-n><C-w>j]], { desc = "Terminal: Move Down" })
--vim.keymap.set("t", "<Space>wk", [[<C-\><C-n><C-w>k]], { desc = "Terminal: Move Up" })
--vim.keymap.set("t", "<Space>wl", [[<C-\><C-n><C-w>l]], { desc = "Terminal: Move Right" })

-- Also highly recommended: map Escape to exit terminal typing mode
-- This lets you use normal 'j/k' to scroll the Gemini output
--vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Terminal: Exit Insert Mode" })
