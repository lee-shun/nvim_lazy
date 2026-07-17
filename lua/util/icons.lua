-- Shared icon definitions for completion, diagnostics and UI plugins.
-- Centralized so all plugins use the same symbols.

local M = {}

---Kind icons used by nvim-cmp and other completion UIs.
M.kinds = {
    Array = " ",
    Boolean = " ",
    Class = " ",
    Color = " ",
    Constant = " ",
    Constructor = " ",
    Copilot = " ",
    Enum = " ",
    EnumMember = " ",
    Event = " ",
    Field = " ",
    File = " ",
    Folder = " ",
    Function = " ",
    Interface = " ",
    Key = " ",
    Keyword = " ",
    Method = " ",
    Module = " ",
    Namespace = " ",
    Null = " ",
    Number = " ",
    Object = " ",
    Operator = " ",
    Package = " ",
    Property = " ",
    Reference = " ",
    Snippet = " ",
    String = " ",
    Struct = " ",
    Text = " ",
    TypeParameter = " ",
    Unit = " ",
    Value = " ",
    Variable = " ",
    TN = "💡",
}

---Diagnostic signs used by vim.diagnostic and UI plugins.
M.diagnostics = {
    Error = "",
    Warn = "",
    Hint = "",
    Info = "",
}

return M
