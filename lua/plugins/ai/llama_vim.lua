-- FIM (llama.cpp) 服务器地址：可用环境变量 NVIM_FIM_HOST 覆盖（换网络不用改配置）
local fim_host = os.getenv("NVIM_FIM_HOST") or "192.168.1.133"

return {
    "ggml-org/llama.vim",
    -- 必须启动时加载：插件在 enable() 里注册 `autocmd InsertEnter * inoremap <A-f> ...`，
    -- 若用 event = "InsertEnter" 懒加载，首次进 insert 时插件才加载，autocmd 注册太晚，
    -- <A-f> 映射要第二次进 insert 才存在（实测确认）。插件是轻量 vimscript，启动加载无压力。
    event = "VeryLazy",
    init = function()
        vim.g.llama_config = {
            auto_fim = true,
            endpoint_fim = "http://" .. fim_host .. ":8080/infill",
            keymap_fim_trigger = "<A-f>",
            -- 用 <A-a> 而不是 <A-A>：很多终端对 Alt+大写字母 发的序列和 Alt+小写一样
            -- （Shift 被吞），nvim 解成 <A-a>，<A-A> 映射永远不触发（用户实测 <A-l> 可用、<A-A> 无反应）
            keymap_fim_accept_full = "<A-a>",
            keymap_fim_accept_line = "<A-l>",
            keymap_fim_accept_word = "<A-w>",

            keymap_inst_trigger = "<A-i>",
            keymap_inst_rerun = "<A-r>",
            keymap_inst_continue = "<A-c>",
            keymap_inst_accept = "<A-a>",
            keymap_inst_cancel = "<A-x>",

            keymap_fim_next = "<A-j>",
            keymap_fim_prev = "<A-k>",

            keymap_debug_toggle = "<A-d>",
        }
    end,
}
