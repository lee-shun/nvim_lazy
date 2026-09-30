return {
	"obsidian-nvim/obsidian.nvim",
	lazy = true,
	version = "*",
	-- 只在 vault 存在的机器上启用（如 61 无 ~/knowledge_library 时自动禁用，避免启动报错）
	cond = vim.fn.isdirectory(vim.fn.expand("~/knowledge_library")) == 1,
	ft = "markdown",
	dependencies = {
		-- Required.
		"nvim-lua/plenary.nvim",
	},
	opts = {
		legacy_commands = false,
		workspaces = {
			{
				name = "knowledge_library",
				path = "~/knowledge_library",
			},
		},
		new_notes_location = "current_dir",
		ui = {
			enable = false,
		},
		note_id_func = function(title)
			if not title then
				return "untitled"
			end
			local s = title
				-- 替换各类空白为下划线
				:gsub("%s+", "_")
				:gsub("　", "_") -- 全角空格
				-- 移除文件系统非法字符
				:gsub('[\\/:*?"<>|%%#&{}~+]', "")
				-- 处理中文标点（提升可读性）
				:gsub("（", "_")
				:gsub("）", "")
				:gsub("、", "_")
				:gsub("，", "_")
				:gsub("。", "")
				-- 清理多余下划线
				:gsub("_+", "_")
				:gsub("^_+", "")
				:gsub("_+$", "")
			return s == "" and "untitled" or s
		end,
		-- 用内置 markdown 链接 + relative 格式，替代之前手写的 link.style：
		-- 旧实现拿 basename 当 vault 相对路径去 find_workspace，会崩/丢失子目录/丢锚点。
		-- format="relative" 生成相对当前笔记的路径（如 ../subdir/note.md），并保留 #anchor/#block。
		-- 想要 Obsidian 默认"最短文件名"链接就删掉下面 format 这行。
		link = {
			style = "markdown",
			format = "relative",
		},
		templates = {
			folder = ".obsidian_template",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M:%S",
		},
		-- 保存时自动写入的 frontmatter 由模板驱动（见 util/obsidian_frontmatter）：
		-- 字段集合/顺序/占位符值都读自 templates.folder 的模板，模板改了自动同步。
		-- id/aliases/tags 用笔记实时值；date/created 等已有值不覆盖（set-once）。
		frontmatter = {
			sort = function(a, b)
				return require("util.obsidian_frontmatter").sort(a, b)
			end,
			func = function(note)
				return require("util.obsidian_frontmatter").func(note)
			end,
		},
		-- 知识库里有大量 C/C++ 代码（markdown 里未加 fence 的行首 #include/#endif 等），
		-- obsidian.nvim 的 tag 解析会把它们当成 tag。这里在 setup 后包一层 parse.tags.extract，
		-- 过滤掉 C/C++ 预处理器指令，避免 :Obsidian tags 误匹配。
		-- 黑名单取"明确是预处理器指令、且基本不会当 tag 用"的词；
		-- 有意不含 error/warning/line（它们更可能是正经 tag），需要时再补。
		callbacks = {
			post_setup = function()
				local tags = require("obsidian.parse.tags")
				local orig_extract = tags.extract
				local cpp_directive = {
					include = true, define = true, ifdef = true, ifndef = true,
					["else"] = true, elif = true, endif = true, undef = true, pragma = true,
				}
				tags.extract = function(line, opts)
					local out = orig_extract(line, opts)
					local res = {}
					for _, m in ipairs(out) do
						if not cpp_directive[m.tag] then
							res[#res + 1] = m
						end
					end
					return res
				end
			end,
		},
	},
}
