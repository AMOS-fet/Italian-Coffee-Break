-- File: ~/.config/nvim/lua/coffee_break.lua
local M = {}

M.palette = {
    dark = {
        bg = "#282828",
        bg_alt = "#1B1E1F",
        fg = "#F9EDD2",
        red = "#F94835",
        green = "#B7B827",
        yellow = "#F9BB31",
        blue = "#83A497",
        purple = "#D184CC",
        gray = "#A89985",
        border = "#504945",
    },
    light = {
        bg = "#F9EDD2",
        bg_alt = "#D3C29F",
        fg = "#282828",
        red = "#CA2420",
        green = "#98971C",
        yellow = "#D89822",
        blue = "#448385",
        purple = "#A962AF",
        gray = "#8F8173",
        border = "#FCF3DB",
    }
}


function M.load()
    vim.cmd("hi clear")
    if vim.fn.exists("syntax_on") then
        vim.cmd("syntax reset")
    end
    vim.o.termguicolors = true
    vim.g.colors_name = "coffee_break"

    
    local is_dark = vim.o.background == "dark"
    local c = is_dark and M.palette.dark or M.palette.light

    local highlights = {
        -- Base UI
        Normal       = { fg = c.fg, bg = c.bg },
        NormalFloat  = { fg = c.fg, bg = c.bg_alt },
        LineNr       = { fg = c.gray },
        CursorLine   = { bg = c.bg_alt },
        CursorLineNr = { fg = c.yellow, bold = true },
        VertSplit    = { fg = c.border },

        -- Base Syntax
        Comment      = { fg = c.gray, italic = true },
        String       = { fg = c.green },
        Number       = { fg = c.purple },
        Boolean      = { fg = c.purple, bold = true },
        Function     = { fg = c.blue, bold = true },
        Keyword      = { fg = c.red, italic = true },
        Type         = { fg = c.yellow },
        Operator     = { fg = c.fg },
          
        -- LazyVim (Snacks.dashboard)
        SnacksDashboardHeader = { fg = c.blue, bold = true },
        SnacksDashboardIcon   = { fg = c.purple },
        SnacksDashboardTitle  = { fg = c.yellow, bold = true },
        SnacksDashboardDesc   = { fg = c.fg },
        SnacksDashboardKey    = { fg = c.red, bold = true },
        SnacksDashboardFooter = { fg = c.gray, italic = true },
    
    }

    for group, opts in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, opts)
    end
end

return M
