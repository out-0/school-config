return {
  "MoulatiMehdi/42norm.nvim",
  ft = { "c", "h", "cpp", "hpp" },   -- load when opening C files
  config = function()
    local norm = require("42norm")

    norm.setup({
      header_on_save = true,
      format_on_save = true,
      liner_on_change = true,
    })

    vim.keymap.set("n", "<F5>", function()
      norm.check_norms()
    end)

    vim.keymap.set("n", "<C-f>", function()
      norm.format()
    end)

    vim.keymap.set("n", "<F1>", function()
      norm.stdheader()
    end)
  -- run norminette automatically when saving
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = { "*.c", "*.h" },
      callback = function()
        norm.check_norms()
      end,
    })
  end,
}
