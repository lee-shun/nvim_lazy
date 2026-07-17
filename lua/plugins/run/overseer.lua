-- lua/plugins/run/overseer.lua
-- overseer.nvim 完整配置
-- 支持：ROS2 colcon / CMake / 单文件 g++ 的 构建 + 运行

local project = require("util.project")

-- Project detection helpers are provided by util.project for reuse by other plugins.

-- ==================== 构建函数 ====================
local function smart_build()
	local overseer = require("overseer")
	local ros2_ok, _ = project.is_ros2_workspace()
	if ros2_ok then
		overseer.run_task({ name = "ROS2: colcon build" })
		return
	end
	local cmake_ok, _ = project.is_cmake_project()
	if cmake_ok then
		overseer.run_task({ name = "CMake: build" })
		return
	end
	local ft = vim.bo.filetype
	if ft == "c" or ft == "cpp" then
		overseer.run_task({ name = "Single file: g++" })
		return
	end
	vim.notify("No suitable build template found", vim.log.levels.WARN)
end

-- ==================== 运行函数（修复顺序：ROS2 → CMake → 单文件） ====================
local function run_executable()
	local overseer = require("overseer")

	-- 1. ROS2
	local ros2_ok, ws_root = project.is_ros2_workspace()
	if ros2_ok then
		vim.ui.input({ prompt = "ROS2 package name: " }, function(pkg)
			if not pkg or pkg == "" then
				return
			end
			vim.ui.input({ prompt = "Node/executable name: " }, function(node)
				if not node or node == "" then
					return
				end
				overseer
					.new_task({
						name = "ros2 run: " .. pkg .. " " .. node,
						cmd = { "ros2", "run", pkg, node },
						cwd = ws_root,
						components = { "default" },
					})
					:start()
			end)
		end)
		return
	end

	-- 2. CMake（在单文件之前检测，确保项目内的 .cpp 文件走 CMake 分支）
	local cmake_ok, proj_root = project.is_cmake_project()
	if cmake_ok then
		vim.ui.input({ prompt = "Executable path in build/ (e.g. my_app or src/main): " }, function(name)
			if not name or name == "" then
				return
			end
			local exe = proj_root .. "/build/" .. name
			if vim.fn.filereadable(exe) ~= 1 then
				vim.notify("Executable not found: " .. exe, vim.log.levels.WARN)
				return
			end
			overseer
				.new_task({
					name = "run: " .. vim.fn.fnamemodify(name, ":t"),
					cmd = { exe },
					cwd = proj_root,
					components = { "default" },
				})
				:start()
		end)
		return
	end

	-- 3. 单文件（只有不在 CMake/ROS2 项目内时才走这里）
	local ft = vim.bo.filetype
	if ft == "c" or ft == "cpp" then
		local outfile = vim.fn.expand("%:p:r")
		if vim.fn.filereadable(outfile) ~= 1 then
			vim.notify("Executable not found: " .. outfile .. "\nBuild first with <leader>rb", vim.log.levels.WARN)
			return
		end
		overseer
			.new_task({
				name = "run: " .. vim.fn.expand("%:t:r"),
				cmd = { outfile },
				cwd = vim.fn.expand("%:p:h"),
				components = { "default" },
			})
			:start()
		return
	end

	vim.notify("No executable to run in current context", vim.log.levels.WARN)
end

-- ==================== 编译并运行（单文件专用） ====================
local function build_and_run()
	local ft = vim.bo.filetype
	if ft ~= "c" and ft ~= "cpp" then
		vim.notify("Build & Run only for single C/C++ files", vim.log.levels.WARN)
		return
	end
	local overseer = require("overseer")
	overseer.run_task({ name = "Single file: g++ & run" })
end

-- ==================== 任务管理函数 ====================
local function rerun_last()
	local overseer = require("overseer")
	local task_list = require("overseer.task_list")
	local tasks = overseer.list_tasks({
		status = { overseer.STATUS.SUCCESS, overseer.STATUS.FAILURE, overseer.STATUS.CANCELED },
		sort = task_list.sort_finished_recently,
	})
	if vim.tbl_isempty(tasks) then
		vim.notify("No tasks found", vim.log.levels.WARN)
		return
	end
	overseer.run_action(tasks[1], "restart")
end

local function cancel_running()
	local overseer = require("overseer")
	local tasks = overseer.list_tasks({ status = overseer.STATUS.RUNNING })
	if vim.tbl_isempty(tasks) then
		vim.notify("No running tasks", vim.log.levels.WARN)
		return
	end
	for _, task in ipairs(tasks) do
		task:stop()
	end
end

local function dispose_all()
	local overseer = require("overseer")
	local tasks = overseer.list_tasks({})
	for _, task in ipairs(tasks) do
		task:dispose()
	end
end

local function open_output()
	local overseer = require("overseer")
	local running = overseer.list_tasks({ status = overseer.STATUS.RUNNING })
	if not vim.tbl_isempty(running) then
		running[1]:open_output("float")
		return
	end
	local all = overseer.list_tasks({})
	if not vim.tbl_isempty(all) then
		all[1]:open_output("float")
		return
	end
	vim.notify("No tasks found", vim.log.levels.WARN)
end

local function select_build_template()
	local overseer = require("overseer")
	local templates = {
		{ name = "ROS2: colcon build", desc = "Build ROS2 workspace" },
		{ name = "CMake: build", desc = "Build CMake project" },
		{ name = "Single file: g++", desc = "Compile current file" },
		{ name = "Single file: g++ & run", desc = "Compile and run current file" },
	}
	vim.ui.select(templates, {
		prompt = "Select build template:",
		format_item = function(item)
			return string.format("%-28s %s", item.name, item.desc)
		end,
	}, function(choice)
		if choice then
			overseer.run_task({ name = choice.name })
		end
	end)
