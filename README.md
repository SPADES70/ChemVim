# ChemVim

Chemical process simulator for neovim



# Installation

## Requirements

- Neovim >= 0.9
- [Lazy.nvim](https://github.com/folke/lazy.nvim)

## Setup

Clone the repository:

```bash
git clone https://github.com/SPADES70/ChemVim {LOCAL PLUGIN DIR}
```

Add the following to your Lazy plugin specs (e.g. `~/.config/nvim/lua/plugins/ChemVim.lua`):

```lua
return {
  dir = "{LOCAL PLUGIN DIR}",
  name = "ChemVim",
  config = function()
    require('ChemVim').setup()
  end,
}
```

Restart Neovim and verify the installation by running `:SolveProcess`. You should see a notification confirming ChemVim is loaded.


