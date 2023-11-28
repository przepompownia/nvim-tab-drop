# nvim-tab-drop

`nvim-tab-drop` - `tab drop` replacement to avoid triggering redundant autocommands.

## See:
- https://github.com/neovim/neovim/issues/14567
- https://github.com/vim/vim/issues/12087 
- https://github.com/vim/vim/issues/12552

## Example usages:
```lua
require('nvim-tab-drop')(path)
require('nvim-tab-drop')(path, line, column)

local nvimTabDrop = require('nvim-tab-drop')
local tabDrop = function (opts) nvimTabDrop(opts.args) end
local opts = {nargs = 1, complete = 'file'}

vim.api.nvim_create_user_command('TabDrop', tabDrop, opts)
```

Extracted from https://github.com/przepompownia/nvim-arctgx
