{
  description = "Dotfiles dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; config = {}; overlays = []; };
        in
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              # CLI tools
              stow
              fzf
              fd
              bat
              eza
              delta

              # Zsh plugins & theme
              zsh-autosuggestions
              zsh-syntax-highlighting
              zsh-powerlevel10k

              # Terminal emulator
              ghostty-bin
            ];

            shellHook = ''
              export IN_NIX_ZSH=1

              # Read-only dotfiles content (flake source)
              export DOTFILES_DIR="${toString self}/.dotfiles"

              # Writable zsh runtime dir (outside /nix/store)
              export ZDOTDIR="''${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles-zsh"
              mkdir -p "$ZDOTDIR"

              # Make zsh use the repo's nix-shell zshrc
              ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$ZDOTDIR/.zshrc"

              # Point zsh state to writable locations
              export ZSH_CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
              mkdir -p "$ZSH_CACHE_DIR"/{sessions,compdump} 2>/dev/null
              export ZSH_SESSION_DIR="$ZSH_CACHE_DIR/sessions"
              export ZSH_COMPDUMP="$ZSH_CACHE_DIR/compdump/zcompdump-$ZSH_VERSION"
              export HISTFILE="$ZSH_CACHE_DIR/history"
              export HISTSIZE=10000
              export SAVEHIST=10000

              # Nix-provided paths
              export OMZ_DIR="${pkgs.oh-my-zsh}/share/oh-my-zsh"
              export ZSH_AUTOSUGGESTIONS_DIR="${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions"
              export ZSH_SYNTAX_HIGHLIGHTING_DIR="${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting"
              export P10K_THEME="${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"

              export GIT_CONFIG_GLOBAL="$DOTFILES_DIR/git/.gitconfig"

              exec zsh -i
            '';
          };
        });
    };
}
