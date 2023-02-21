local global = {}
local home = os.getenv("HOME")
function global:load_variables()
	self.home = home
	self.vim_config_path = vim.fn.stdpath("config")
	self.plugins_installed_path = vim.fn.stdpath("data")
	self.tmp_dir = self.vim_config_path .. "/tmp/"
end

global:load_variables()

return global
