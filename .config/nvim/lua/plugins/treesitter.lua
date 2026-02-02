return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,       -- must load early
    build = ":TSUpdate", -- install/update parsers
    config = function()
      -- only run this *after* plugin is fully installed
      local ts = require("nvim-treesitter")       -- plugin entry
      ts.setup {
        ensure_installed = {
          "bash", "c", "lua", "vim", "query", "markdown"
        },
        sync_install = false,
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      }
    end,
  }
}
