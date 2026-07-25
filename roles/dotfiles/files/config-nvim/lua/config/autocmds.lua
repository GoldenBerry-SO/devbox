-- ABOUTME: Custom autocmds for IDE-like startup behavior
-- ABOUTME: Opens neo-tree sidebar automatically on launch

-- Open neo-tree sidebar on startup
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("open_neo_tree", { clear = true }),
  callback = function()
    vim.defer_fn(function()
      vim.cmd("Neotree show")
    end, 100)
  end,
})
