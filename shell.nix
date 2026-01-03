let
  nixpkgs = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/tarball/nixos-25.11";
    sha256 = "1ynrqn0zpdcfggdkgvi62ijf72lmiwp1pbv8lc8f16xadjww43y8";
  };
  pkgs = import nixpkgs { config = {}; overlays = []; };
in

pkgs.mkShellNoCC {
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
}
