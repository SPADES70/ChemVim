local M = {}

function M.setup()
  vim.api.nvim_create_user_command("ProcessParameters", function()
    vim.notify("ChemVim Process", vim.log.levels.INFO)
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local streams = {}
    local unitops = {}

    for linedx, line in ipairs(lines) do
	
        for capture in string.gmatch(line, "--%[(.-)%]%-%->") do
  	    vim.notify(capture, vim.log.levels.INFO)  -- prints "S1-i"
    	    local name, direction = string.match(capture, "(.-)%-(.+)")
            table.insert(streams, { name = name, direction = direction })
        end
	local start_col, end_col = string.find(line,"%+%-*%+")
	if start_col and lines[linedx+1] then
		local label = string.match(lines[linedx+1], "%|%s*(.-)%s*%|")
		if label then
    			local unitop_type, unitop_id = string.match(label, "(.-)%-(.+)")

			table.insert(unitops, {unitop_type = unitop_type, unitop_id=unitop_id}) 
		end
	end
    end
    local stream_json = vim.fn.json_encode(streams)
    vim.notify(stream_json, vim.log.levels.INFO)
    local op_json = vim.fn.json_encode(unitops)
    vim.notify(op_json, vim.log.levels.INFO)
    --vim.notify(vim.inspect(streams), vim.log.levels.INFO)
  end, {})
end


return M
