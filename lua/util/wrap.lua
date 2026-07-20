-- Generic text wrapping helpers for normal and visual modes.
-- Requires Neovim >= 0.9 (uses vim.v.maxcol).
-- Assumes 'selection' is "inclusive" (the default).

local M = {}

-- ---------------------------------------------------------------------------
-- Byte/char helpers (UTF-8 safe)
-- ---------------------------------------------------------------------------

---Return the full (possibly multi-byte) char starting at 1-based byte col.
---@param line string
---@param col1 integer 1-based byte column
---@return string
local function char_at(line, col1)
	if col1 < 1 or col1 > #line then
		return ""
	end
	return vim.fn.strcharpart(line:sub(col1), 0, 1)
end

---Extend a 1-based byte col to the LAST byte of the char starting there.
---Returns col1 - 1 when col1 points past the line (i.e. "no char").
---@param line string
---@param col1 integer
---@return integer
local function char_end_col(line, col1)
	local ch = char_at(line, col1)
	if ch == "" then
		return col1 - 1
	end
	return col1 + #ch - 1
end

---Convert a 1-based virtual (screen) column to a 1-based byte column.
---Returns #line + 1 when the vcol is past the end of the line.
---@param line string
---@param vcol integer
---@return integer
local function vcol_to_byte(line, vcol)
	if vcol <= 1 then
		return 1
	end
	local scol = 1 -- current virtual column (1-based)
	local byte = 1
	while byte <= #line do
		local ch = char_at(line, byte)
		if ch == "" then
			break
		end
		local w = vim.fn.strdisplaywidth(ch, scol - 1)
		if scol + w - 1 >= vcol then
			return byte
		end
		scol = scol + w
		byte = byte + #ch
	end
	return #line + 1
end

---Clamp a {row, col0} cursor so it sits on an actual character.
---@param row integer 1-based
---@param col0 integer 0-based
---@return integer, integer
local function clamp_cursor(row, col0)
	local llen = #(vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or "")
	col0 = math.min(math.max(col0, 0), math.max(llen - 1, 0))
	return row, col0
end

-- ---------------------------------------------------------------------------
-- Normal mode
-- ---------------------------------------------------------------------------

