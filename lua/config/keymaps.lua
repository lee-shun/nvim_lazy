-- Global keymaps (buffer-local keymaps live in lua/lang/).
-- Loaded after plugins so which-key is available.

local wk = require("which-key")

-- ─────────────────────────────────────────────────────────────
-- Insert mode: popup/completion navigation
-- ─────────────────────────────────────────────────────────────
vim.keymap.set("i", "<cr>", function()
    return vim.v.pumvisible == 1 and "<C-y>" or "<cr>"
end, { expr = true, noremap = true, desc = "✅ Confirm popup or insert CR" })

vim.keymap.set("i", "<Tab>", function()
    return vim.v.pumvisible == 1 and "<C-n>" or "<Tab>"
end, { expr = true, noremap = true, desc = "⬇️ Next popup item or Tab" })

vim.keymap.set("i", "<S-Tab>", function()
    return vim.v.pumvisible == 1 and "<C-p>" or "<Tab>"
end, { expr = true, noremap = true, desc = "⬆️ Previous popup item or Tab" })

-- ─────────────────────────────────────────────────────────────
-- Quick access
-- ─────────────────────────────────────────────────────────────
wk.add({
    { "<leader>v", "<cmd>e ~/.config/nvim/init.lua<cr>", desc = "⚙️ Edit Vimrc" },
})

vim.keymap.set("n", "<C-h>", ":set hlsearch!<cr>", { noremap = true, silent = true, desc = "🔍 Toggle search highlight" })

-- ─────────────────────────────────────────────────────────────
-- Window resizing
-- ─────────────────────────────────────────────────────────────
vim.keymap.set("n", "<up>",    ":resize +3<cr>",          { noremap = true, silent = true, desc = "🔲 Increase window height" })
vim.keymap.set("n", "<down>",  ":resize -3<cr>",          { noremap = true, silent = true, desc = "🔲 Decrease window height" })
vim.keymap.set("n", "<left>",  ":vertical resize-5<cr>",  { noremap = true, silent = true, desc = "🔲 Decrease window width" })
vim.keymap.set("n", "<right>", ":vertical resize+5<cr>",  { noremap = true, silent = true, desc = "🔲 Increase window width" })

-- ─────────────────────────────────────────────────────────────
-- Visual mode: keep selection after indent
-- ─────────────────────────────────────────────────────────────
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true, desc = "⬅️ Decrease indent and reselect" })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true, desc = "➡️ Increase indent and reselect" })

-- ─────────────────────────────────────────────────────────────
-- Add blank lines and move lines
-- ─────────────────────────────────────────────────────────────
wk.add({
    { "[<leader>", ":<c-u>put! =repeat(nr2char(10), v:count1)<cr>'[", desc = "⬆️ Add empty line above" },
    { "[<space>",  ":<c-u>put! =repeat(nr2char(10), v:count1)<cr>'[", desc = "⬆️ Add empty line above" },
    { "[e",        ":<c-u>execute 'move -1-'. v:count1<cr>",        desc = "⬆️ Move line up" },
    { "]<leader>", ":<c-u>put =repeat(nr2char(10), v:count1)<cr>",   desc = "⬇️ Add empty line below" },
    { "]<space>",  ":<c-u>put =repeat(nr2char(10), v:count1)<cr>",   desc = "⬇️ Add empty line below" },
    { "]e",        ":<c-u>execute 'move +'. v:count1<cr>",          desc = "⬇️ Move line down" },
})

-- ─────────────────────────────────────────────────────────────
-- Yank / paste / join improvements
-- ─────────────────────────────────────────────────────────────
vim.keymap.set("n", "Y", "y$", { noremap = true, desc = "📋 Yank to end of line" })

-- Paste in visual mode without overwriting the default register
vim.keymap.set("v", "<leader>p", '"_dP', { noremap = true, desc = "📋 Paste (no overwrite)" })

-- Move selected lines up/down
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", { noremap = true, desc = "⬇️ Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv", { noremap = true, desc = "⬆️ Move selection up" })

-- Keep cursor centered after J
vim.keymap.set("n", "J", "mzJ'z", { noremap = true, desc = "🔗 Join lines and restore cursor" })

-- ─────────────────────────────────────────────────────────────
-- Terminal escape
-- ─────────────────────────────────────────────────────────────
vim.keymap.set("t", "<C-N>", "<C-\\><C-N>", { noremap = true, desc = "🔙 Exit terminal insert mode" })

-- ─────────────────────────────────────────────────────────────
-- Centralized leader group definitions
-- ─────────────────────────────────────────────────────────────
-- Keep all top-level <leader> groups in one place so descriptions
-- and icons stay consistent across plugins.
local wk = require("which-key")
wk.add({
    { "<leader>a", group = "🤖 Avante" },
    { "<leader>b", group = "📑 Buffer" },
    { "<leader>c", group = "🛠️ Code" },
    { "<leader>d", group = "🐛 Debug" },
    { "<leader>f", group = "🔍 Find" },
    { "<leader>g", group = "🐙 Git" },
    { "<leader>l", group = "📡 LSP" },
    { "<leader>m", group = "✍️ Markdown" },
    { "<leader>n", group = "🔔 Notifications" },
    { "<leader>o", group = "💻 Opencode" },
    { "<leader>r", group = "▶️ Run" },
    { "<leader>s", group = "🧱 Surround" },
    { "<leader>t", group = "📁 File Explorer" },
    { "<leader>u", group = "🔄 Undo" },
    { "<leader>x", group = "📐 TeX / Typst" },
})
