--
-- Builtin Mappings
--
local wk = require("which-key")

-- completion popup navigation
vim.keymap.set("i", "<cr>", function()
    return vim.v.pumvisible == 1 and "<C-y>" or "<cr>"
end, { expr = true, noremap = true })

vim.keymap.set("i", "<Tab>", function()
    return vim.v.pumvisible == 1 and "<C-n>" or "<Tab>"
end, { expr = true, noremap = true })

vim.keymap.set("i", "<S-Tab>", function()
    return vim.v.pumvisible == 1 and "<C-p>" or "<Tab>"
end, { expr = true, noremap = true })

-- quick
wk.add({
    { "<leader>v", "<cmd>e ~/.config/nvim/init.lua<cr>", desc = "Edit personal VIMRC" },
})

vim.keymap.set("n", "<C-h>", ":set hlsearch!<cr>", { noremap = true, silent = true })

-- window
vim.keymap.set("n", "<up>", ":resize +3<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<down>", ":resize -3<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<left>", ":vertical resize-5<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<right>", ":vertical resize+5<cr>", { noremap = true, silent = true })

-- change indent and reselect in visual mode
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })

-- add blank line and move line
wk.add({
    { "[<leader>", ":<c-u>put! =repeat(nr2char(10), v:count1)<cr>'[", desc = "Add empty line prev" },
    { "[e",        ":<c-u>execute 'move -1-'. v:count1<cr>",          desc = "Move line prev" },
    { "]<leader>", ":<c-u>put =repeat(nr2char(10), v:count1)<cr>",    desc = "Add empty line next" },
    { "]e",        ":<c-u>execute 'move +'. v:count1<cr>",            desc = "Move line next" },
})

-- yank to end of line
vim.keymap.set("n", "Y", "y$", { noremap = true })

-- greatest remap ever: paste without overwriting register
vim.keymap.set("v", "<leader>p", '"_dP', { noremap = true })

-- move selected lines
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", { noremap = true })
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv", { noremap = true })

-- place the cursor in the middle after J
vim.keymap.set("n", "J", "mzJ'z", { noremap = true })

-- terminal escape
vim.keymap.set("t", "<C-N>", "<C-\\><C-N>", { noremap = true })
