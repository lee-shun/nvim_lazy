-- 放于 ~/.local/share/nvim/site/plugin/zathura_cite.lua（symlink 到本文件）
-- nvim 只扫描 <rtp>/plugin/ 一层，故用 shim 加载嵌套插件项目
local root = "/home/ls/.local/share/nvim/site/zathura-cite"
vim.opt.rtp:prepend(root)
package.path = root .. "/plugin/?.lua;" .. package.path
require "zathura_cite"
