local nvim_config_path = vim.fn.stdpath("config")

-- Create cache dir and subs dir
local createdir = function()
    local tmp_data_dir = {
        nvim_config_path .. "/tmp/backup",
        nvim_config_path .. "/tmp/session",
        nvim_config_path .. "/tmp/swap",
        nvim_config_path .. "/tmp/tags",
        nvim_config_path .. "/tmp/undo",
    }
    -- There only check once that If cache_dir exists
    -- Then I don't want to check subs dir exists
    if vim.fn.isdirectory(nvim_config_path .. "/tmp") == 0 then
        os.execute("mkdir -p " .. nvim_config_path .. "/tmp")
        print("mkdir nvim tmp dir!")
        for _, v in pairs(tmp_data_dir) do
            if vim.fn.isdirectory(v) == 0 then
                os.execute("mkdir -p " .. v)
            end
        end
    end
end
createdir()

-- python
vim.g.python_host_prog = "/usr/bin/python"
vim.g.python3_host_prog = "/usr/bin/python3"

-- encode
vim.o.encoding = "utf-8"
vim.o.fileencodings = "ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1"
vim.o.fileformats = "unix,dos,mac"

-- basic
vim.cmd("filetype plugin indent on")
vim.cmd("syntax on")
vim.o.compatible = false
vim.g.mapleader = " "
vim.o.autochdir = false
vim.o.autoread = true
vim.o.scrolloff = 5
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.cursorcolumn = true
vim.o.colorcolumn = "81,121"
vim.o.textwidth = 80
vim.o.hidden = true
vim.o.showmode = true
vim.o.showcmd = true
vim.o.mouse = ""
vim.o.wrap = false
vim.o.linebreak = true
vim.o.timeout = true
vim.o.timeoutlen = 800
vim.o.updatetime = 800
vim.o.ttimeout = true
vim.o.ttimeoutlen = 10
vim.o.conceallevel = 0
vim.o.wildmenu = true
vim.o.lazyredraw = false
vim.o.laststatus = 3
vim.o.ttyfast = true
vim.o.termguicolors = true
vim.o.laststatus = 2
vim.o.cmdheight = 1
vim.o.statusline = "%#normal#"
vim.o.spelllang = "en,cjk"
vim.o.spellfile = nvim_config_path .. "/spell/en.utf-8.add"
vim.o.shiftround = true
vim.o.virtualedit = "block"

vim.o.inccommand = "split"

vim.o.showmatch = true
vim.opt.iskeyword:append("_,$,@,%,#")
vim.o.matchpairs = "(:),{:},[:],<:>"
vim.o.whichwrap = "b,s,<,>,[,]"

vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.cmd("nohlsearch")

vim.o.smartindent = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.smarttab = true
vim.o.expandtab = true
vim.o.shiftround = true

vim.o.foldmethod = "manual"
vim.o.foldenable = true
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

vim.o.list = true
vim.o.listchars = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←"
vim.o.showbreak = "↪"

vim.opt.clipboard:prepend("unnamed,unnamedplus")

vim.o.completeopt = "menuone,noselect,noinsert"
vim.opt.complete:append("k")

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.undofile = true
vim.o.swapfile = true
vim.o.backup = true
vim.o.undodir = nvim_config_path .. "/tmp/undo"
vim.o.backupdir = nvim_config_path .. "/tmp/backup"
vim.o.directory = nvim_config_path .. "/tmp/swap"
vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

vim.opt.wildignore:append("*.o,*.obj,*.bin,*.dll,*.exe")
vim.opt.wildignore:append("*/.git/*,*/.svn/*,*/__pycache__/*,*/build/**")
vim.opt.wildignore:append("*.pyc")
vim.opt.wildignore:append("*.DS_Store")
vim.opt.wildignore:append("*.aux,*.bbl,*.blg,*.brf,*.fls,*.fdb_latexmk,*.synctex.gz,*.pdf")

-- Disable some builtin vim plugins
local disabled_built_ins = {
    "2html_plugin",
    "getscript",
    "getscriptPlugin",
    "gzip",
    "logipat",
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
    "tar",
    "tarPlugin",
    "rrhelper",
    "vimball",
    "vimballPlugin",
    "zip",
    "zipPlugin",
    "matchit"
}

for _, plugin in pairs(disabled_built_ins) do
    vim.g["loaded_" .. plugin] = 1
end
