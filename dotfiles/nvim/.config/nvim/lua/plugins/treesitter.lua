local M = {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-context',
  },
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local treesitter = require('nvim-treesitter')
    treesitter.install({
      'c',
      'cpp',
      'lua',
      'python',
      'cmake',
      'vim',
      'json',
      'rust',
      'zig',
      'haskell',
      'csv',
      'typescript',
      'tsx',
      'javascript'
    })

    -- nvim-treesitter's main branch only installs parsers; highlighting must be started per buffer.
    -- pcall: filetypes without an installed parser would otherwise error.
    vim.api.nvim_create_autocmd('FileType', {
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}

return { M }
