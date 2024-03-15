return {
    "nvim-tree/nvim-tree.lua",
    enabled = true,
    keys = {
        { "<leader>t", "<cmd>NvimTreeToggle<cr>", desc = "NvimTreeToggle" },
    },
    cmd = { "NvimTreeToggle", "NvimTreeClose" },
    dependencies = { "kyazdani42/nvim-web-devicons", "folke/which-key.nvim" },
    opts = {
        ui = {
            confirm = {
                remove = true,
                trash = false,
            },
        },
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        update_focused_file = {
            enable = true,
            update_root = true,
        },
        modified = {
            enable = true,
        },
        on_attach = function(bufnr)
            local api = require("nvim-tree.api")
            local opts = function(desc)
                return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
            end

            -- mark operation
            local mark_move_j = function()
                api.marks.toggle()
                vim.cmd("norm j")
            end
            local mark_move_k = function()
                api.marks.toggle()
                vim.cmd("norm k")
            end

            -- marked files operation
            local mark_trash = function()
                local marks = api.marks.list()
                if #marks == 0 then
                    table.insert(marks, api.tree.get_node_under_cursor())
                end
                vim.ui.input({ prompt = string.format("Trash %s files? [y/n] ", #marks) }, function(input)
                    if input == "y" then
                        for _, node in ipairs(marks) do
                            api.fs.trash(node)
                        end
                        api.marks.clear()
                        api.tree.reload()
                    end
                end)
            end
            local mark_remove = function()
                local marks = api.marks.list()
                if #marks == 0 then
                    table.insert(marks, api.tree.get_node_under_cursor())
                end
                vim.ui.input({ prompt = string.format("Remove/Delete %s files? [y/n] ", #marks) }, function(input)
                    if input == "y" then
                        for _, node in ipairs(marks) do
                            api.fs.remove(node)
                        end
                        api.marks.clear()
                        api.tree.reload()
                    end
                end)
            end

            local mark_copy = function()
                local marks = api.marks.list()
                if #marks == 0 then
                    table.insert(marks, api.tree.get_node_under_cursor())
                end
                for _, node in pairs(marks) do
                    api.fs.copy.node(node)
                end
                api.marks.clear()
                api.tree.reload()
            end
            local mark_cut = function()
                local marks = api.marks.list()
                if #marks == 0 then
                    table.insert(marks, api.tree.get_node_under_cursor())
                end
                for _, node in pairs(marks) do
                    api.fs.cut(node)
                end
                api.marks.clear()
                api.tree.reload()
            end

            vim.keymap.set("n", "<CR>", api.tree.change_root_to_node, opts("CD"))
            vim.keymap.set("n", "<C-e>", api.node.open.replace_tree_buffer, opts("Open: In Place"))
            vim.keymap.set("n", "e", api.node.open.horizontal, opts("Open: Horizontal Split"))
            vim.keymap.set("n", "t", api.node.open.tab, opts("Open: New Tab"))
            vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
            vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
            vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
            vim.keymap.set("n", "<BS>", api.tree.change_root_to_parent, opts("Up"))
            vim.keymap.set("n", "a", api.fs.create, opts("Create"))
            vim.keymap.set("n", "if", api.node.show_info_popup, opts("Info"))
            vim.keymap.set("n", "dF", api.fs.remove, opts("Delete"))
            vim.keymap.set("n", "df", api.fs.trash, opts("Trash"))
            vim.keymap.set("n", "L", api.tree.expand_all, opts("Expand All"))
            vim.keymap.set("n", "H", api.tree.collapse_all, opts("Collapse"))
            vim.keymap.set("n", "rn", api.fs.rename_basename, opts("Rename: Omit extension"))
            vim.keymap.set("n", "rN", api.fs.rename, opts("Rename: with extension"))
            vim.keymap.set("n", "rp", api.fs.rename_sub, opts("Rename: ABS Path, Omit Filename"))
            vim.keymap.set("n", "]d", api.node.navigate.diagnostics.next, opts("Next Diagnostic"))
            vim.keymap.set("n", "[d", api.node.navigate.diagnostics.prev, opts("Prev Diagnostic"))
            vim.keymap.set("n", "fs", api.live_filter.start, opts("Filter"))
            vim.keymap.set("n", "fc", api.live_filter.clear, opts("Clean Filter"))
            vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
            vim.keymap.set("n", "mv", api.marks.bulk.move, opts("Move Bookmarked"))
            vim.keymap.set("n", "mc", api.marks.clear, opts("Clear All Bookmark"))
            vim.keymap.set("n", "mt", api.marks.toggle, opts("Toggle Bookmark"))
            vim.keymap.set("n", "mn", api.marks.navigate.next, opts("Next Bookmark"))
            vim.keymap.set("n", "mp", api.marks.navigate.prev, opts("Prev Bookmark"))
            vim.keymap.set("n", "J", mark_move_j, opts("Toggle Bookmark Down"))
            vim.keymap.set("n", "K", mark_move_k, opts("Toggle Bookmark Up"))
            vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
            vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
            vim.keymap.set("n", "q", api.tree.close, opts("Close"))
            vim.keymap.set("n", "<C-r>", api.tree.reload, opts("Refresh"))
            vim.keymap.set("n", "xs", api.node.run.system, opts("Run System"))
            vim.keymap.set("n", "xv", api.node.run.cmd, opts("Run Vim Command"))
            vim.keymap.set("n", "<C-h>", api.tree.toggle_custom_filter, opts("Toggle Hidden"))
            vim.keymap.set("n", ".", api.tree.toggle_hidden_filter, opts("Toggle Dotfiles"))
            vim.keymap.set("n", "<C-i>", api.tree.toggle_gitignore_filter, opts("Toggle Git Ignore"))
            vim.keymap.set("n", "dd", mark_cut, opts("Cut File(s)"))
            vim.keymap.set("n", "df", mark_trash, opts("Trash File(s)"))
            vim.keymap.set("n", "dF", mark_remove, opts("Remove File(s)"))
            vim.keymap.set("n", "yy", mark_copy, opts("Copy File(s)"))
            vim.keymap.set("n", "yn", api.fs.copy.filename, opts("Copy Name"))
            vim.keymap.set("n", "yp", api.fs.copy.relative_path, opts("Copy Relative Path"))
            vim.keymap.set("n", "yP", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
            vim.keymap.set("n", "cp", api.fs.print_clipboard, opts("Print Clipboard"))
            vim.keymap.set("n", "cc", api.fs.clear_clipboard, opts("Clear Clipboard"))
            vim.keymap.set("n", "gp", api.node.navigate.git.prev, opts("Prev Git"))
            vim.keymap.set("n", "gn", api.node.navigate.git.next, opts("Next Git"))
            vim.keymap.set("n", "gr", api.git.reload, opts("Reload Git"))
            vim.keymap.set("n", "G", api.node.navigate.sibling.last, opts("Last Sibling"))
            vim.keymap.set("n", "gg", api.node.navigate.sibling.first, opts("First Sibling"))
        end,
    },
}
