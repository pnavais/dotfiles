
-- custom commands
vim.api.nvim_create_user_command("ToggleTheme", function()
  require("base46").toggle_theme()
end, {})


