return {
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      -- LazyVim routes the "N lines, M bytes written" save message to noice's
      -- "mini" popup (a bordered nui.nvim window). Inside herdr, that popup
      -- creation crashes nui.nvim's border layout code (herdr fires rapid
      -- duplicate pane-resize events right around save). Skip the popup
      -- instead of showing it, until herdr fixes the resize behavior.
      for _, route in ipairs(opts.routes or {}) do
        if route.view == "mini" then
          route.view = nil
          route.opts = { skip = true }
        end
      end
      return opts
    end,
  },
}
