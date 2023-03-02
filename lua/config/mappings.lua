--
-- Buildin Mapping
--
local wk = require("which-key")

-- comp
vim.keymap.set("i", "<cr>", '(pumvisible())?("\\<C-y>"):("\\<cr>")', { expr = true, noremap = true })
vim.keymap.set("i", "<Tab>", 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', { expr = true, noremap = true })
vim.keymap.set("i", "<S-Tab>", 'pumvisible() ? "\\<C-p>" : "\\<Tab>"', { expr = true, noremap = true })

-- quick
local qucik_map = {
	["<leader>"] = { "<Esc>/<++><cr>:nohlsearch<cr>i<Del><Del><Del><Del>", "Search <++> and change" },
	v = { "<cmd>e ~/.config/nvim/init.lua<cr>", "Edit personal VIMRC" },
}
local quick_map_opt = {
	mode = "n",
	prefix = "<leader>",
	buffer = nil,
	silent = true,
	noremap = true,
	nowait = false,
}
wk.register(qucik_map, quick_map_opt)

vim.keymap.set("n", "<C-h>", ":set hlsearch!<cr>", { noremap = true , silent = true})

-- window
vim.keymap.set("n", "<up>", ":resize +3<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<down>", ":resize -3<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<left>", ":vertical resize-5<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<right>", ":vertical resize+5<cr>", { noremap = true, silent = true })

-- change indent and select in v-mode
vim.keymap.set("v", "<", "<gv", { noremap = true , silent = true})
vim.keymap.set("v", ">", ">gv", { noremap = true , silent = true})

-- add blank line and move line
wk.register({
	["[e"] = { ":<c-u>execute 'move -1-'. v:count1<cr>", "Move line prev" },
	["]e"] = { ":<c-u>execute 'move +'. v:count1<cr>", "Move line next" },
	["[<leader>"] = { ":<c-u>put! =repeat(nr2char(10), v:count1)<cr>'[", "Add empty Line prev" },
	["]<leader>"] = { ":<c-u>put =repeat(nr2char(10), v:count1)<cr>", "Add empty line next" },
}, {
	mode = "n",
	prefix = "",
	buffer = nil,
	silent = true,
	noremap = true,
	nowait = false,
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
