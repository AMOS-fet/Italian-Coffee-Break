-- File: ~/.config/nvim/lua/plugins/colorscheme.lua
return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        require("coffee_break").load()
      end,
    },
  },
}
