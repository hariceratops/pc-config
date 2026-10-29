local M = {
  'neovim/nvim-lspconfig',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    { 'folke/neodev.nvim', opts = {} },
  },
  config = function()
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    local required_langauge_servers = { 'clangd', 'rust_analyzer', 'pyright', 'ts_ls', 'zls', 'lua_ls' }

    vim.lsp.log.set_level('warn')
    vim.lsp.config('*', { capabilities = capabilities })
    vim.lsp.config('lua_ls', {
      settings = {
        Lua = { 
          runtime = { version = 'LuaJIT' },
          diagnostics = { globals = { 'vim', 'require' } }
        },
      }
    })
    for _, lsp in ipairs(required_langauge_servers) do
      vim.lsp.enable(lsp)
    end

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('my.lsp', {}),
      callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        if client:supports_method('textDocument/completion') then
          vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end
        -- Auto-format ("lint") on save
        -- Usually not needed if server supports "textDocument/willSaveWaitUntil"
        if not client:supports_method('textDocument/willSaveWaitUntil') and
          not client:supports_method('textDocument/formatting') then
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
            buffer = args.buf,
            callback = function()
              vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
            end,
          })
        end

        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = args.buf, desc = '[R]e[n]ame' })
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = args.buf, desc = '[C]ode [A]ction' })
        vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, { buffer = args.buf, desc = '[G]oto [D]efintion' })
        vim.keymap.set('n', '<leader>gr', require('telescope.builtin').lsp_references, { buffer = args.buf, desc = '[G]oto [R]eferences' })
        vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, { buffer = args.buf, desc = '[G]oto [I]mplementation' })
        vim.keymap.set('n', '<leader>td', vim.lsp.buf.type_definition, { buffer = args.buf, desc = '[T]ype [D]efintion' })
        vim.keymap.set('n', '<leader>ds', require('telescope.builtin').lsp_document_symbols, { buffer = args.buf, desc = '[D]ocument [S]ymbols' })
        vim.keymap.set('n', '<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, { buffer = args.buf, desc = '[W]orskpace [S]ymbols' })
        vim.keymap.set('n', '<leader>d', vim.lsp.buf.hover, { buffer = args.buf, desc = 'Hover [D]ocumentation' })
        vim.keymap.set('n', '<leader>gD', vim.lsp.buf.declaration, { buffer = args.buf, desc = '[G]oto [D]eclaration' })
        vim.keymap.set('n', '<leader>D', vim.lsp.buf.signature_help, { buffer = args.buf, desc = 'Signature Documentation' })
        vim.keymap.set('n', '<leader>ic', vim.lsp.buf.incoming_calls, { buffer = args.buf, desc = '[I]ncoming [C]alls' })
        vim.keymap.set('n', '<leader>oc', vim.lsp.buf.outgoing_calls, { buffer = args.buf, desc = '[O]utgoing [C]alls' })
      end
    })
  end
}

return { M }
