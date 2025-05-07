return {
  "anuvyklack/windows.nvim",
  requires = {
    "anuvyklack/middleclass",
    "anuvyklack/animation.nvim",
  },

  config = function()
    vim.o.winwidth = 50
    vim.o.winminwidth = 60
    vim.o.equalalways = false
    require("windows").setup()
  end,
}
