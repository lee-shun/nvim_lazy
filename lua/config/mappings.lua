--
-- Buildin Mapping
--
local wk = require("which-key")

-- comp
vim.keymap.set("i", "<cr>", '(pumvisible())?("\\<C-y>"):("\\<cr>")', { expr = true, noremap = true })
vim.keymap.set("i", "<Tab>", 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', { expr = true, noremap = true })
vim.keymap.set("i", "<S-Tab>", 'pumvisible() ? "\\<C-p>" : "\\<Tab>"', { expr = true, noremap = true })

-- quick
local quick_map = { "<leader>v", "<cmd>e ~/.config/nvim/init.lua<cr>", desc = "Edit personal VIMRC", nowait = false, remap = false }
wk.add(quick_map)

vim.keymap.set("n", "<C-h>", ":set hlsearch!<cr>", { noremap = true, silent = true })

-- window
vim.keymap.set("n", "<up>", ":resize +3<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<down>", ":resize -3<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<left>", ":vertical resize-5<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<right>", ":vertical resize+5<cr>", { noremap = true, silent = true })

-- change indent and select in v-mode
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })

-- add blank line and move line
wk.add(
    {
        { "[<leader>", ":<c-u>put! =repeat(nr2char(10), v:count1)<cr>'[", desc = "Add empty Line prev", nowait = false, remap = false },
        { "[e",        ":<c-u>execute 'move -1-'. v:count1<cr>",          desc = "Move line prev",      nowait = false, remap = false },
        { "]<leader>", ":<c-u>put =repeat(nr2char(10), v:count1)<cr>",    desc = "Add empty line next", nowait = false, remap = false },
        { "]e",        ":<c-u>execute 'move +'. v:count1<cr>",            desc = "Move line next",      nowait = false, remap = false },
    })

-- yank line
vim.keymap.set("n", "Y", "y$", { noremap = true })

-- greatest remap ever
vim.keymap.set("v", "<leader>p", '"_dP', { noremap = true })

-- move the chosen zone
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv", { noremap = true })
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv", { noremap = true })

-- place the cursor in the middle
vim.keymap.set("n", "J", "mzJ'z", { noremap = true })

-- terminal
vim.keymap.set("t", "<C-N>", "<C-\\><C-N>", { noremap = true })