---Wrap the character under the cursor (multi-byte safe).
---@param pattern string e.g. "\\boldsymbol"
local function wrap_normal(pattern)
	local row, col = require("util.buffer").cursor_pos() -- 0-based row/col
	local line = vim.api.nvim_get_current_line()
	local char = char_at(line, col + 1)
	if char == "" then
		return
	end
	local wrapped = pattern .. "{" .. char .. "}"
	vim.api.nvim_buf_set_text(0, row, col, row, col + #char, { wrapped })
end

-- ---------------------------------------------------------------------------
-- Visual block mode (rectangle per line, virtual-column aware)
-- Cursor target: end of the block on the CURSOR's row (the closing "}").
-- ---------------------------------------------------------------------------

---@param pattern string
---@param start_pos table getpos("v") result
---@param end_pos table getpos(".") result (cursor corner)
---@return integer, integer cursor {row(1-based), col(0-based)}
local function wrap_block(pattern, start_pos, end_pos)
	local s_row, e_row = start_pos[2], end_pos[2]
	if s_row > e_row then
		s_row, e_row = e_row, s_row
	end

	local cur_row, cur_col = end_pos[2], end_pos[3] -- the "last" corner

	-- Rectangle edges are defined by VIRTUAL columns, not byte columns.
	local sv = vim.fn.virtcol("v")
	local ev = vim.fn.virtcol(".")
	if sv > ev then
		sv, ev = ev, sv
	end

	-- "<C-V>$" sets curswant to maxcol: extend each row to end of line.
	local to_eol = (vim.fn.getcurpos()[5] == vim.v.maxcol)

	-- Default: cursor stays at its corner (used if its row is skipped).
	local ret_row, ret_col = clamp_cursor(cur_row, cur_col - 1)

	for lnum = e_row, s_row, -1 do
		local line = (vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false))[1] or ""

		local s_byte = vcol_to_byte(line, sv)
		if s_byte <= #line then -- empty/short lines are skipped
			local e_byte
			if to_eol then
				e_byte = #line
			else
				e_byte = math.min(char_end_col(line, vcol_to_byte(line, ev)), #line)
			end

			if s_byte <= e_byte then
				local selected = line:sub(s_byte, e_byte)
				local wrapped = pattern .. "{" .. selected .. "}"
				vim.api.nvim_buf_set_text(0, lnum - 1, s_byte - 1, lnum - 1, e_byte, { wrapped })

				if lnum == cur_row then
					-- "pattern{" (#pattern + 1 bytes) was inserted before the
					-- block, so the block end shifts right by that amount.
					ret_row, ret_col = clamp_cursor(cur_row, e_byte + #pattern + 1)
				end
			end
		end
	end

	return ret_row, ret_col
end

-- ---------------------------------------------------------------------------
-- Visual line mode (wrap each line independently, skip empty lines)
-- Cursor target: start of the LAST selected line.
-- ---------------------------------------------------------------------------

---@param pattern string
---@param start_line integer 1-based
---@param end_line integer 1-based
---@return integer, integer cursor {row(1-based), col(0-based)}
local function wrap_line(pattern, start_line, end_line)
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end

	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
	if #lines == 0 then
		return end_line, 0
	end

	for i, content in ipairs(lines) do
		if content ~= "" then
			lines[i] = pattern .. "{" .. content .. "}"
		end
		-- empty lines are left untouched
	end

	vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
	return end_line, 0 -- first column of the last selected line
end

-- ---------------------------------------------------------------------------
-- Visual char mode (selection as one unit, multi-byte safe)
-- Cursor target: end of the wrapped region (the closing "}").
-- ---------------------------------------------------------------------------

---@param pattern string
---@param start_pos table getpos("v") result
---@param end_pos table getpos(".") result
---@return integer, integer cursor {row(1-based), col(0-based)}
local function wrap_char(pattern, start_pos, end_pos)
	local s_row, s_col = start_pos[2], start_pos[3]
	local e_row, e_col = end_pos[2], end_pos[3]
	if s_row > e_row or (s_row == e_row and s_col > e_col) then
		s_row, e_row = e_row, s_row
		s_col, e_col = e_col, s_col
	end

	local lines = vim.api.nvim_buf_get_lines(0, s_row - 1, e_row, false)
	if #lines == 0 then
		return clamp_cursor(e_row, e_col - 1)
	end

	-- Extend the end column so the LAST selected char is taken whole.
	local last_line = lines[#lines]
	local e_end = char_end_col(last_line, math.min(e_col, #last_line))

	local pieces = {}
	for i, content in ipairs(lines) do
		local lnum = s_row + i - 1
		local line_start = (lnum == s_row) and math.min(s_col, #content + 1) or 1
		local line_end = (lnum == e_row) and e_end or #content
		if line_start <= line_end then
			pieces[#pieces + 1] = content:sub(line_start, line_end)
		else
			pieces[#pieces + 1] = ""
		end
	end

	local wrapped = pattern .. "{" .. table.concat(pieces, "\n") .. "}"
	local wrapped_lines = vim.split(wrapped, "\n", { plain = true })

	local s_start = math.min(s_col, #lines[1] + 1)
	vim.api.nvim_buf_set_text(0, s_row - 1, s_start - 1, e_row - 1, e_end, wrapped_lines)

	-- End of the inserted region = last wrapped line, at its final char ("}").
	local end_row = s_row + #wrapped_lines - 1
	local end_col0 = #wrapped_lines[#wrapped_lines] - 1
	return clamp_cursor(end_row, end_col0)
end

-- ---------------------------------------------------------------------------
-- Entry point
-- ---------------------------------------------------------------------------

---Wrap the current cursor char / selection with a LaTeX-like pattern.
---Supports normal, visual-char, visual-line and visual-block modes.
---@param pattern string
function M.wrap_selection(pattern)
	local mode = vim.fn.mode()

	if mode == "n" then
		wrap_normal(pattern)
		return -- no <Esc> needed in normal mode
	end

	local is_visual = mode:sub(1, 1) == "v" or mode == "V" or mode == "\22"
	if not is_visual then
		return
	end

	local start_pos = vim.fn.getpos("v")
	local end_pos = vim.fn.getpos(".")

	local cur_row, cur_col
	if mode == "\22" then
		cur_row, cur_col = wrap_block(pattern, start_pos, end_pos)
	elseif mode == "V" then
		cur_row, cur_col = wrap_line(pattern, start_pos[2], end_pos[2])
	else
		cur_row, cur_col = wrap_char(pattern, start_pos, end_pos)
	end

	-- Park the cursor at the mode-specific target, then leave visual mode.
	pcall(vim.api.nvim_win_set_cursor, 0, { cur_row, cur_col })
	local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
	vim.api.nvim_feedkeys(esc, "n", false)
end

return M
