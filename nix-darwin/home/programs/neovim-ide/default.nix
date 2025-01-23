{ pkgs, ... }:
{

  programs.neovim-ide = {
    enable = false;
    settings = {
      vim = {
        neovim.package = pkgs.neovim-nightly;
        viAlias = false;
        vimAlias = true;
        preventJunkFiles = true;
        cmdHeight = 2;
        autocomplete = {
          enable = true;
        };
        autopairs = {
          enable = true;
        };
        colorColumn = {
          enable = true;
          column = 120;
        };
        customPlugins = with pkgs.vimPlugins; [
          multiple-cursors
          vim-repeat
        ];
        dap = {
          enable = false;
          csharp = true;
          scala = true;
        };
        mapLeaderSpace = true;
        filetree = {
          enable = true;
          yazi.enable = true;
          # oil.enable = true;
        };
        format = {
          conform = {
            enable = true;
          };
        };
        git = {
          enable = true;

          gitsigns.enable = true;
          # Handled by snacks.nvim
          lazygit.enable = false;
        };
        harpoon = {
          enable = true;
        };
        keys = {
          enable = true;
          whichKey.enable = true;
        };
        lsp = {
          enable = true;
          folds = true;
          formatOnSave = false;
          clang = true;
          codeActions.enable = true;
          csharp = {
            enable = true;
            type = "csharp_ls";
          };
          go = true;
          haskell = true;
          nix = {
            enable = true;
          };
          rust = {
            enable = false;
          };
          scala = {
            enable = true;
            metals = {
              package = pkgs.callPackage ./metals.nix { };
              # best effort compilation + vs code default settings
              # see https://github.com/scalameta/metals-vscode/blob/1e10e1a71cf81569ea65329ec2aa0aa1cb6ad682/packages/metals-vscode/package.json#L232
              serverProperties = [
                "-Dmetals.enable-best-effort=true"
                "-Xmx2G"
                "-XX:+UseZGC"
                "-XX:ZUncommitDelay=30"
                "-XX:ZCollectionInterval=5"
                "-XX:+IgnoreUnrecognizedVMOptions"
              ];
            };
          };

          trouble.enable = true;
        };
        markdown = {
          enable = true;
          render.enable = true;
        };
        mini = {
          enable = true;
          ai.enable = true;
          completion.enable = true;
          icons.enable = true;
          indentScope.enable = true;
          hipatterns.enable = true;
          statusLine.enable = true;
          surround.enable = true;
        };
        notifications = {
          enable = true;
        };
        snippets = {
          vsnip.enable = true;
        };
        telescope = {
          enable = true;
          tabs.enable = true;
          mediaFiles.enable = false;
        };
        theme = {
          enable = true;
          name = "gruber-darker";
          # style = "deep";
          transparency = true;
        };
        treesitter = {
          enable = true;
          autotagHtml = true;
          context.enable = false;
        };
        visuals = {
          enable = true;
          noice.enable = true;
          nvimWebDevIcons.enable = true;
        };
      };
    };
  };
}