end

-- ==================== Lazy.nvim 插件定义 ====================
return {
	{
		"stevearc/overseer.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"folke/which-key.nvim",
		},
		cmd = {
			"OverseerRun",
			"OverseerToggle",
			"OverseerShell",
			"OverseerTaskAction",
		},
		keys = {
			{ "<leader>rb", smart_build, desc = "Smart Build" },
			{ "<leader>rB", select_build_template, desc = "Select Template" },
			{ "<leader>rr", run_executable, desc = "Run Executable" },
			{ "<leader>rR", build_and_run, desc = "Build & Run (single file)" },
			{ "<leader>ro", "<cmd>OverseerToggle<CR>", desc = "Toggle Task List" },
			{ "<leader>rl", rerun_last, desc = "Rerun Last Task" },
			{ "<leader>rc", cancel_running, desc = "Cancel Running" },
			{ "<leader>rd", dispose_all, desc = "Dispose All" },
			{ "<leader>rq", open_output, desc = "Open Output" },
		},
		config = function()
			local overseer = require("overseer")

			overseer.setup({
				task_list = {
					direction = "bottom",
					max_width = { 110, 0.4 },
					min_width = { 40, 0.2 },
					max_height = { 20, 0.2 },
					min_height = 8,
					bindings = {
						["q"] = "Close",
						["<C-l>"] = "IncreaseDetail",
						["<C-h>"] = "DecreaseDetail",
						["<C-k>"] = "ScrollOutputUp",
						["<C-j>"] = "ScrollOutputDown",
						["<C-r>"] = "Restart",
						["<C-d>"] = "Dispose",
					},
				},
				component_aliases = {
					default = {
						"on_exit_set_status",
						"on_complete_notify",
						{ "on_complete_dispose", timeout = 300 },
					},
				},
			})

			overseer.register_template({
				name = "ROS2: colcon build",
				builder = function()
					local _, ws_root = project.is_ros2_workspace()
					return {
						name = "colcon build",
						cmd = { "colcon" },
						args = {
							"build",
							"--symlink-install",
							"--cmake-args",
							"-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
							"-DCMAKE_BUILD_TYPE=RelWithDebInfo",
						},
						cwd = ws_root,
						components = {
							{ "on_output_quickfix", open = true, open_height = 8 },
							"default",
						},
					}
				end,
			})

			overseer.register_template({
				name = "CMake: build",
				builder = function()
					local _, proj_root = project.is_cmake_project()
					local build_dir = proj_root .. "/build"
					vim.fn.mkdir(build_dir, "p")
					return {
						name = "cmake build",
						cmd = { "bash" },
						args = {
							"-c",
							string.format(
								"cmake -B %s -S %s -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo && cmake --build %s -j$(nproc)",
								build_dir,
								proj_root,
								build_dir
							),
						},
						cwd = proj_root,
						components = {
							{ "on_output_quickfix", open = true, open_height = 8 },
							"default",
						},
					}
				end,
			})

			overseer.register_template({
				name = "Single file: g++",
				builder = function()
					local file = vim.fn.expand("%:p")
					local ext = vim.fn.expand("%:e")
					local outfile = vim.fn.expand("%:p:r")
					local compiler = (ext == "c") and "gcc" or "g++"
					local std = (ext == "c") and "c11" or "c++17"
					return {
						name = compiler .. " " .. vim.fn.expand("%:t"),
						cmd = { compiler },
						args = { "-std=" .. std, "-Wall", "-Wextra", "-g", "-O2", file, "-o", outfile },
						cwd = vim.fn.expand("%:p:h"),
						components = {
							{ "on_output_quickfix", open = true, open_height = 8 },
							"default",
						},
					}
				end,
			})

			overseer.register_template({
				name = "Single file: g++ & run",
				builder = function()
					local file = vim.fn.expand("%:p")
					local ext = vim.fn.expand("%:e")
					local outfile = vim.fn.expand("%:p:r")
					local compiler = (ext == "c") and "gcc" or "g++"
					local std = (ext == "c") and "c11" or "c++17"
					return {
						name = compiler .. " & run " .. vim.fn.expand("%:t"),
						cmd = { "bash" },
						args = {
							"-c",
							string.format(
								"%s -std=%s -Wall -Wextra -g -O2 %s -o %s && %s",
								compiler,
								std,
								file,
								outfile,
								outfile
							),
						},
						cwd = vim.fn.expand("%:p:h"),
						components = {
							{ "on_output_quickfix", open = true, open_height = 8 },
							"default",
						},
					}
				end,
			})

			overseer.clear_task_cache()

			local wk = require("which-key")
			wk.add({
				{ "<leader>r", group = "Run/Build", icon = { icon = "󱓞", color = "blue" } },
				{ "<leader>rb", desc = "Smart Build", icon = { icon = "󰙵", color = "green" } },
				{ "<leader>rB", desc = "Select Template", icon = { icon = "󰋙", color = "yellow" } },
				{ "<leader>rr", desc = "Run Executable", icon = { icon = "󰜎", color = "cyan" } },
				{ "<leader>rR", desc = "Build & Run", icon = { icon = "󰓦", color = "orange" } },
				{ "<leader>ro", desc = "Task List", icon = { icon = "󰙵", color = "blue" } },
				{ "<leader>rl", desc = "Rerun Last", icon = { icon = "󰜉", color = "purple" } },
				{ "<leader>rc", desc = "Cancel Running", icon = { icon = "󰜺", color = "red" } },
				{ "<leader>rd", desc = "Dispose All", icon = { icon = "󰩹", color = "grey" } },
				{ "<leader>rq", desc = "Open Output", icon = { icon = "󰌵", color = "green" } },
			})
		end,
	},
}
