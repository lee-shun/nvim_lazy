local wk = require("which-key")

--
-- Buildin Mapping
--

-- comp
vim.keymap.set("i", "<CR>", '(pumvisible())?("\\<C-y>"):("\\<cr>")', { expr = true, noremap = true })
vim.keymap.set("i", "<Tab>", 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', { expr = true, noremap = true })
vim.keymap.set("i", "<S-Tab>", 'pumvisible() ? "\\<C-p>" : "\\<Tab>"', { expr = true, noremap = true })

-- quick
local qucik_map = {
	["<leader>"] = { "<Esc>/<++><CR>:nohlsearch<CR>i<Del><Del><Del><Del>", "Search <++> and change" },
	c = { "<cmd> e ~/.config/nvim/init.lua<CR>", "Edit personal VIMRC" },
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

vim.keymap.set("n", "<C-h>", ":set hlsearch!<CR>", { noremap = true })

-- window
vim.keymap.set("n", "<up>", ":resize +3<CR>", { noremap = true })
vim.keymap.set("n", "<down>", ":resize -3<CR>", { noremap = true })
vim.keymap.set("n", "<left>", ":vertical resize-5<CR>", { noremap = true })
vim.keymap.set("n", "<right>", ":vertical resize+5<CR>", { noremap = true })

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
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { noremap = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { noremap = true })

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
	["s"] = { ":TranslateW<CR>", "Translate" },
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
	["t"] = { ":NvimTreeToggle<CR>", "NvimTreeToggle" },
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
		b = { "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", "Toggle breakpoint" },
		B = {
			"<Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
			"Set cond breakpoint",
		},
		c = { "<Cmd>lua require'dap'.continue()<CR>", "Continue" },
		s = { "<Cmd>lua require'dap'.close()<CR>", "Close" },
		i = { "<Cmd>lua require'dap'.step_into()<CR>", "Step into" },
		v = { "<Cmd>lua require'dap'.step_over()<CR>", "Step over" },
		o = { "<Cmd>lua require'dap'.step_out()<CR>", "Step out" },
		u = { "<cmd>lua require('dapui').toggle()<CR>", "DapUI toggle" },
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
		f = { "<Cmd> Telescope find_files<CR>", "Find file" },
		b = { "<Cmd> Telescope buffers<CR>", "Find buffers" },
		m = { "<Cmd> Telescope oldfiles<CR>", "Find most recent files" },
		w = { "<Cmd> Telescope live_grep<CR>", "Find word" },
		l = { "<Cmd> Telescope current_buffer_fuzzy_find<CR>", "Find line in current buffer" },
		r = { "<Cmd> Telescope registers<CR>", "Find registers" },
		d = { "<Cmd> Telescope diagnostics<CR>", "Find diagnostics" },
		j = { "<Cmd> Telescope jumplist<CR>", "Find jumplist" },
		y = { "<Cmd> Telescope yank_history<CR>", "Find yank history" },
		t = { "<Cmd> Telescope find_template<CR>", "Find file templates" },
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
	["<F12>"] = { "<cmd>ToggleTerm<CR>", "Toggle term" },
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
	b = { "<cmd> lua require('yabs'):run_task('build')<CR>", "Build task" },
	r = { "<cmd> lua require('yabs'):run_task('run')<CR>", "Run task" },
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
	[[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
	kopts
)
vim.api.nvim_set_keymap(
	"n",
	"N",
	[[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
	kopts
)
vim.api.nvim_set_keymap("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap("n", "g*", [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap("n", "g#", [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)
