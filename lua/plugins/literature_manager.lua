return {
  dir = "~/nvim-literature-manager",
  config = function()
    require("literature_manager").setup({
      literature_dir = "~/knowledge_library/literature",
      note_dir = "~/knowledge_library/literature_note",
      create_folders = true,
      pdf_extensions = {"pdf", "PDF", "epub"}  -- 支持多种文件类型
    })
  end,
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim"
  },
  cmd = {"LiteratureNewList", "LiteratureCheck"},
  keys = {
    {"<leader>ln", "<cmd>LiteratureNewList<cr>", desc = "New Literature Notes"},
    {"<leader>lc", "<cmd>LiteratureCheck<cr>", desc = "Check Literature Notes"}
  }
}
