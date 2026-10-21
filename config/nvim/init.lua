-- ~/.config/nvim/init.lua
-- Starter config: lazy.nvim, Nord, Python dev (basedpyright + ruff), nvim-tree
--
-- ============================================================
-- SETUP CHECKLIST (do these before / on first launch)
-- ============================================================
--
-- 1. Neovim >= 0.11
--      Check with: nvim --version
--
-- 2. Basic build tools
--      - git
--      - a C compiler (cc/gcc/clang), used to build tree-sitter parsers
--
-- 3. tree-sitter CLI (needed by nvim-treesitter's 'main' branch)
--      macOS (brew):  brew install tree-sitter-cli
--      Arch Linux:    sudo pacman -S tree-sitter-cli
--      Check with:    which tree-sitter
--      (Note: brew's `tree-sitter` formula is only the library.
--       You need `tree-sitter-cli` for the command.)
--
-- 4. Python language server and linter, installed OUTSIDE Mason
--      uv tool install basedpyright   # provides basedpyright-langserver
--      uv tool install ruff           # skip if ruff is already installed
--      Check with: which basedpyright-langserver ruff
--      If they aren't found, add ~/.local/bin to PATH
--      (`uv tool update-shell` will do it).
--
-- 5. A Python project environment
--      cd your-project && uv sync     # creates .venv in the project root
--      Start nvim from the project root so basedpyright finds .venv.
--      (Or launch with: uv run nvim)
--
-- 6. Icons (optional but recommended)
--      Your terminal font needs Nerd Font glyphs. Either use a Nerd Font,
--      or keep your font and add a symbols-only fallback:
--        brew install --cask font-symbols-only-nerd-font
--
-- 7. First launch
--      Open nvim and let lazy.nvim install the plugins, then restart.
--      Mason installs lua_ls; tree-sitter compiles its parsers.
--      Troubleshooting: :checkhealth, :Lazy, :Mason, :checkhealth vim.lsp
--
-- ============================================================
-- KEY BINDINGS (leader = <Space>)
-- ============================================================
--   <leader>n / N   file tree toggle / reveal current file
--   <leader>ff/fg   find files / grep      <leader>fb/fh/fd  buffers/help/diagnostics
--   gd gr K         LSP definition / references / hover
--   <leader>rn/ca   rename / code action
--   [d ]d           previous / next diagnostic
--   <leader>tt/tf   run nearest test / file (pytest)
--   <leader>w / q   save / quit
-- Press <Space> and wait to see all bindings via which-key.

------------------------------------------------------------
-- Leader keys (set before plugins load)
------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

------------------------------------------------------------
-- Options
------------------------------------------------------------
local o = vim.opt
o.number = true
o.relativenumber = false
o.signcolumn = "yes"
o.cursorline = true
o.termguicolors = true
o.scrolloff = 8
o.wrap = false

o.expandtab = true -- spaces, not tabs
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true

o.ignorecase = true
o.smartcase = true
o.incsearch = true
o.hlsearch = true

o.splitright = true
o.splitbelow = true
o.undofile = true
o.updatetime = 250
o.clipboard = "unnamedplus" -- share clipboard with the system
o.colorcolumn = "120"       -- ruff/black default line length

------------------------------------------------------------
-- Bootstrap lazy.nvim
------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local out = vim.fn.system({
        "git", "clone", "--filter=blob:none", "--branch=stable",
        "https://github.com/folke/lazy.nvim.git", lazypath,
    })
    if vim.v.shell_error ~= 0 then
        error("Failed to clone lazy.nvim:\n" .. out)
    end
end
vim.opt.rtp:prepend(lazypath)

------------------------------------------------------------
-- Plugins
------------------------------------------------------------
require("lazy").setup({

    -- Colour scheme: Nord
    {
        "gbprod/nord.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("nord").setup({})
            vim.cmd.colorscheme("nord")
        end,
    },

    -- Statusline
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = { theme = "nord" },
            sections = {
                lualine_c = { { "filename", path = 3 } },
            },
        },
    },

    -- Fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        branch = "master",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>",  desc = "Find files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>",   desc = "Grep" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>",     desc = "Buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>",   desc = "Help" },
            { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
        },
    },

    -- Syntax highlighting / parsing (nvim-treesitter 'main' branch API)
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").install({
                "python", "lua", "vim", "vimdoc", "bash", "toml", "yaml", "json", "markdown",
            })
            vim.api.nvim_create_autocmd("FileType", {
                callback = function()
                    pcall(vim.treesitter.start)
                end,
            })
        end,
    },

    -- LSP server installer
    { "williamboman/mason.nvim", opts = {} },

    -- LSP configs (provides default server definitions)
    { "neovim/nvim-lspconfig" },

    -- Bridge: installs servers and enables them automatically
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
        opts = {
            -- basedpyright and ruff are installed outside Mason (uv tool install / brew)
            ensure_installed = { "lua_ls" },
        },
    },

    -- Completion
    {
        "saghen/blink.cmp",
        version = "1.*",
        opts = {
            keymap = { preset = "default" }, -- <C-space> open, <C-y> accept, <C-n>/<C-p> navigate
            sources = { default = { "lsp", "path", "buffer" } },
        },
    },

    -- Formatting (ruff format + import sorting on save)
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                python = { "ruff_fix", "ruff_format" },
            },
            format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
        },
    },

    -- File explorer sidebar
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys = {
            { "<leader>n", "<cmd>NvimTreeToggle<cr>",   desc = "Toggle file tree" },
            { "<leader>N", "<cmd>NvimTreeFindFile<cr>", desc = "Reveal current file" },
        },
        opts = {
            view = { width = 32 },
            filters = { dotfiles = false },
        },
    },

    -- Keybinding hints
    { "folke/which-key.nvim",    event = "VeryLazy",    opts = {} },

    -- Git signs in the gutter
    { "lewis6991/gitsigns.nvim", opts = {} },

    -- Quality of life
    { "windwp/nvim-autopairs",   event = "InsertEnter", opts = {} },
    { "numToStr/Comment.nvim",   opts = {} }, -- gcc / gc{motion}

    -- Run tests (pytest) from inside Neovim
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-python",
        },
        keys = {
            { "<leader>tt", function() require("neotest").run.run() end,                   desc = "Test nearest" },
            { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test file" },
            { "<leader>ts", function() require("neotest").summary.toggle() end,            desc = "Test summary" },
            { "<leader>to", function() require("neotest").output_panel.toggle() end,       desc = "Test output" },
        },
        config = function()
            require("neotest").setup({
                adapters = { require("neotest-python")({ runner = "pytest" }) },
            })
        end,
    },
}, {
    checker = { enabled = false }, -- no automatic update checks
})

