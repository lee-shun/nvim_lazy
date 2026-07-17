---Build and run core functionality module.
---Used by plugins/run.lua via `require("util.build")`.
---Depends on toggleterm.nvim (installed externally).

local M = {}

-- ==================== History Management ====================
-- Persistent history for user inputs
local history = {
	cmake_args = {},
	ros2_pkg = {},
	ros2_node = {},
	gpp_args = {},
}

---Load history from a JSON file in stdpath("data").
local function load_history()
	local path = vim.fn.stdpath("data") .. "/build_history.json"
	local f = io.open(path, "r")
	if f then
		local content = f:read("*a")
		f:close()
		local ok, data = pcall(vim.json.decode, content)
		if ok and type(data) == "table" then
			history = vim.tbl_deep_extend("force", history, data)
		end
	end
end

---Save history to a JSON file.
local function save_history()
	local path = vim.fn.stdpath("data") .. "/build_history.json"
	local f = io.open(path, "w")
	if f then
		f:write(vim.json.encode(history))
		f:close()
	end
end

-- Load on module init
load_history()

---Get input with history navigation (Up/Down arrows).
---@param opts table vim.ui.input options
---@param hist_list string[] history list to browse
---@param callback function(value?)
local function input_with_history(opts, hist_list, callback)
	hist_list = hist_list or {}
	local hist_idx = #hist_list + 1 -- start at "new entry" position

	-- Wrap the callback to save to history
	local function wrapped_callback(value)
		-- value is nil when user cancels (Esc/Ctrl-C)
		-- value is "" when user presses Enter with empty input
		-- Only save non-empty values to history
		if value and value ~= "" then
			if hist_list[#hist_list] ~= value then
				table.insert(hist_list, value)
				save_history()
			end
		end
		if callback then
			callback(value)
		end
	end

	-- Intercept Up/Down in the input buffer via temporary autocmd
	local augroup = vim.api.nvim_create_augroup("BuildInputHistory", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = augroup,
		pattern = "*",
		once = true,
		callback = function(args)
			local buf = args.buf
			if vim.api.nvim_buf_line_count(buf) <= 3 then
				vim.keymap.set({ "i", "n" }, "<Up>", function()
					if hist_idx > 1 then
						hist_idx = hist_idx - 1
						local val = hist_list[hist_idx] or ""
						vim.api.nvim_buf_set_lines(buf, 0, -1, false, { val })
						vim.api.nvim_win_set_cursor(0, { 1, #val })
					end
				end, { buffer = buf, silent = true })

				vim.keymap.set({ "i", "n" }, "<Down>", function()
					if hist_idx < #hist_list then
						hist_idx = hist_idx + 1
						local val = hist_list[hist_idx] or ""
						vim.api.nvim_buf_set_lines(buf, 0, -1, false, { val })
						vim.api.nvim_win_set_cursor(0, { 1, #val })
					elseif hist_idx == #hist_list then
						hist_idx = #hist_list + 1
						vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })
						vim.api.nvim_win_set_cursor(0, { 1, 0 })
					end
				end, { buffer = buf, silent = true })
			end
		end,
	})

	vim.ui.input(opts, wrapped_callback)
end

---Get the last used CMake args, or empty string.
---@return string
function M.get_last_cmake_args()
	return history.cmake_args[#history.cmake_args] or ""
end

---Get the last used g++ args, or empty string.
---@return string
function M.get_last_gpp_args()
	return history.gpp_args[#history.gpp_args] or ""
end

-- ==================== Terminal Execution ====================

---Run a command in a named toggleterm terminal.
---@param name string Display name for the terminal
---@param cmd string Command to execute
---@param cwd? string Working directory
---@return table term The toggleterm Terminal instance
function M.run_in_terminal(name, cmd, cwd)
	local Terminal = require("toggleterm.terminal").Terminal
	local term = Terminal:new({
		cmd = cmd,
		dir = cwd,
		display_name = name,
		direction = "float",
		close_on_exit = false,
		on_open = function()
			vim.cmd("startinsert!")
		end,
	})
	term:toggle()
	return term
end

-- ==================== Build Functions ====================

---Smart build: auto-detect project type and build with optional custom args.
---@param project table The util.project module
function M.build(project)
	local ok, ros2_root = project.is_ros2_workspace()
	if ok then
		input_with_history(
			{ prompt = "Colcon args (Enter for default): ", default = M.get_last_cmake_args() },
			history.cmake_args,
			function(args)
				-- Cancelled (Esc/Ctrl-C): do nothing
				if args == nil then
					return
				end
				local cmd = "colcon build --symlink-install --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo"
				if args ~= "" then
					cmd = cmd .. " " .. args
				end
				M.run_in_terminal("ROS2 Build", cmd, ros2_root)
			end
		)
		return
	end

	local cmake_ok, cmake_root = project.is_cmake_project()
	if cmake_ok then
		input_with_history(
			{ prompt = "CMake args (Enter for default): ", default = M.get_last_cmake_args() },
			history.cmake_args,
			function(args)
				if args == nil then
					return
				end
				vim.fn.mkdir(cmake_root .. "/build", "p")
				local cmd = "cmake -B build -S . -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo"
				if args ~= "" then
					cmd = cmd .. " " .. args
				end
				cmd = cmd .. " && cmake --build build -j$(nproc)"
				M.run_in_terminal("CMake Build", cmd, cmake_root)
			end
		)
		return
	end

	local ft = vim.bo.filetype
	if ft == "c" or ft == "cpp" then
		input_with_history(
			{ prompt = "g++ args (Enter for default): ", default = M.get_last_gpp_args() },
			history.gpp_args,
			function(args)
				if args == nil then
					return
				end
				local file = vim.fn.expand("%:p")
				local out = vim.fn.expand("%:p:r")
				local cc = (ft == "c") and "gcc" or "g++"
				local std = (ft == "c") and "c11" or "c++17"
				local cmd = string.format("%s -std=%s -Wall -Wextra -g -O2", cc, std)
				if args ~= "" then
					cmd = cmd .. " " .. args
				end
				cmd = string.format("%s %s -o %s", cmd, file, out)
				M.run_in_terminal("Single File Build", cmd, vim.fn.expand("%:p:h"))
			end
		)
		return
	end

	vim.notify("No build system found", vim.log.levels.WARN)
end

---Build in Debug mode with optional custom args.
---@param project table The util.project module
function M.build_debug(project)
	local ok, ros2_root = project.is_ros2_workspace()
	if ok then
		input_with_history(
			{ prompt = "Colcon args (Enter for default): ", default = M.get_last_cmake_args() },
			history.cmake_args,
			function(args)
				if args == nil then
					return
				end
				local cmd = "colcon build --symlink-install --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Debug"
				if args ~= "" then
					cmd = cmd .. " " .. args
				end
				M.run_in_terminal("ROS2 Build (Debug)", cmd, ros2_root)
			end
		)
		return
	end

	local cmake_ok, cmake_root = project.is_cmake_project()
	if cmake_ok then
		input_with_history(
			{ prompt = "CMake args (Enter for default): ", default = M.get_last_cmake_args() },
			history.cmake_args,
			function(args)
				if args == nil then
					return
				end
				vim.fn.mkdir(cmake_root .. "/build", "p")
				local cmd = "cmake -B build -S . -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Debug"
				if args ~= "" then
					cmd = cmd .. " " .. args
				end
				cmd = cmd .. " && cmake --build build -j$(nproc)"
				M.run_in_terminal("CMake Build (Debug)", cmd, cmake_root)
			end
		)
		return
	end

	local ft = vim.bo.filetype
	if ft == "c" or ft == "cpp" then
		input_with_history(
			{ prompt = "g++ args (Enter for default): ", default = M.get_last_gpp_args() },
			history.gpp_args,
			function(args)
				if args == nil then
					return
				end
				local file = vim.fn.expand("%:p")
				local out = vim.fn.expand("%:p:r")
				local cc = (ft == "c") and "gcc" or "g++"
				local std = (ft == "c") and "c11" or "c++17"
				local cmd = string.format("%s -std=%s -Wall -Wextra -g -O0", cc, std)
				if args ~= "" then
					cmd = cmd .. " " .. args
				end
				cmd = string.format("%s %s -o %s", cmd, file, out)
				M.run_in_terminal("Single File Build (Debug)", cmd, vim.fn.expand("%:p:h"))
			end
		)
		return
	end

	vim.notify("No build system found", vim.log.levels.WARN)
end

---Build with the last used arguments (repeat last build).
---@param project table The util.project module
function M.build_last(project)
	local last_cmake = M.get_last_cmake_args()
	local last_gpp = M.get_last_gpp_args()

	local ok, ros2_root = project.is_ros2_workspace()
	if ok then
		local cmd = "colcon build --symlink-install --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo"
		if last_cmake ~= "" then
			cmd = cmd .. " " .. last_cmake
		end
		M.run_in_terminal("ROS2 Build (Last)", cmd, ros2_root)
		return
	end

	local cmake_ok, cmake_root = project.is_cmake_project()
	if cmake_ok then
		vim.fn.mkdir(cmake_root .. "/build", "p")
		local cmd = "cmake -B build -S . -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo"
		if last_cmake ~= "" then
			cmd = cmd .. " " .. last_cmake
		end
		cmd = cmd .. " && cmake --build build -j$(nproc)"
		M.run_in_terminal("CMake Build (Last)", cmd, cmake_root)
		return
	end

	local ft = vim.bo.filetype
	if ft == "c" or ft == "cpp" then
		local file = vim.fn.expand("%:p")
		local out = vim.fn.expand("%:p:r")
		local cc = (ft == "c") and "gcc" or "g++"
		local std = (ft == "c") and "c11" or "c++17"
		local cmd = string.format("%s -std=%s -Wall -Wextra -g -O2", cc, std)
		if last_gpp ~= "" then
			cmd = cmd .. " " .. last_gpp
		end
		cmd = string.format("%s %s -o %s", cmd, file, out)
		M.run_in_terminal("Single File Build (Last)", cmd, vim.fn.expand("%:p:h"))
		return
	end

	vim.notify("No build system found", vim.log.levels.WARN)
end

---Clean build artifacts.
---@param project table The util.project module
function M.clean(project)
	local cmake_ok, cmake_root = project.is_cmake_project()
	if cmake_ok then
		M.run_in_terminal("CMake Clean", "rm -rf build && echo \"Cleaned build/\"", cmake_root)
		return
	end

	local ft = vim.bo.filetype
	if ft == "c" or ft == "cpp" then
		local out = vim.fn.expand("%:p:r")
		M.run_in_terminal(
			"Single File Clean",
			string.format("rm -f %s && echo \"Cleaned %s\"", out, out),
			vim.fn.expand("%:p:h")
		)
		return
	end

	vim.notify("Nothing to clean", vim.log.levels.WARN)
end

-- ==================== Run Functions ====================

---Run the built executable.
---@param project table The util.project module
function M.run(project)
	local ok, ros2_root = project.is_ros2_workspace()
	if ok then
		input_with_history(
			{ prompt = "Package: " },
			history.ros2_pkg,
			function(pkg)
				if pkg == nil then
					return
				end
				if pkg == "" then
					vim.notify("Package name cannot be empty", vim.log.levels.WARN)
					return
				end
				input_with_history(
					{ prompt = "Node: " },
					history.ros2_node,
					function(node)
						if node == nil then
							return
						end
						if node == "" then
							vim.notify("Node name cannot be empty", vim.log.levels.WARN)
							return
						end
						M.run_in_terminal("ROS2 Run", string.format("ros2 run %s %s", pkg, node), ros2_root)
					end
				)
			end
		)
		return
	end

	local cmake_ok, cmake_root = project.is_cmake_project()
	if cmake_ok then
		local exes = vim.fn.systemlist(string.format("find %s/build -maxdepth 2 -type f -executable 2>/dev/null", cmake_root))
		if #exes == 0 then
			vim.notify("No executable found in build/", vim.log.levels.WARN)
			return
		end
		vim.ui.select(exes, { prompt = "Select executable:" }, function(exe)
			if exe then
				M.run_in_terminal("CMake Run", exe, cmake_root)
			end
		end)
		return
	end

	local ft = vim.bo.filetype
	if ft == "c" or ft == "cpp" then
		local out = vim.fn.expand("%:p:r")
		if vim.fn.filereadable(out) ~= 1 then
			vim.notify("Not built yet. Press <leader>rb first.", vim.log.levels.WARN)
			return
		end
		M.run_in_terminal("Run", out, vim.fn.expand("%:p:h"))
		return
	end

	vim.notify("No executable to run", vim.log.levels.WARN)
end

---Build and run the current single file (C/C++ only).
function M.build_and_run()
	local ft = vim.bo.filetype
	if ft ~= "c" and ft ~= "cpp" then
		vim.notify("Build & Run only for single C/C++ files", vim.log.levels.WARN)
		return
	end
	local file = vim.fn.expand("%:p")
	local out = vim.fn.expand("%:p:r")
	local cc = (ft == "c") and "gcc" or "g++"
	local std = (ft == "c") and "c11" or "c++17"
	M.run_in_terminal(
		"Build & Run",
		string.format("%s -std=%s -Wall -Wextra -g -O2 %s -o %s && %s", cc, std, file, out, out),
		vim.fn.expand("%:p:h")
	)
end

---Run with command-line arguments.
---@param project table The util.project module
function M.run_with_args(project)
	local cmake_ok, cmake_root = project.is_cmake_project()
	local cwd = cmake_root or vim.fn.expand("%:p:h")
	local target = nil

	if cmake_ok then
		local exes = vim.fn.systemlist(string.format("find %s/build -maxdepth 2 -type f -executable 2>/dev/null", cmake_root))
		if #exes > 0 then
			vim.ui.select(exes, { prompt = "Select executable:" }, function(exe)
				if not exe then
					return
				end
				vim.ui.input({ prompt = "Arguments: " }, function(args)
					if args == nil then
						return
					end
					if args ~= "" then
						M.run_in_terminal("Run with args", string.format("%s %s", exe, args), cwd)
					else
						M.run_in_terminal("Run", exe, cwd)
					end
				end)
			end)
			return
		end
	end

	local ft = vim.bo.filetype
	if ft == "c" or ft == "cpp" then
		target = vim.fn.expand("%:p:r")
		if vim.fn.filereadable(target) ~= 1 then
			vim.notify("Not built yet. Press <leader>rb first.", vim.log.levels.WARN)
			return
		end
	end

	if not target then
		vim.notify("No executable to run", vim.log.levels.WARN)
		return
	end

	vim.ui.input({ prompt = "Arguments: " }, function(args)
		if args == nil then
			return
		end
		if args ~= "" then
			M.run_in_terminal("Run with args", string.format("%s %s", target, args), cwd)
		else
			M.run_in_terminal("Run", target, cwd)
		end
	end)
end

-- ==================== Terminal Management ====================

---Toggle the toggleterm terminal.
function M.toggle_terminal()
	require("toggleterm").toggle(1)
end

---Kill all open toggleterm terminals.
function M.kill_terminal()
	local terms = require("toggleterm.terminal").get_all()
	for _, term in ipairs(terms) do
		if term:is_open() then
			term:shutdown()
		end
	end
end

-- ==================== Debug Support (nvim-dap) ====================

---Debug a CMake target (requires nvim-dap + cpptools).
---@param project table The util.project module
function M.debug_cmake(project)
	local dap = require("dap")
	local ok, cmake_root = project.is_cmake_project()
	if not ok then
		vim.notify("Not in a CMake project", vim.log.levels.WARN)
		return
	end

	local exes = vim.fn.systemlist(string.format("find %s/build -maxdepth 2 -type f -executable 2>/dev/null", cmake_root))
	if #exes == 0 then
		vim.notify("No executable found in build/", vim.log.levels.WARN)
		return
	end

	vim.ui.select(exes, { prompt = "Debug target:" }, function(exe)
		if not exe then
			return
		end
		dap.run({
			type = "cppdbg",
			request = "launch",
			name = "Debug",
			program = exe,
			cwd = cmake_root,
			stopOnEntry = false,
		})
	end)
end

---Debug the current single file (requires nvim-dap + cpptools).
function M.debug_single_file()
	local dap = require("dap")
	local ft = vim.bo.filetype
	if ft ~= "c" and ft ~= "cpp" then
		vim.notify("Debug only for C/C++ files", vim.log.levels.WARN)
		return
	end
	local out = vim.fn.expand("%:p:r")
	if vim.fn.filereadable(out) ~= 1 then
		vim.notify("Not built yet. Build with <leader>rb first.", vim.log.levels.WARN)
		return
	end
	dap.run({
		type = "cppdbg",
		request = "launch",
		name = "Debug",
		program = out,
		cwd = vim.fn.expand("%:p:h"),
		stopOnEntry = false,
	})
end

-- ==================== Auto Commands ====================

---Set up auto-build on save for single files outside of projects.
---@param project table The util.project module
function M.setup_autocmds(project)
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = vim.api.nvim_create_augroup("AutoBuild", { clear = true }),
		pattern = { "*.c", "*.cpp" },
		callback = function()
			local cmake_ok = project.is_cmake_project()
			local ros2_ok = project.is_ros2_workspace()
			if not cmake_ok and not ros2_ok then
				local file = vim.fn.expand("%:p")
				local out = vim.fn.expand("%:p:r")
				local cc = vim.bo.filetype == "c" and "gcc" or "g++"
				local std = vim.bo.filetype == "c" and "c11" or "c++17"
				vim.fn.jobstart(string.format("%s -std=%s -Wall -g -O2 %s -o %s", cc, std, file, out))
			end
		end,
	})
end

return M
