local M = {}
local current_buf = nil

local function generate_template(streams, unitops)
  local lines = {}

  table.insert(lines, "STREAMS")
  for _,stream in ipairs(streams) do
	table.insert(lines, stream.name)
	table.insert(lines, stream.direction)
	table.insert(lines, "Flowrate: ")
	table.insert(lines, "Components: ")
	table.insert(lines, '--------')
  end
  table.insert(lines, "UNIT OPS")
  for _,unitop in ipairs(unitops) do
	table.insert(lines, unitop.unitop_type)
	table.insert(lines, unitop.unitop_id)
	table.insert(lines, "Volume: ")
	table.insert(lines, "Reaction: ")
	table.insert(lines, "Rate Constant: ")
	table.insert(lines, '--------')
  end

  return lines
end

local function read_diagram()
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

  return streams, unitops
end

local function parse_params_buffer(lines)
  local streams = {}
  local unitops = {}
  local section = nil
  local current = nil

  for _, line in ipairs(lines) do
    if line == "STREAMS" then
      section = "streams"
    elseif line == "UNIT OPS" then
      section = "unitops"
    elseif line == "--------" then
      if current and section == "streams" then
        table.insert(streams, current)
      elseif current and section == "unitops" then
        table.insert(unitops, current)
      end
      current = nil
    elseif section == "streams" then
      if current == nil then
        current = { name = line }
      elseif current.direction == nil then
        current.direction = line
      else
        local flowrate = string.match(line, "Flowrate:%s*(.+)")
        if flowrate then current.flowrate = flowrate end
        local components = string.match(line, "Components:%s*(.+)")
        if components then current.components = components end
      end
    elseif section == "unitops" then
      if current == nil then
        current = { unitop_type = line }
      elseif current.unitop_id == nil then
        current.unitop_id = line
      else
        local volume = string.match(line, "Volume:%s*(.+)")
        if volume then current.volume = volume end
        local reaction = string.match(line, "Reaction:%s*(.+)")
        if reaction then current.reaction = reaction end
        local rate = string.match(line, "Rate Constant:%s*(.+)")
        if rate then current.rate_constant = rate end
      end
    end
  end

  return streams, unitops
end

function M.setup()
  vim.api.nvim_create_user_command("SetParameters", function()
    vim.notify("ChemVim Process", vim.log.levels.INFO)
  local streams, unitops = read_diagram()
  local temp_buffer = generate_template(streams, unitops)
  current_buf = vim.api.nvim_create_buf(false, true)  -- unlisted, scratch buffer
  vim.api.nvim_buf_set_lines(current_buf, 0, -1, false, temp_buffer)
  vim.api.nvim_open_win(current_buf, true, {
    relative = "editor",
    width = 40,
    height = 20,
    row = 5,
    col = 10,
    style = "minimal",
    border = "single"
  })
  end, {})
  vim.api.nvim_create_user_command("SaveParameters", function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local streams, unitops = parse_params_buffer(lines)
  local streams_json = vim.fn.json_encode(streams)
  vim.notify(streams_json, vim.log.levels.INFO)
  local unitops_json = vim.fn.json_encode(unitops)
  vim.notify(unitops_json, vim.log.levels.INFO) 
  vim.api.nvim_buf_delete(current_buf, { force = true })


  end, {})
end


return M
