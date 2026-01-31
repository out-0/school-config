return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    -- 42 Hack: Python needs a C++ compiler for its 'scanner.cc'
    -- We force clang/clang++ because 'cc' is often broken at school
    local install = require("nvim-treesitter.install")
    install.compilers = { "clang", "gcc" }
    
    -- Add python to the list
    if type(opts.ensure_installed) == "table" then
      vim.list_extend(opts.ensure_installed, { "python", "lua", "c" })
    end
  end,
}
