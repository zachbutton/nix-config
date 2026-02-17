{ pkgs, lib, ... }:

let
  vimNiriNavSrc = pkgs.fetchFromGitHub {
    owner = "andergrim";
    repo = "vim-niri-nav";
    rev = "master";
    hash = "sha256-HZNED+FD5+IYT5F1iPmPSjBoaefxVj1CXhOlTkGSOzA=";
  };

  vimNiriNavPlugin = pkgs.vimUtils.buildVimPlugin {
    pname = "vim-niri-nav";
    version = "unstable";
    src = vimNiriNavSrc;
  };

  vimNiriNavBin = pkgs.stdenvNoCC.mkDerivation {
    pname = "vim-niri-nav-bin";
    version = "unstable";
    src = vimNiriNavSrc;
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"
      install -m755 vim-niri-nav "$out/bin/vim-niri-nav"
      runHook postInstall
    '';
  };
in

{
  programs.nixvim = {
    enable = true;

    # ──────────────────────────────────────────────
    # Globals
    # ──────────────────────────────────────────────
    globals = {
      mapleader = " ";
      maplocalleader = "\\";
    };

    # ──────────────────────────────────────────────
    # Options (from lua/basic.lua)
    # ──────────────────────────────────────────────
    opts = {
      number = true;
      relativenumber = false;

      tabstop = 4;
      softtabstop = 4;
      shiftwidth = 4;
      expandtab = false;

      smartindent = true;
      wrap = false;

      swapfile = false;
      backup = false;
      undofile = true;

      hlsearch = false;
      incsearch = true;

      termguicolors = true;

      scrolloff = 8;
      signcolumn = "yes";

      updatetime = 50;
      colorcolumn = "80";
    };

    # ──────────────────────────────────────────────
    # Keymaps (from lua/keymap.lua)
    # ──────────────────────────────────────────────
    keymaps = [
      # Disable q: (command-line window)
      {
        mode = [
          "n"
          "v"
        ];
        key = "q:";
        action = "<nop>";
      }

      # gh/gl for beginning/end of line
      {
        mode = [
          "n"
          "v"
        ];
        key = "gh";
        action = "^";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "gl";
        action = "$";
      }

      # Move selected lines up/down in visual mode
      {
        mode = "v";
        key = "J";
        action = ":m '>+1<CR>gv=gv";
      }
      {
        mode = "v";
        key = "K";
        action = ":m '<-2<CR>gv=gv";
      }

      # j/k respect wrapped lines
      {
        mode = "n";
        key = "j";
        action = "gj";
      }
      {
        mode = "n";
        key = "k";
        action = "gk";
      }

      # Keep cursor centered
      {
        mode = "n";
        key = "J";
        action = "mzJ`z";
      }
      {
        mode = "n";
        key = "<C-d>";
        action = "<C-d>zz";
      }
      {
        mode = "n";
        key = "<C-u>";
        action = "<C-u>zz";
      }
      {
        mode = "n";
        key = "n";
        action = "nzzzv";
      }
      {
        mode = "n";
        key = "N";
        action = "Nzzzv";
      }

      # System clipboard yank/paste and void delete
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>y";
        action = ''"+y'';
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>p";
        action = ''"+p'';
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>d";
        action = ''"_d'';
      }
    ];

    # ──────────────────────────────────────────────
    # Treesitter — uses nixvim's current top-level API
    # (NOT settings.highlight — that's the old API)
    # By default ALL grammars are installed via Nix.
    # Use grammarPackages to limit to specific ones.
    # ──────────────────────────────────────────────
    plugins.treesitter = {
      enable = true;
      highlight.enable = true;
      indent.enable = true;
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        bash
        html
        css
        scss
        javascript
        typescript
        tsx
        json
        lua
        markdown
        markdown_inline
        python
        nix
      ];
    };

    # ──────────────────────────────────────────────
    # LSP — Nix-managed servers (replaces Mason)
    # ──────────────────────────────────────────────
    plugins.lsp = {
      enable = true;
      servers = {
        ts_ls.enable = true;
        lua_ls.enable = true;
        pyright.enable = true;
        html.enable = true;
        cssls.enable = true;
        bashls.enable = true;
        jsonls.enable = true;
        nil_ls.enable = true;
      };
    };

    # ──────────────────────────────────────────────
    # Blink.cmp (completion)
    # ──────────────────────────────────────────────
    plugins.blink-cmp = {
      enable = true;
    };

    # ──────────────────────────────────────────────
    # Conform (formatting)
    # ──────────────────────────────────────────────
    plugins.conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = {
          javascript = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            stop_after_first = true;
          };
          typescript = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            stop_after_first = true;
          };
        };
        format_on_save = {
          timeout_ms = 500;
          lsp_format = "fallback";
        };
      };
    };

    # ──────────────────────────────────────────────
    # Lualine (statusline)
    # ──────────────────────────────────────────────
    plugins.lualine.enable = true;

    # ──────────────────────────────────────────────
    # All other plugins via extraPlugins.
    #
    # This is the official nixvim-recommended pattern
    # for plugins where you need manual Lua setup or
    # where the module's generated code has issues.
    # See: nixvim FAQ "How do I use a plugin not
    # supported by nixvim?"
    # ──────────────────────────────────────────────
    extraPlugins = with pkgs.vimPlugins; [
      # Which-key
      which-key-nvim

      # Harpoon 2
      harpoon2
      plenary-nvim

      # Snacks (picker)
      snacks-nvim

      # Toggleterm
      toggleterm-nvim

      # Yazi file manager
      yazi-nvim

      # Leap (motion)
      leap-nvim

      # Avante (AI assistant) + deps
      avante-nvim
      nui-nvim
      nvim-web-devicons
      dressing-nvim
      img-clip-nvim
      render-markdown-nvim

      # Snippets for blink.cmp
      friendly-snippets

      # Niri/Vim navigation
      vimNiriNavPlugin
    ];

    # ──────────────────────────────────────────────
    # Lua config — everything that needs manual setup
    # ──────────────────────────────────────────────
    extraConfigLuaPre = ''
      -- Must happen before plugins reference isfname
      vim.opt.isfname:append("@-@")
      vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
    '';

    extraConfigLua = ''

      -- ── Which-key ──
      require("which-key").setup({})

      -- ── Harpoon 2 ──
      local harpoon = require("harpoon")
      harpoon:setup({
        settings = {
          save_on_toggle = true,
          sync_on_ui_close = true,
        },
      })
      vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon: Add file" })
      vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon: Toggle menu" })
      vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end, { desc = "Harpoon: File 1" })
      vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end, { desc = "Harpoon: File 2" })
      vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end, { desc = "Harpoon: File 3" })
      vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end, { desc = "Harpoon: File 4" })

      -- ── Snacks ──
      require("snacks").setup({
        picker = {},
      })
      vim.keymap.set("n", "<leader><space>", function() Snacks.picker.smart() end, { desc = "Smart Find Files" })
      vim.keymap.set("n", "<leader>/", function() Snacks.picker.grep() end, { desc = "Grep" })
      vim.keymap.set("n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Goto Definition" })
      vim.keymap.set("n", "gD", function() Snacks.picker.lsp_declarations() end, { desc = "Goto Declaration" })
      vim.keymap.set("n", "gr", function() Snacks.picker.lsp_references() end, { desc = "References" })
      vim.keymap.set("n", "gI", function() Snacks.picker.lsp_implementations() end, { desc = "Goto Implementation" })
      vim.keymap.set("n", "gy", function() Snacks.picker.lsp_type_definitions() end, { desc = "Goto Type Definition" })
      vim.keymap.set("n", "gai", function() Snacks.picker.lsp_incoming_calls() end, { desc = "Calls Incoming" })
      vim.keymap.set("n", "gao", function() Snacks.picker.lsp_outgoing_calls() end, { desc = "Calls Outgoing" })
      vim.keymap.set("n", "<leader>ss", function() Snacks.picker.lsp_symbols() end, { desc = "LSP Symbols" })
      vim.keymap.set("n", "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, { desc = "LSP Workspace Symbols" })

      -- ── Toggleterm ──
      require("toggleterm").setup({
        shade_terminals = true,
        shading_factor = 30,
        shading_ratio = -3,
        float_opts = { border = "rounded" },
      })

      local Terminal = require("toggleterm.terminal").Terminal
      local full = Terminal:new({
        cmd = "jjui",
        hidden = true,
        direction = "float",
      })
      local peek = Terminal:new({
        cmd = "jjui",
        hidden = true,
      })

      function _full() full:toggle() end
      function _peek() peek:toggle() end

      vim.keymap.set("n", "<leader>g", "<cmd>lua _peek()<CR>", { noremap = true, silent = true, desc = "jjui (peek)" })
      vim.keymap.set("n", "<leader>G", "<cmd>lua _full()<CR>", { noremap = true, silent = true, desc = "jjui (float)" })

      -- ── Yazi ──
      vim.keymap.set({ "n", "v" }, "<leader>-", "<cmd>Yazi<cr>", { desc = "Open Yazi" })

      -- ── Leap ──
      vim.keymap.set({ "n", "x", "o" }, "<leader>t", "<Plug>(leap)", { desc = "Leap" })
      vim.keymap.set("n", "<C-w>t", "<Plug>(leap-from-window)", { desc = "Leap from window" })

      -- ── Avante ──
      require("avante").setup({
        instructions_file = "AGENTS.md",
        provider = "openai",
        providers = {
          provider = "openai",
          openai = {
            endpoint = "https://api.openai.com/v1",
            model = "gpt-5.2",
          },
        },
      })

      -- ── render-markdown (for Avante) ──
      require("render-markdown").setup({
        file_types = { "markdown", "Avante" },
      })
    '';

    # ──────────────────────────────────────────────
    # Runtime packages (formatters, tools)
    # ──────────────────────────────────────────────
    extraPackages = with pkgs; [
      prettierd
      nodePackages.prettier
      yazi
      ripgrep
      fd
    ];
  };

  home.packages = [
    vimNiriNavBin
  ];
}
