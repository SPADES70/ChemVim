local M = {}

local results_buf = nil
local results_win = nil

function M.open_results_window()
	-- close stale window
	if results_win and vim.api.nvim_win_is_valid(results_win) then
		vim.api.nvim_win_close(results_win, true)
	end

	-- new scratch buffer
	results_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(results_buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(results_buf, "filetype", "chemvim_results")

	-- vertical split on the right
	vim.cmd("vsplit")
	results_win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(results_win, results_buf)
	vim.api.nvim_win_set_width(results_win, 45)

	-- go back to params window
	vim.cmd("wincmd p")
	return results_buf
end 


function M.render_results(result)
	local buf = M.open_results_window()
	local lines = {}

	if result.error then
		table.insert(lines, " ERROR")
		table.insert(lines, " " .. result.error)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		return
	end

	local unit = result.unit or "REACTOR"
	table.insert(lines, "")
	table.insert(lines, "  ⚗️  " .. unit .. " RESULTS")
	table.insert(lines, " " .. string.rep("-", 36))
	table.insert(lines, "")
	table.insert(lines, string.format(" Conversion (X)    : %.4f (%.1f%%)",
		result.conversion_X, result.conversion_X * 100))
	table.insert(lines, string.format("  Ca out               : %.4f mol/L",
		result.Ca_out_mol_L))
	table.insert(lines, string.format("  Residence time (τ)   : %.4f s",
		result.residence_time_s))
	table.insert(lines, string.format("  Reactor volume       : %.2f L",
		result.reactor_volume_L))
	table.insert(lines, "")

	if result.unit == "CSTR" then 
		local rate = result.reaction_rate
		local pct = string.format("%.1f%%", result.conversion_X * 100) 
		
		table.insert(lines, " Operating Point:")
		table.insert(lines, " " .. string.rep("-", 36))
		table.insert(lines, string.format("  Reaction rate (r)    : %.4f mol/L·s", rate))
		table.insert(lines, "")
		table.insert(lines, "  Reactor Diagram:")
		table.insert(lines, "  " .. string.rep("-", 36))
		table.insert(lines, string.format("       Feed (Ca0=%.2f mol/L)", result.Ca0 or 0))
		table.insert(lines,               "           │")
		table.insert(lines,               "           ▼")
		table.insert(lines,               "     ┌───────────┐")
		table.insert(lines,               "     │  ~~~~~~~  │")
		table.insert(lines,               "     │  ~~~~~~~  │──→ Ca out")
		table.insert(lines,               "     │ (well mix)│")
		table.insert(lines,               "     └───────────┘")
		table.insert(lines, string.format("          X = %s", pct))
		table.insert(lines, "")
	end

	table.insert(lines, " " .. string.rep("-", 36))
	table.insert(lines, " [q] close ")
	table.insert(lines, "")

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":lua require('chemvim.display').close()<CR>",
		{ noremap = true, silent = true })
end

function M.close()
  if results_win and vim.api.nvim_win_is_valid(results_win) then
    vim.api.nvim_win_close(results_win, true)
  end
end

return M
