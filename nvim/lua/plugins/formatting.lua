-- lazy.nvim example
return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" }, -- Run formatters before saving
    cmd = { "ConformInfo" },
    opts = {
      -- Define formatters
      formatters_by_ft = {
        python = { "black" }, -- Use black directly (often preferred for Python)
        -- OR if you strictly want to run prettier which then runs black:
        -- python = { "prettier" },

        -- Configure other languages as needed
        lua = { "stylua" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        -- etc.
      },

      -- Set up format-on-save
      format_on_save = {
        timeout_ms = 500, -- Timeout for formatting
        lsp_fallback = true, -- Fallback to LSP formatting if conform fails
      },

      -- Optional: Customize formatters if needed
      -- formatters = {
      --   prettier = {
      --     -- Use local node_modules prettier first
      --     prepend_args = {"--config-precedence", "prefer-file"},
      --   }
      -- }
    },
    init = function()
      -- Optional: Add a keymap for manual formatting
      vim.api.nvim_set_keymap(
        "n",
        "<leader>f",
        "<cmd>Format<CR>",

        { noremap = true, silent = true, desc = "Format buffer" }
      )
    end,
  },
}
