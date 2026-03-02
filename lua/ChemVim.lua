local M = {}

function M.setup()
  vim.api.nvim_create_user_command("ProcessParameters", function()
    vim.notify("ChemVim Process", vim.log.levels.INFO)
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local streams = {}

    for _, line in ipairs(lines) do
	
        for capture in string.gmatch(line, "--%[(.-)%]%-%->") do
  	    vim.notify(capture, vim.log.levels.INFO)  -- prints "S1-i"
    	    local name, direction = string.match(capture, "(.-)%-(.+)")
            table.insert(streams, { name = name, direction = direction })
        end
    end
    local json = vim.fn.json_encode(streams)
    vim.notify(json, vim.log.levels.INFO)
    --vim.notify(vim.inspect(streams), vim.log.levels.INFO)
  end, {})
end


return M
