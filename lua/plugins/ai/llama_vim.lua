return {
    "ggml-org/llama.vim",
    event = "InsertEnter",
    init = function()
        vim.g.llama_config = {
            auto_fim = true,
            endpoint_fim = "http://127.0.0.1:8080/infill",
            keymap_fim_trigger = "<A-f>",
            keymap_fim_accept_full = "<A-A>",
            keymap_fim_accept_line = "<A-l>",
            keymap_fim_accept_word = "<A-w>",

            keymap_inst_trigger = "<A-i>",
            keymap_inst_rerun = "<A-r>",
            keymap_inst_continue = "<A-c>",
            keymap_inst_accept = "<A-a>",
            keymap_inst_cancel = "<A-x>",

            keymap_fim_next = "<A-J>",
            keymap_fim_prev = "<A-K>",

            keymap_debug_toggle = "<A-d>",
        }
    end,
}
