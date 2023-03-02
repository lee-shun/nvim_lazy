return {
  "windwp/nvim-spectre",
  -- stylua: ignore
  keys = {
    { "<leader>c", function() require("spectre").open() end, desc = "Replace in files (Spectre)" },
  },
}
