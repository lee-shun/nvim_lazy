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
    -- Only check once if cache_dir exists.
    -- If not, create tmp and all subdirectories.
    if vim.fn.isdirectory(nvim_config_path .. "/tmp") == 0 then
        vim.fn.mkdir(nvim_config_path .. "/tmp", "p")
        print("mkdir nvim tmp dir!")
        for _, v in ipairs(tmp_data_dir) do
            if vim.fn.isdirectory(v) == 0 then
                vim.fn.mkdir(v, "p")
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
-- localleader 用逗号（markdown-plus 等插件的 buffer 局部键前缀），不用双空格
vim.g.maplocalleader = ","
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
vim.o.laststatus = 2
vim.o.ttyfast = true
vim.o.termguicolors = true
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

vim.o.foldmethod = "manual"
vim.o.foldenable = true
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

vim.o.list = true
vim.o.listchars = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←"
vim.o.showbreak = "↪"

-- 剪切板策略（判定顺序见下）：
--   1) 外部 X/Wayland 工具“真的可用”（跑一次无害读取，timeout 2s 防卡）→ xclip / xsel / wl-clipboard
--   2) 在 tmux 里 → tmux 缓冲区（nvim 内置实现对 ≥3.2 用 load-buffer -w，会转发 OSC52 给外层终端）
--   3) 纯 ssh（无 tmux）→ OSC52（不起外部进程，永远不会有 xclip 报错）
--   4) 都不行 → &clipboard 保持空，只用内部寄存器
-- ⚠️ 关键：第 4 步绝不能留 unnamed/unnamedplus。nvim 内置 provider 的判定是
--   `!empty($DISPLAY) && executable('xclip')`（runtime/autoload/provider/clipboard.vim），
--   只看 DISPLAY 非空、不测可达性。tmux 里 DISPLAY 常是失效的 ssh X11 转发值
--   （如 localhost:10.0），此时一旦启用 clipboard，yy 就会报
--   "clipboard: error invoking xclip: Error: Can't open display: ..."。
-- 可用环境变量覆盖：NVIM_CLIPBOARD=xclip|xsel|wl-clipboard(=wl-copy)|tmux|osc52|none
local function clipboard_tool_ok(args)
    if vim.fn.executable(args[1]) == 0 then
        return false
    end
    local cmd = {}
    if vim.fn.executable("timeout") == 1 then
        cmd[1] = "timeout"
        cmd[2] = "2"
    end
    for i = 1, #args do
        cmd[#cmd + 1] = args[i]
    end
    local sys = vim.fn.system
    local ok = pcall(sys, cmd)
    return ok and vim.v.shell_error == 0
end

-- 强制指定剪切板后端（跨机器/远程场景用），非法值按自动判定处理
local clip_force = vim.env.NVIM_CLIPBOARD
local force_alias = { ["wl-copy"] = "wl-clipboard" } -- 两种写法都收，避免静默回落自动判定
local force_ok = {}
for _, v in ipairs({ "xclip", "xsel", "wl-clipboard", "wl-copy", "tmux", "osc52", "none" }) do
    force_ok[v] = true
end
if not force_ok[clip_force or ""] then
    clip_force = nil
end

local clip_tool = nil
if clip_force then
    clip_tool = force_alias[clip_force] or clip_force
elseif clipboard_tool_ok({ "xclip", "-selection", "clipboard", "-o" }) then
    clip_tool = "xclip"
elseif clipboard_tool_ok({ "xsel", "--primary", "--output" }) then
    clip_tool = "xsel"
elseif clipboard_tool_ok({ "wl-paste" }) then
    clip_tool = "wl-clipboard"
elseif vim.env.TMUX and clipboard_tool_ok({ "tmux", "list-buffers" }) then
    clip_tool = "tmux"
elseif (vim.env.TMUX or vim.env.SSH_TTY) then
    -- 没有任何可用外部工具，但在 tmux/ssh 会话里：OSC52 送到“你正在操作的那台机器”
    clip_tool = "osc52"
else
    clip_tool = "none"
end

if clip_tool == "xclip" then
    vim.g.clipboard = {
        name = "xclip",
        copy = {
            ["+"] = "xclip -selection clipboard",
            ["*"] = "xclip -selection primary",
        },
        paste = {
            ["+"] = "xclip -selection clipboard -o",
            ["*"] = "xclip -selection primary -o",
        },
        cache_enabled = 1,
    }
    vim.opt.clipboard:prepend("unnamedplus")
elseif clip_tool == "xsel" then
    vim.g.clipboard = {
        name = "xsel",
        copy = {
            ["+"] = "xsel --clipboard --input",
            ["*"] = "xsel --primary --input",
        },
        paste = {
            ["+"] = "xsel --clipboard --output",
            ["*"] = "xsel --primary --output",
        },
        cache_enabled = 1,
    }
    vim.opt.clipboard:prepend("unnamedplus")
elseif clip_tool == "wl-clipboard" then
    vim.g.clipboard = {
        name = "wl-clipboard",
        copy = {
            ["+"] = "wl-copy",
            ["*"] = "wl-copy --type text/plain",
        },
        paste = {
            ["+"] = "wl-paste",
            ["*"] = "wl-paste --type text/plain",
        },
        cache_enabled = 1,
    }
    vim.opt.clipboard:prepend("unnamedplus")
elseif clip_tool == "tmux" then
    -- 字符串形式：用 nvim 内置的 tmux 实现（copy: tmux load-buffer -w -；paste: tmux save-buffer -）
    -- 好处：paste 是本地命令，无 OSC52 查询延迟；copy 会顺带转发 OSC52 给外层终端
    vim.g.clipboard = "tmux"
    vim.opt.clipboard:prepend("unnamedplus")
elseif clip_tool == "osc52" then
    vim.g.clipboard = "osc52"
    vim.opt.clipboard:prepend("unnamedplus")
else
    -- 没有可用的外部剪切板：&clipboard 必须留空。
    -- 留 unnamed/unnamedplus 会让内置 provider 自己挑工具（见上面注释），失效 DISPLAY 下必报错。
end

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

-- Disable providers not needed (suppress healthcheck warnings)
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

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
