return {
    "dstein64/nvim-scrollview",
    config = true,
    event = "BufRead",
    cmd = { "ScrollViewToggle", "ScrollViewEnable", "ScrollViewDisable" },
}
