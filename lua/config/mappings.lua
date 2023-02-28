local wk = require("which-key")

--
-- Buildin Mapping
--

-- comp
vim.keymap.set("i", "<cr>", '(pumvisible())?("\\<C-y>"):("\\<cr>")', { expr = true, noremap = true })
vim.keymap.set("i", "<Tab>", 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', { expr = true, noremap = true })
vim.keymap.set("i", "<S-Tab>", 'pumvisible() ? "\\<C-p>" : "\\<Tab>"', { expr = true, noremap = true })

-- quick
local qucik_map = {
	["<leader>"] = { "<Esc>/<++><cr>:nohlsearch<cr>i<Del><Del><Del><Del>", "Search <++> and change" },
	c = { "<cmd>e ~/.config/nvim/init.lua<cr>", "Edit personal VIMRC" },
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

vim.keymap.set("n", "<C-h>", ":set hlsearch!<cr>", { noremap = true })

-- window
vim.keymap.set("n", "<up>", ":resize +3<cr>", { noremap = true })
vim.keymap.set("n", "<down>", ":resize -3<cr>", { noremap = true })
vim.keymap.set("n", "<left>", ":vertical resize-5<cr>", { noremap = true })
vim.keymap.set("n", "<right>", ":vertical resize+5<cr>", { noremap = true })

-- change indent and select in v-mode
vim.keymap.set("v", "<", "<gv", { noremap = true })
vim.keymap.set("v", ">", ">gv", { noremap = true })

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
vim.keymap.set("n", "n", "nzzzv", { noremap = true })
vim.keymap.set("n", "N", "Nzzzv", { noremap = true })
vim.keymap.set("n", "J", "mzJ'z", { noremap = true })

-- terminal
vim.keymap.set("t", "<C-N>", "<C-\\><C-N>", { noremap = true })

--
-- Plugin Mappings
--

-- translate
wk.register({
	["s"] = { "<cmd>TranslateW<cr>", "Translate" },
}, {
	mode = "n",
	prefix = "<leader>",
	buffer = nil,
	silent = true,
	noremap = true,
	nowait = false,
})

-- nvim tree
wk.register({
	["t"] = { "<cmd>NvimTreeToggle<cr>", "NvimTreeToggle" },
}, {
	mode = "n",
	prefix = "<leader>",
	buffer = nil,
	silent = true,
	noremap = true,
	nowait = false,
})

-- easy align
wk.register({
	g = {
		a = { "<Plug>(EasyAlign)", "Easy align" },
	},
}, {

	mode = "n",
	prefix = "",
	buffer = nil,
	silent = true,
	noremap = true,
	nowait = false,
})
wk.register({
	g = {
		a = { "<Plug>(EasyAlign)", "Easy align" },
	},
}, {

	mode = "v",
	prefix = "",
	buffer = nil,
	silent = true,
	noremap = true,
	nowait = false,
})

-- dap
local dap_map = {
	d = {
		name = "Nvim Dap",
		b = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Toggle breakpoint" },
		B = {
			"<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>",
			"Set cond breakpoint",
		},
		c = { "<cmd>lua require'dap'.continue()<cr>", "Continue" },
		s = { "<cmd>lua require'dap'.close()<cr>", "Close" },
		i = { "<cmd>lua require'dap'.step_into()<cr>", "Step into" },
		v = { "<cmd>lua require'dap'.step_over()<cr>", "Step over" },
		o = { "<cmd>lua require'dap'.step_out()<cr>", "Step out" },
		u = { "<cmd>lua require('dapui').toggle()<cr>", "DapUI toggle" },
	},
}
local dap_map_opt = {
	mode = "n",
	prefix = "<leader>",
	buffer = nil,
	silent = true,
	noremap = true,
	nowait = false,
}
wk.register(dap_map, dap_map_opt)

-- telescope
local tel_map = {
	f = {
		name = "Find",
		f = { "<cmd>Telescope find_files<cr>", "Find file" },
		b = { "<cmd>Telescope buffers<cr>", "Find buffers" },
		m = { "<cmd>Telescope oldfiles<cr>", "Find most recent files" },
		w = { "<cmd>Telescope live_grep<cr>", "Find word" },
		l = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Find line in current buffer" },
		r = { "<cmd>Telescope registers<cr>", "Find registers" },
		d = { "<cmd>Telescope diagnostics<cr>", "Find diagnostics" },
		j = { "<cmd>Telescope jumplist<cr>", "Find jumplist" },
		y = { "<cmd>Telescope yank_history<cr>", "Find yank history" },
		t = { "<cmd>Telescope find_template<cr>", "Find file templates" },
	},
}
local tel_map_opt = {
	mode = "n",
	prefix = "<leader>",
	buffer = nil,
	silent = true,
	noremap = true,
	nowait = false,
}
wk.register(tel_map, tel_map_opt)

-- term
wk.register({
	["<F12>"] = { "<cmd>ToggleTerm<cr>", "Toggle term" },
}, {
	mode = "n",
	prefix = "",
	buffer = nil,
	silent = true,
	noremap = true,
	nowait = false,
})

-- yabs.nvim
local yabs_map_opt = {
	mode = "n",
	prefix = "<leader>r",
	buffer = nil,
	silent = true,
	noremap = true,
	nowait = false,
}
local yabs_map = {
	name = "Task runner",
	b = { "<cmd>lua require('yabs'):run_task('build')<cr>", "Build task" },
	r = { "<cmd>lua require('yabs'):run_task('run')<cr>", "Run task" },
}
wk.register(yabs_map, yabs_map_opt)

-- yanky
vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")
vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")

-- hllens
local kopts = { noremap = true, silent = true }

vim.api.nvim_set_keymap(
	"n",
	"n",
	[[<cmd>execute('normal! ' . v:count1 . 'n')<cr><cmd>lua require('hlslens').start()<cr>]],
	kopts
)
vim.api.nvim_set_keymap(
	"n",
	"N",
	[[<cmd>execute('normal! ' . v:count1 . 'N')<cr><cmd>lua require('hlslens').start()<cr>]],
	kopts
)
vim.api.nvim_set_keymap("n", "*", [[*<cmd>lua require('hlslens').start()<cr>]], kopts)
vim.api.nvim_set_keymap("n", "#", [[#<cmd>lua require('hlslens').start()<cr>]], kopts)
vim.api.nvim_set_keymap("n", "g*", [[g*<cmd>lua require('hlslens').start()<cr>]], kopts)
vim.api.nvim_set_keymap("n", "g#", [[g#<cmd>lua require('hlslens').start()<cr>]], kopts)
