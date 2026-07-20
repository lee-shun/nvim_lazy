return {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    cmd = "PasteImg",
    opts = {
        default = {
            file_name = function()
                vim.fn.inputsave()
                local name = vim.fn.input("Name: ")
                vim.fn.inputrestore()

                if name == nil or name == "" then
                    return os.date("%y-%m-%d-%H-%M-%S")
                end
                return name
            end,
            extension = "png",
            dir_path = "assets",
        },
        filetypes = {
            markdown = {
                template = "![image]($FILE_PATH)",
            },
        },
    },
    config = function(_, opts)
        require("img-clip").setup(opts)

        vim.api.nvim_create_user_command("PasteImg", function()
            require("img-clip").paste_image()
        end, { desc = "Paste image from clipboard" })
    end,
}