------------------------------------------------------------
-- LSP configuration (Neovim 0.11+ native API)
------------------------------------------------------------
vim.lsp.config("basedpyright", {
    settings = {
        basedpyright = {
            analysis = {
                typeCheckingMode = "standard", -- "strict"/"all" if you want mypy-like strictness
                autoImportCompletions = true,
            },
        },
    },
})

-- These two are not installed by Mason, so enable them explicitly.
-- Requires `basedpyright-langserver` and `ruff` on your PATH
-- (e.g. `uv tool install basedpyright`).
vim.lsp.enable({ "basedpyright", "ruff" })

-- Let basedpyright handle hover; ruff handles linting/formatting
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
        end

        local map = function(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = args.buf, desc = "LSP: " .. desc })
        end
        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gr", vim.lsp.buf.references, "References")
        map("K", vim.lsp.buf.hover, "Hover")
        map("<leader>rn", vim.lsp.buf.rename, "Rename")
        map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    end,
})

vim.diagnostic.config({
    virtual_text = true,
    severity_sort = true,
    float = { border = "rounded" },
})

------------------------------------------------------------
-- General keymaps
------------------------------------------------------------
local map = vim.keymap.set
map("n", "<Esc>", "<cmd>nohlsearch<cr>")
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Prev diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })

-- Window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Keep selection when indenting in visual mode
map("v", "<", "<gv")
map("v", ">", ">gv")
