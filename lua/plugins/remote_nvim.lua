return {
	"amitds1997/remote-nvim.nvim",
	version = "*",
	cmd = { "RemoteInfo", "RemoteStart" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		require("remote-nvim").setup({
			-- ===== 离线模式（最关键！RK3588 可能连不上 GitHub） =====
			offline_mode = {
				-- enabled = true,
				-- no_github = true, -- 完全不访问 GitHub，全靠本地缓存
				-- cache_dir = vim.fn.stdpath("cache") .. "/remote-nvim.nvim/version_cache",
			},

			-- ===== 远程配置同步 =====
			remote = {
				app_name = "nvim", -- 远程的 NVIM_APPNAME
				copy_dirs = {
					-- 1) 同步整个 nvim 配置（你的 lua/、init.lua 等）
					config = {
						base = vim.fn.stdpath("config"),
						dirs = "*",
						compression = { enabled = true },
					},
					-- 2) 同步 lazy 插件目录（避免远程重新下载插件）
					data = {
						base = vim.fn.stdpath("data"),
						dirs = { "lazy" },
						compression = {
							enabled = true,
							additional_opts = { "--exclude-vcs" },
						},
					},
				},
			},
		})
	end,
}
