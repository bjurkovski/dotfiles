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
              export DOTFILES_DIR="$PWD/.dotfiles"
              export ZDOTDIR="$DOTFILES_DIR/zsh"

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
