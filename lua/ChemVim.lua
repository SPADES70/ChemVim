local M = {}

function M.setup()
  vim.api.nvim_create_user_command("SolveProcess", function()
    vim.notify("ChemVim Process", vim.log.levels.INFO)
  end, {})
end

return M
