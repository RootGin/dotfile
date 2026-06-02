{ self, inputs, ... }:
{
  flake.nixosModules.applicationsDevNeovim =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.nixvim.nixosModules.nixvim ];

      config = lib.mkIf config.programs.dev.enable {
        programs.nixvim = {
          enable = true;

          # ════════════════════════════════════════════════════════════════
          #  EDITOR SETTINGS
          # ════════════════════════════════════════════════════════════════
          opts = {
            # Lines
            number = true;
            relativenumber = true;
            cursorline = true;

            # Indentation
            tabstop = 2;
            softtabstop = 2;
            shiftwidth = 2;
            expandtab = true;
            autoindent = true;
            smartindent = true;

            # Search
            hlsearch = true;
            incsearch = true;
            ignorecase = true;
            smartcase = true;

            # Scrolling
            scrolloff = 8;
            sidescrolloff = 8;

            # Splits
            splitbelow = true;
            splitright = true;

            # Clipboard
            clipboard = "unnamedplus";

            # Appearance
            termguicolors = true;
            signcolumn = "yes";
            updatetime = 100;
            timeoutlen = 300;

            # No backups, persistent undo
            swapfile = false;
            backup = false;
            undofile = true;

            # Mouse (IDE-like)
            mouse = "a";

            # Folding
            foldmethod = "expr";
            foldexpr = "nvim_treesitter#foldexpr()";
            foldlevel = 99;
            foldcolumn = "1";

            # Ruler at 80/120
            colorcolumn = "80,120";

            # Show whitespace
            list = true;
            listchars = "tab:»·,trail:·,nbsp:␣,extends:→,precedes:←";
          };

          # ════════════════════════════════════════════════════════════════
          #  COLORSCHEME
          # ════════════════════════════════════════════════════════════════
          colorschemes.nord = {
            enable = true;
            settings = {
              disable_background = false;
              contrast = true;
              styles = {
                comments = "italic";
                functions = "bold";
              };
            };
          };

          # ════════════════════════════════════════════════════════════════
          #  PLUGINS
          # ════════════════════════════════════════════════════════════════
          plugins = {
            # ── Bufferline (IDE-like tabs) ─────────────────────────────
            bufferline = {
              enable = true;
              settings.options = {
                diagnostics = "nvim_lsp";
                separator_style = "slant";
                always_show_bufferline = true;
                offsets = [
                  {
                    filetype = "neo-tree";
                    text = "Explorer";
                    highlight = "Directory";
                  }
                ];
              };
            };

            # ── Telescope ─────────────────────────────────────────────
            telescope = {
              enable = true;
              extensions.fzf-native.enable = true;
              keymaps = {
                "<leader>ff" = "find_files";
                "<leader>fg" = "live_grep";
                "<leader>fw" = "grep_string";
                "<leader>fb" = "buffers";
                "<leader>fh" = "help_tags";
                "<leader>fs" = "lsp_document_symbols";
                "<leader>fS" = "lsp_workspace_symbols";
                "<leader>fr" = "lsp_references";
                "<leader>fd" = "diagnostics";
                "<leader>fq" = "quickfix";
                "<leader>ft" = "treesitter";
                "<leader>fc" = "commands";
                "<leader>fk" = "keymaps";
                "<leader>fo" = "oldfiles";
                "<leader>fz" = "current_buffer_fuzzy_find";
              };
            };

            # ── Treesitter ────────────────────────────────────────────
            treesitter = {
              enable = true;
              settings = {
                highlight.enable = true;
                indent.enable = true;
                incremental_selection = {
                  enable = true;
                  keymaps = {
                    init_selection = "<leader>ss";
                    node_incremental = "<leader>si";
                    node_decremental = "<leader>sd";
                    scope_incremental = "<leader>sc";
                  };
                };
              };
              grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
                nix
                lua
                python
                javascript
                typescript
                tsx
                java
                rust
                bash
                json
                yaml
                toml
                markdown
                html
                css
                scss
                sql
                gitcommit
                diff
                dockerfile
                cmake
                make
              ];
            };

            # ── Autocompletion ────────────────────────────────────────
            cmp = {
              enable = true;
              settings = {
                snippet.expand = "luasnip";
                completion = {
                  completeopt = "menu,menuone,noinsert";
                };
                mapping = {
                  "<C-d>" = "cmp.mapping.scroll_docs(-4)";
                  "<C-f>" = "cmp.mapping.scroll_docs(4)";
                  "<C-Space>" = "cmp.mapping.complete()";
                  "<C-e>" = "cmp.mapping.close()";
                  "<CR>" = "cmp.mapping.confirm({ select = true })";
                  "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' })";
                  "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' })";
                };
                sources = [
                  { name = "nvim_lsp"; }
                  { name = "luasnip"; }
                  { name = "path"; }
                  { name = "buffer"; }
                ];
              };
            };

            # ── LuaSnip ───────────────────────────────────────────────
            luasnip.enable = true;

            # ── Lualine (statusline) ──────────────────────────────────
            lualine = {
              enable = true;
              settings.options = {
                icons_enabled = true;
                theme = "nord";
                component_separators = "|";
                section_separators = "";
                sections = {
                  lualine_a = [ "mode" ];
                  lualine_b = [
                    "branch"
                    "diff"
                    "diagnostics"
                  ];
                  lualine_c = [ "filename" ];
                  lualine_x = [
                    "encoding"
                    "filetype"
                  ];
                  lualine_y = [ "progress" ];
                  lualine_z = [ "location" ];
                };
              };
            };

            # ── Which-key ─────────────────────────────────────────────
            which-key = {
              enable = true;
              settings = {
                icons.group = "";
                icons.mappings = false;
              };
            };

            # ── Neo-tree (file explorer) ──────────────────────────────
            neo-tree = {
              enable = true;
              settings = {
                window.position = "left";
                close_if_last_window = true;
                filesystem.follow_current_file = true;
              };
            };

            # ── Aerial (code outline) ─────────────────────────────────
            aerial = {
              enable = true;
              settings = {
                close_behavior = "auto";
                backends = [
                  "treesitter"
                  "lsp"
                  "markdown"
                ];
                show_guides = true;
                guides = {
                  mid_item = "├─";
                  last_item = "└─";
                  nested_top = "│ ";
                };
                filter_kind = false;
                keymaps = {
                  "[" = "actions.prev";
                  "]" = "actions.next";
                };
              };
            };

            # ── Gitsigns ──────────────────────────────────────────────
            gitsigns = {
              enable = true;
              settings = {
                current_line_blame = true;
                current_line_blame_opts.delay = 500;
                signs = {
                  add.text = "+";
                  change.text = "~";
                  delete.text = "_";
                  topdelete.text = "‾";
                  changedelete.text = "~";
                };
              };
            };

            # ── Conform (auto-format on save) ─────────────────────────
            conform-nvim = {
              enable = true;
              settings = {
                format_on_save = {
                  lsp_fallback = true;
                  timeout_ms = 500;
                };
                formatters_by_ft = {
                  nix = [ "nixfmt" ];
                  lua = [ "stylua" ];
                  python = [ "black" ];
                  javascript = [ "prettier" ];
                  typescript = [ "prettier" ];
                  javascriptreact = [ "prettier" ];
                  typescriptreact = [ "prettier" ];
                  json = [ "prettier" ];
                  yaml = [ "prettier" ];
                  markdown = [ "prettier" ];
                  html = [ "prettier" ];
                  css = [ "prettier" ];
                  rust = [ "rustfmt" ];
                  java = [ "google-java-format" ];
                  "*" = [ "trim_whitespace" ];
                };
              };
            };

            # ── Flash (fast jump navigation) ──────────────────────────
            flash = {
              enable = true;
              settings = {
                jump.autojump = true;
                search.multi_window = true;
                label = {
                  uppercase = false;
                };
                highlight = {
                  backdrop = false;
                };
              };
            };

            # ── Auto-session (session persistence) ────────────────────
            auto-session = {
              enable = true;
              settings.log_level = "error";
            };

            # ── Autopairs ─────────────────────────────────────────────
            autopairs.enable = true;

            # ── Comment ───────────────────────────────────────────────
            comment.enable = true;

            # ── Indent blankline ──────────────────────────────────────
            indent-blankline = {
              enable = true;
              settings = {
                indent.char = "│";
                scope.char = "│";
                scope.enabled = true;
              };
            };

            # ── Noice (UI polish) ────────────────────────────────────
            noice = {
              enable = true;
              settings = {
                cmdline.enabled = true;
                messages.enabled = true;
                popupmenu.enabled = true;
                lsp.progress.enabled = true;
                presets = {
                  bottom_search = true;
                  command_palette = true;
                  long_message_to_split = true;
                };
              };
            };

            # ── Todo-comments ─────────────────────────────────────────
            todo-comments = {
              enable = true;
              settings.signs = true;
            };

            # ── Vim-illuminate ────────────────────────────────────────
            vim-illuminate.enable = true;

            # ── Trouble (diagnostics) ─────────────────────────────────
            trouble = {
              enable = true;
              settings = {
                focus = true;
                auto_open = false;
                auto_close = true;
              };
            };

            # ── Toggleterm ────────────────────────────────────────────
            toggleterm = {
              enable = true;
              settings = {
                size = 10;
                open_mapping = "[[<C-\\>]]";
                hide_numbers = true;
                direction = "horizontal";
              };
            };

            # ── Mini (greeter screen) ─────────────────────────────────
            mini = {
              enable = true;
              modules = {
                starter.enable = true;
              };
            };

            # ── Web-devicons ─────────────────────────────────────────
            web-devicons.enable = true;

            # ══════════════════════════════════════════════════════════
            #  LSP CONFIGURATION
            # ══════════════════════════════════════════════════════════
            lsp = {
              enable = true;
              inlayHints = true;
              keymaps = {
                lspBuf = {
                  gd = "definition";
                  gD = "declaration";
                  gi = "implementation";
                  gr = "references";
                  gt = "type_definition";
                  K = "hover";
                  "<F2>" = "rename";
                  "<F3>" = "code_action";
                  "<leader>f" = "format";
                };
              };
              servers = {
                nil = {
                  enable = true;
                  settings.formatting.command = [ "nixfmt" ];
                };
                lua_ls = {
                  enable = true;
                  settings.telemetry.enable = false;
                };
                ts_ls.enable = true;
                pyright.enable = true;
                jdtls.enable = true;
                rust_analyzer = {
                  enable = true;
                  installCargo = true;
                  installRustc = true;
                };
                jsonls.enable = true;
                yamlls = {
                  enable = true;
                  settings.yaml.schemas = {
                    "https://json.schemastore.org/github-workflow.json" = ".github/workflows/*.{yml,yaml}";
                  };
                };
                marksman.enable = true;
                bashls.enable = true;
                html.enable = true;
                cssls.enable = true;
              };
            };
          };

          # ════════════════════════════════════════════════════════════════
          #  GLOBAL KEYMAPS
          # ════════════════════════════════════════════════════════════════
          keymaps = [
            {
              key = "<leader>bd";
              action = "<cmd>bd<CR>";
              options.desc = "Close buffer";
            }
            {
              key = "<leader>bo";
              action = "<cmd>%bd|e#|bd#<CR>";
              options.desc = "Close other buffers";
            }
            {
              key = "<leader>bl";
              action = "<cmd>bnext<CR>";
              options.desc = "Next buffer";
            }
            {
              key = "<leader>bh";
              action = "<cmd>bprev<CR>";
              options.desc = "Previous buffer";
            }
            {
              key = "<leader>b1";
              action = "<cmd>BufferLineGoToBuffer 1<CR>";
              options.desc = "Go to buffer 1";
            }
            {
              key = "<leader>b2";
              action = "<cmd>BufferLineGoToBuffer 2<CR>";
              options.desc = "Go to buffer 2";
            }
            {
              key = "<leader>b3";
              action = "<cmd>BufferLineGoToBuffer 3<CR>";
              options.desc = "Go to buffer 3";
            }
            {
              key = "<leader>b4";
              action = "<cmd>BufferLineGoToBuffer 4<CR>";
              options.desc = "Go to buffer 4";
            }

            # ── Diagnostics ─────────────────────────────────────────────
            {
              key = "[d";
              action = "<cmd>vim.diagnostic.goto_prev()<CR>";
              options.desc = "Previous diagnostic";
            }
            {
              key = "]d";
              action = "<cmd>vim.diagnostic.goto_next()<CR>";
              options.desc = "Next diagnostic";
            }
            {
              key = "<leader>v";
              action = "<cmd>vsplit<CR>";
              options.desc = "Vertical split";
            }
            {
              key = "<leader>s";
              action = "<cmd>split<CR>";
              options.desc = "Horizontal split";
            }

            # ── Split navigation (Ctrl+h/j/k/l) ──────────────────────
            {
              key = "<C-h>";
              action = "<C-w>h";
              options.desc = "Go to left split";
            }
            {
              key = "<C-j>";
              action = "<C-w>j";
              options.desc = "Go to lower split";
            }
            {
              key = "<C-k>";
              action = "<C-w>k";
              options.desc = "Go to upper split";
            }
            {
              key = "<C-l>";
              action = "<C-w>l";
              options.desc = "Go to right split";
            }

            # ── Window management ───────────────────────────────────────
            {
              key = "<leader>w";
              action = "<C-w>";
              options.desc = "Window prefix";
            }
            {
              key = "<leader>wh";
              action = "<C-w>h";
              options.desc = "Move to left window";
            }
            {
              key = "<leader>wl";
              action = "<C-w>l";
              options.desc = "Move to right window";
            }
            {
              key = "<leader>wj";
              action = "<C-w>j";
              options.desc = "Move to lower window";
            }
            {
              key = "<leader>wk";
              action = "<C-w>k";
              options.desc = "Move to upper window";
            }
            {
              key = "<leader>wv";
              action = "<C-w>v";
              options.desc = "Split vertically";
            }
            {
              key = "<leader>ws";
              action = "<C-w>s";
              options.desc = "Split horizontally";
            }
            {
              key = "<leader>wq";
              action = "<C-w>q";
              options.desc = "Close window";
            }
            {
              key = "<leader>w=";
              action = "<C-w>=";
              options.desc = "Equalize windows";
            }

            # ── Toggles ────────────────────────────────────────────────
            {
              key = "<leader>e";
              action = ":Neotree toggle<CR>";
              options.desc = "Toggle file explorer";
            }
            {
              key = "<leader>o";
              action = ":AerialToggle<CR>";
              options.desc = "Toggle code outline";
            }
            {
              key = "<leader>tt";
              action = ":ToggleTerm<CR>";
              options.desc = "Toggle terminal";
            }
            {
              key = "<leader>tl";
              action = ":ToggleTerm direction=vertical size=80<CR>";
              options.desc = "Toggle vertical terminal";
            }
            {
              key = "<leader>xx";
              action = ":TroubleToggle<CR>";
              options.desc = "Toggle diagnostics";
            }
            {
              key = "<leader>u";
              action = ":UndotreeToggle<CR>";
              options.desc = "Toggle undo tree";
            }
            {
              key = "<leader>ll";
              action = ":LazyGit<CR>";
              options.desc = "Open lazygit";
            }

            # ── Flash navigation ───────────────────────────────────────
            {
              key = "s";
              action = "<cmd>Flash<CR>";
              options.desc = "Flash jump";
              mode = "n";
            }
            {
              key = "S";
              action = "<cmd>FlashTreesitter<CR>";
              options.desc = "Flash treesitter";
              mode = "n";
            }
            {
              key = "r";
              action = "<cmd>FlashRemote<CR>";
              options.desc = "Flash remote";
              mode = "o";
            }

            # ── Search ─────────────────────────────────────────────────
            {
              key = "<Esc><Esc>";
              action = "<cmd>nohlsearch<CR>";
              options.desc = "Clear search highlights";
            }
            {
              key = "n";
              action = "nzzzv";
              options.desc = "Center on next match";
            }
            {
              key = "N";
              action = "Nzzzv";
              options.desc = "Center on previous match";
            }

            # ── Visual mode ────────────────────────────────────────────
            {
              key = "<";
              action = "<<";
              options.desc = "Indent left";
              mode = "v";
            }
            {
              key = ">";
              action = ">>";
              options.desc = "Indent right";
              mode = "v";
            }
            {
              key = "J";
              action = ":m '>+1<CR>gv=gv";
              options.desc = "Move selection down";
              mode = "v";
            }
            {
              key = "K";
              action = ":m '<-2<CR>gv=gv";
              options.desc = "Move selection up";
              mode = "v";
            }
          ];

          # ════════════════════════════════════════════════════════════════
          #  EXTRA LUA CONFIG
          # ════════════════════════════════════════════════════════════════
          extraConfigLuaPre = ''
            -- Diagnostic symbols in sign column
            local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = "󰋼 " }
            for type, icon in pairs(signs) do
              local hl = "DiagnosticSign" .. type
              vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
            end

            -- LSP attach: auto-format on save, keymaps, etc.
            vim.api.nvim_create_autocmd("LspAttach", {
              group = vim.api.nvim_create_augroup("UserLspConfig", {}),
              callback = function(ev)
                -- Buffer-local keymaps that depend on LSP
                local bufopts = { noremap = true, silent = true, buffer = ev.buf }
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
                vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
                vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
                vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, bufopts)
                vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
                vim.keymap.set("n", "<leader>wl", function()
                  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, bufopts)
                vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, bufopts)
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
                vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, bufopts)
                vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
                vim.keymap.set("n", "<leader>f", function()
                  vim.lsp.buf.format({ async = true })
                end, bufopts)
              end,
            })
          '';

          extraConfigLua = ''
            -- System clipboard
            vim.keymap.set({ "n", "x" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
            vim.keymap.set({ "n", "x" }, "<leader>p", [["+p]], { desc = "Paste from clipboard" })
            vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to clipboard" })

            -- Exit terminal mode
            vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

            -- Better terminal navigation
            vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Terminal: left split" })
            vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Terminal: lower split" })
            vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Terminal: upper split" })
            vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Terminal: right split" })

            -- Highlight on yank
            vim.api.nvim_create_autocmd("TextYankPost", {
              pattern = "*",
              callback = function()
                vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
              end,
            })

            -- Auto-close neo-tree when it's the last window
            vim.api.nvim_create_autocmd("BufEnter", {
              group = vim.api.nvim_create_augroup("NeoTreeClose", {}),
              callback = function()
                if vim.api.nvim_get_option_value("filetype", { buf = 0 }) == "neo-tree"
                  and vim.fn.winnr("$") == 1 then
                  vim.cmd("q")
                end
              end,
            })

            -- Restore cursor position
            vim.api.nvim_create_autocmd("BufReadPost", {
              pattern = "*",
              callback = function()
                local mark = vim.api.nvim_buf_get_mark(0, '"')
                local lcount = vim.api.nvim_buf_line_count(0)
                if mark[1] > 0 and mark[1] <= lcount then
                  pcall(vim.api.nvim_win_set_cursor, 0, mark)
                end
              end,
            })

            -- Lazygit integration: :LazyGit command
            vim.api.nvim_create_user_command("LazyGit", function()
              local term = require("toggleterm.terminal").Terminal:new({
                cmd = "lazygit",
                direction = "float",
                float_opts = { border = "rounded" },
              })
              term:toggle()
            end, { desc = "Open lazygit" })
          '';

          # ── Extra plugins not natively supported by nixvim ──────────
          extraPlugins = with pkgs.vimPlugins; [
            undotree
          ];
        };

        # ── Lazygit (IDE Git integration) ─────────────────────────────
        environment.systemPackages = with pkgs; [
          lazygit
          stylua
          black
          prettierd
          rustfmt
          google-java-format
        ];
      };
    };
}
