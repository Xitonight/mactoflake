return {
  "lmilojevicc/herdr-splits.nvim",
  cond = vim.env.HERDR_ENV == "1",
  event = "VeryLazy",
  config = function()
    require("herdr-splits").setup {
      resize_keys = {
        left = "<C-S-h>",
        down = "<C-S-j>",
        up = "<C-S-k>",
        right = "<C-S-l>",
      },
      at_edge = "stop",
      nav_at_edge = "stop",
    }
  end,
  keys = {
    { "<C-h>", function() require("herdr-splits").move_cursor_left() end, desc = "Navigate left" },
    { "<C-j>", function() require("herdr-splits").move_cursor_down() end, desc = "Navigate down" },
    { "<C-k>", function() require("herdr-splits").move_cursor_up() end, desc = "Navigate up" },
    { "<C-l>", function() require("herdr-splits").move_cursor_right() end, desc = "Navigate right" },
    { "<C-S-h>", function() require("herdr-splits").resize_left() end, desc = "Resize left" },
    { "<C-S-j>", function() require("herdr-splits").resize_down() end, desc = "Resize down" },
    { "<C-S-k>", function() require("herdr-splits").resize_up() end, desc = "Resize up" },
    { "<C-S-l>", function() require("herdr-splits").resize_right() end, desc = "Resize right" },
  },
}
