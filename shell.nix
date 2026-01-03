let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-25.11";
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
    export _NIX_ZDOTDIR="$PWD/.zsh-nix-shell"
    mkdir -p "$_NIX_ZDOTDIR"

    export ZSH_AUTOSUGGESTIONS=${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions
    export ZSH_SYNTAX_HIGHLIGHTING=${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting
    export POWERLEVEL10K=${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k

    # zshrc
    cat > "$_NIX_ZDOTDIR/.zshrc" <<'EOF'
# -----------------------------
# Nix-shell scoped zshrc
# -----------------------------

# -------------------------------------------------
# Powerlevel10k instant prompt (must be near top)
# -------------------------------------------------
if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
  source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
fi

POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# Oh My Zsh (Nix-provided)
export ZSH="${pkgs.oh-my-zsh}/share/oh-my-zsh"

# Note: ZSH_THEME disabled because we'll source Powerlevel10k manually
ZSH_THEME=""

DISABLE_AUTO_TITLE="true"        # Let tmux handle window titles
COMPLETION_WAITING_DOTS="true"

# Plugins (same as your list)
plugins=(git colored-man-pages python)

# Load Oh My Zsh
source "$ZSH/oh-my-zsh.sh"

# Manual sourcing (Nix-provided) — mirrors your Homebrew setup style
source "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Powerlevel10k theme (manual)
# If you use an existing ~/.p10k.zsh, it will still be picked up if you source it.
source "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"

# Optional: if you have a p10k config in your repo, prefer it:
# [[ -f "$PWD/.p10k.zsh" ]] && source "$PWD/.p10k.zsh"
# Or use your global one:
# [[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# --- fzf + fd Integration ---
# Use fd instead of find for better performance and smarter defaults
# fd automatically respects .gitignore and is much faster

# Default command for fzf (Ctrl+T): find files and directories
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Preview command: show directory tree with eza or file content with bat
export _fzf_preview_cmd="if [ -d {} ]; then eza -a --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

# Ctrl+T options: fuzzy find files/directories with preview
export FZF_CTRL_T_OPTS="
  --preview '$_fzf_preview_cmd'
  --preview-window right:60%:wrap
  --bind 'ctrl-/:toggle-preview'
"

# Alt+C command: find directories only
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Alt+C options: directory navigation with tree preview
export FZF_ALT_C_OPTS="
  --preview 'eza -a --tree --color=always {} | head -200'
  --preview-window right:60%:wrap
  --bind 'ctrl-/:toggle-preview'
"

# Context-aware fzf completions (triggered with **)
# Provides custom previews based on the command being used
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza -a --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}

# To customize prompt, run `p10k configure` or edit ~/.dotfiles/zsh/.p10k.zsh.
source .dotfiles/zsh/.p10k.zsh
EOF

    # Git config
    export GIT_CONFIG_GLOBAL="$PWD/.gitconfig.nix-shell"

    cat > "$GIT_CONFIG_GLOBAL" <<'EOF'
[core]
  pager = delta

[interactive]
  diffFilter = delta --color-only

[delta]
  navigate = true
  side-by-side = true
  line-numbers = true
  syntax-theme = 1337
EOF


    if [ -z "''${IN_NIX_ZSH:-}" ] && [ -t 1 ]; then
      export IN_NIX_ZSH=1
      export ZDOTDIR="$_NIX_ZDOTDIR"
      exec zsh -i
    fi
  '';
}
