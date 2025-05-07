return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("lspconfig").pyright.setup({
        settings = {
          python = {
            pythonPath = "~/MySoftware/RedBarSushiAI/venv/bin/python",
          },
        },
      })
      require("lspconfig").lua_ls.setup({})
      require("lspconfig").clangd.setup({})
    end,
  },
}
