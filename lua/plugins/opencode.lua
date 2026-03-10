return {
    "sudo-tee/opencode.nvim",
    config = function()
        -- Default configuration with all available options
        require('opencode').setup({
            preferred_picker = 'telescope',    -- 'telescope', 'fzf', 'mini.pick', 'snacks', 'select', if nil, it will use the best available picker. Note mini.pick does not support multiple selections
            preferred_completion = 'nvim-cmp', -- 'blink', 'nvim-cmp','vim_complete' if nil, it will use the best available completion
            default_global_keymaps = false,     -- If false, disables all default global keymaps
            default_mode = 'build',            -- 'build' or 'plan' or any custom configured. @see [OpenCode Agents](https://opencode.ai/docs/modes/)
            default_system_prompt = nil,       -- Custom system prompt to use for all sessions. If nil, uses the default built-in system prompt
            keymap_prefix = '<leader>o',       -- Default keymap prefix for global keymaps change to your preferred prefix and it will be applied to all keymaps starting with <leader>o
            opencode_executable = 'opencode',  -- Name of your opencode binary

            keymap = {
                editor = {
                    ['<leader>ot'] = { 'toggle', desc = 'Toggle Opencode UI' },
                    ['<leader>oi'] = { 'open_input', desc = 'Open and focus input window (insert mode)' },
                    ['<leader>oI'] = { 'open_input_new_session', desc = 'Open input window with new session (insert mode)' },
                    ['<leader>oo'] = { 'open_output', desc = 'Open and focus output window' },
                    ['<leader>of'] = { 'toggle_focus', desc = 'Toggle focus between Opencode and last window' },
                    ['<leader>oT'] = { 'timeline', desc = 'Open timeline picker to navigate/undo/redo/fork messages' },
                    ['<leader>oq'] = { 'close', desc = 'Close Opencode UI windows' },
                    ['<leader>os'] = { 'select_session', desc = 'Select and load an Opencode session' },
                    ['<leader>oR'] = { 'rename_session', desc = 'Rename current session' },
                    ['<leader>op'] = { 'configure_provider', desc = 'Quick provider and model switch' },
                    ['<leader>oV'] = { 'configure_variant', desc = 'Switch model variant for current model' },
                    ['<leader>oy'] = { 'add_visual_selection', mode = { 'v' }, desc = 'Add visual selection to context' },
                    ['<leader>oz'] = { 'toggle_zoom', desc = 'Zoom in/out Opencode windows' },
                    ['<leader>ov'] = { 'paste_image', desc = 'Paste image from clipboard into session' },
                    ['<leader>od'] = { 'diff_open', desc = 'Open diff tab of modified file since last prompt' },
                    ['<leader>o]'] = { 'diff_next', desc = 'Navigate to next file diff' },
                    ['<leader>o['] = { 'diff_prev', desc = 'Navigate to previous file diff' },
                    ['<leader>oc'] = { 'diff_close', desc = 'Close diff view tab' },
                    ['<leader>ora'] = { 'diff_revert_all_last_prompt', desc = 'Revert all file changes since last prompt' },
                    ['<leader>ort'] = { 'diff_revert_this_last_prompt', desc = 'Revert current file changes since last prompt' },
                    ['<leader>orA'] = { 'diff_revert_all', desc = 'Revert all file changes since session start' },
                    ['<leader>orT'] = { 'diff_revert_this', desc = 'Revert current file changes since session start' },
                    ['<leader>orr'] = { 'diff_restore_snapshot_file', desc = 'Restore a file to a restore point' },
                    ['<leader>orR'] = { 'diff_restore_snapshot_all', desc = 'Restore all files to a restore point' },
                    ['<leader>ox'] = { 'swap_position', desc = 'Swap Opencode pane left/right' },
                    ['<leader>opt'] = { 'toggle_tool_output', desc = 'Toggle tools output (diffs, cmd output)' },
                    ['<leader>opr'] = { 'toggle_reasoning_output', desc = 'Toggle reasoning/thinking steps output' },
                    ['<leader>o/'] = { 'quick_chat', mode = { 'n', 'x' }, desc = 'Open quick chat with context' },
                },
                input_window = {
                    ['<C-s>'] = { 'submit_input_prompt', mode = {'i' }, desc = 'Submit prompt' },
                    ['<CR>'] = { 'submit_input_prompt', mode = {'i' }, desc = 'Submit prompt' },
                    ['<esc>'] = { 'close', desc = 'Close UI windows' },
                    ['<C-c>'] = { 'cancel', desc = 'Cancel Opencode request' },
                    ['~'] = { 'mention_file', mode = 'i', desc = 'Pick a file and add to context' },
                    ['@'] = { 'mention', mode = 'i', desc = 'Insert mention (file/agent)' },
                    ['/'] = { 'slash_commands', mode = 'i', desc = 'Pick a command to run' },
                    ['#'] = { 'context_items', mode = 'i', desc = 'Manage context items' },
                    ['<M-v>'] = { 'paste_image', mode = 'i', desc = 'Paste image from clipboard' },
                    ['<tab>'] = { 'toggle_pane', mode = { 'n', 'i' }, desc = 'Toggle between input and output panes' },
                    ['<up>'] = { 'prev_prompt_history', mode = { 'n', 'i' }, desc = 'Navigate to previous prompt in history' },
                    ['<down>'] = { 'next_prompt_history', mode = { 'n', 'i' }, desc = 'Navigate to next prompt in history' },
                    ['<M-m>'] = { 'switch_mode', desc = 'Switch between modes (build/plan)' },
                    ['<M-r>'] = { 'cycle_variant', mode = { 'n', 'i' }, desc = 'Cycle through model variants' },
                },
                output_window = {
                    ['<esc>'] = { 'close', desc = 'Close UI windows' },
                    ['<C-c>'] = { 'cancel', desc = 'Cancel Opencode request' },
                    [']]'] = { 'next_message', desc = 'Navigate to next message' },
                    ['[['] = { 'prev_message', desc = 'Navigate to previous message' },
                    ['<tab>'] = { 'toggle_pane', mode = { 'n', 'i' }, desc = 'Toggle between input and output panes' },
                    ['i'] = { 'focus_input', 'n', desc = 'Focus input window (insert mode)' },
                    ['<M-r>'] = { 'cycle_variant', mode = { 'n' }, desc = 'Cycle through model variants' },
                    ['<leader>oS'] = { 'select_child_session', desc = 'Select and load a child session' },
                    ['<leader>oD'] = { 'debug_message', desc = 'Open raw message for debugging' },
                    ['<leader>oO'] = { 'debug_output', desc = 'Open raw output for debugging' },
                    ['<leader>ods'] = { 'debug_session', desc = 'Open raw session for debugging' },
                },
                session_picker = {
                    rename_session = { '<C-r>', desc = 'Rename selected session' },
                    delete_session = { '<C-d>', desc = 'Delete selected session' },
                    new_session = { '<C-s>', desc = 'Create and switch to new session' },
                },
                timeline_picker = {
                    undo = { '<C-u>', mode = { 'i', 'n' }, desc = 'Undo to selected message' },
                    fork = { '<C-f>', mode = { 'i', 'n' }, desc = 'Fork from selected message' },
                },
                history_picker = {
                    delete_entry = { '<C-d>', mode = { 'i', 'n' }, desc = 'Delete selected history entry' },
                    clear_all = { '<C-X>', mode = { 'i', 'n' }, desc = 'Clear all history entries' },
                },
                model_picker = {
                    toggle_favorite = { '<C-f>', mode = { 'i', 'n' }, desc = 'Toggle model favorite' },
                },
                mcp_picker = {
                    toggle_connection = { '<C-t>', mode = { 'i', 'n' }, desc = 'Toggle MCP server connection' },
                },
            },
            ui = {
                enable_treesitter_markdown = true,                                         -- Use Treesitter for markdown rendering in the output window (default: true).
                position = 'right',                                                        -- 'right' (default), 'left' or 'current'. Position of the UI split. 'current' uses the current window for the output.
                input_position = 'bottom',                                                 -- 'bottom' (default) or 'top'. Position of the input window
                window_width = 0.40,                                                       -- Width as percentage of editor width
                zoom_width = 0.8,                                                          -- Zoom width as percentage of editor width
                display_model = true,                                                      -- Display model name on top winbar
                display_context_size = true,                                               -- Display context size in the footer
                display_cost = true,                                                       -- Display cost in the footer
                window_highlight = 'Normal:OpencodeBackground,FloatBorder:OpencodeBorder', -- Highlight group for the opencode window
                persist_state = true,                                                      -- Keep buffers when toggling/closing UI so window state restores quickly
                icons = {
                    preset = 'nerdfonts',                                                  -- 'nerdfonts' | 'text'. Choose UI icon style (default: 'nerdfonts')
                    overrides = {},                                                        -- Optional per-key overrides, see section below
                },
                questions = {
                    use_vim_ui_select = false, -- If true, render questions/prompts with vim.ui.select instead of showing them inline in the output buffer.
                },
                output = {
                    tools = {
                        show_output = true,           -- Show tools output [diffs, cmd output, etc.] (default: true)
                        show_reasoning_output = true, -- Show reasoning/thinking steps output (default: true)
                    },
                    rendering = {
                        markdown_debounce_ms = 250, -- Debounce time for markdown rendering on new data (default: 250ms)
                        on_data_rendered = nil,     -- Called when new data is rendered; set to false to disable default RenderMarkdown/Markview behavior
                    },
                },
                input = {
                    min_height = 0.10, -- min height of prompt input as percentage of window height
                    max_height = 0.25, -- max height of prompt input as percentage of window height
                    text = {
                        wrap = false,  -- Wraps text inside input window
                    },
                    -- Auto-hide input window when prompt is submitted or focus switches to output window
                    auto_hide = false,
                },
                picker = {
                    snacks_layout = nil -- `layout` opts to pass to Snacks.picker.pick({ layout = ... })
                },
                completion = {
                    file_sources = {
                        enabled = true,
                        preferred_cli_tool = 'server', -- 'fd','fdfind','rg','git','server' if nil, it will use the best available tool, 'server' uses opencode cli to get file list (works cross platform) and supports folders
                        ignore_patterns = {
                            '^%.git/',
                            '^%.svn/',
                            '^%.hg/',
                            'node_modules/',
                            '%.pyc$',
                            '%.o$',
                            '%.obj$',
                            '%.exe$',
                            '%.dll$',
                            '%.so$',
                            '%.dylib$',
                            '%.class$',
                            '%.jar$',
                            '%.war$',
                            '%.ear$',
                            'target/',
                            'build/',
                            'dist/',
                            'out/',
                            'deps/',
                            '%.tmp$',
                            '%.temp$',
                            '%.log$',
                            '%.cache$',
                        },
                        max_files = 10,
                        max_display_length = 50, -- Maximum length for file path display in completion, truncates from left with "..."
                    },
                },
            },
            context = {
                enabled = true,        -- Enable automatic context capturing
                cursor_data = {
                    enabled = false,   -- Include cursor position and line content in the context
                    context_lines = 5, -- Number of lines before and after cursor to include in context
                },
                diagnostics = {
                    info = false,         -- Include diagnostics info in the context (default to false
                    warning = true,       -- Include diagnostics warnings in the context
                    error = true,         -- Include diagnostics errors in the context
                    only_closest = false, -- If true, only diagnostics for cursor/selection
                },
                current_file = {
                    enabled = true, -- Include current file path and content in the context
                    show_full_path = true,
                },
                files = {
                    enabled = true,
                    show_full_path = true,
                },
                selection = {
                    enabled = true, -- Include selected text in the context
                },
                buffer = {
                    enabled = false, -- Disable entire buffer context by default, only used in quick chat
                },
                git_diff = {
                    enabled = false,
                },
            },
            logging = {
                enabled = false,
                level = 'warn', -- debug, info, warn, error
                outfile = nil,
            },
            debug = {
                enabled = false, -- Enable debug messages in the output window
                capture_streamed_events = false,
                show_ids = true,
                quick_chat = {
                    keep_session = false, -- Keep quick_chat sessions for inspection, this can pollute your sessions list
                    set_active_session = false,
                },
            },
            prompt_guard = nil, -- Optional function that returns boolean to control when prompts can be sent (see Prompt Guard section)

            -- User Hooks for custom behavior at certain events
            hooks = {
                on_file_edited = nil,          -- Called after a file is edited by opencode.
                on_session_loaded = nil,       -- Called after a session is loaded.
                on_done_thinking = nil,        -- Called when opencode finishes thinking (all jobs complete).
                on_permission_requested = nil, -- Called when a permission request is issued.
            },
            quick_chat = {
                default_model = nil, -- works better with a fast model like gpt-4.1
                default_agent = nil, -- Uses the current mode when nil
                instructions = nil,  -- Use built-in instructions if nil
            },
        })
    end,
    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "MeanderingProgrammer/render-markdown.nvim",
            opts = {
                anti_conceal = { enabled = false },
                file_types = { 'markdown', 'opencode_output' },
            },
            ft = { 'markdown', 'Avante', 'copilot-chat', 'opencode_output' },
        },
        -- Optional, for file mentions and commands completion, pick only one
        'hrsh7th/nvim-cmp',

        -- Optional, for file mentions picker, pick only one
        'nvim-telescope/telescope.nvim',
    },
}
