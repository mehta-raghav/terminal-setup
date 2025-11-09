#!/usr/bin/env zsh
# ==========================================================
# macOS fresh setup (zsh, non-interactive, idempotent)
# Homebrew FIRST, then:
# - git (brew)
# - uv (brew, fallback to tap or installer)
# - Python 3.13 via uv (NOT via Homebrew)
# - starship (brew) + starship.toml from PUBLIC GitHub
# - oh-my-zsh (unattended)
# - PATH & shell config wiring
# ==========================================================

set -euo pipefail

# ---------- EDIT THESE (PUBLIC GITHUB for starship.toml) ----------
STARSHIP_GH_USER="mehta-raghav"             # e.g., mehta-raghav
STARSHIP_GH_REPO="terminal-setup"           # e.g., dotfiles
STARSHIP_GH_BRANCH="main"                   # e.g., main or master
STARSHIP_FILE_PATH="config/starship.toml"   # e.g. "config/starship.toml"

# Optional: fetch your .zshrc from a public raw URL (leave empty to skip)
ZSHRC_RAW_URL=""  # e.g., https://raw.githubusercontent.com/you/dotfiles/main/.zshrc

# ==========================================================
# Helpers
# ==========================================================
c_green=$'%{\e[32m%}'; c_yellow=$'%{\e[33m%}'; c_red=$'%{\e[31m%}'; c_reset=$'%{\e[0m%}'
info()  { print -P "${c_green}==>${c_reset} $*"; }
warn()  { print -P "${c_yellow}==>${c_reset} $*"; }
error() { print -P "${c_red}==> ERROR:${c_reset} $*"; }

[[ "$(uname -s)" == "Darwin" ]] || { error "This script is for macOS."; exit 1; }
[[ -n "${ZSH_VERSION:-}" ]]      || { error "Run with zsh:  zsh setup_mac.zsh"; exit 1; }

# Keep sudo alive once; no further prompts
if ! sudo -n true 2>/dev/null; then
  info "Requesting admin privileges once (kept alive during install)…"
  sudo -v
fi
( while true; do sudo -n true 2>/dev/null || exit; sleep 60; kill -0 $$ || exit; done ) &

append_once() {
  local file="$1"; shift
  local line="$*"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  grep -Fqx "$line" "$file" || echo "$line" >> "$file"
}

backup_if_exists() {
  local p="$1"
  [[ -f "$p" ]] || return 0
  local ts; ts="$(date +%Y%m%d-%H%M%S)"
  cp -f "$p" "${p}.bak.${ts}"
  warn "Backed up ${p} -> ${p}.bak.${ts}"
}

fetch_public_raw() {
  local url="$1" dst="$2"
  [[ -n "$url" ]] || return 0
  backup_if_exists "$dst"
  curl -fsSL "$url" -o "$dst"
  [[ -s "$dst" ]] || { error "Downloaded empty file from $url"; return 1; }
  info "Fetched $url -> $dst"
}

# Detect arch for Homebrew prefix
ARCH="$(uname -m)"
if [[ "$ARCH" == "arm64" ]]; then
  HB_PREFIX="/opt/homebrew"
else
  HB_PREFIX="/usr/local"
fi


# ==========================================================
# 2) Install XCode if not already installed
# ==========================================================
xcode-select --install


# ==========================================================
# 1) Install Homebrew FIRST (NONINTERACTIVE).
#    If CLT missing and brew install fails, we headlessly install CLT then retry.
# ==========================================================
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Make brew available now and for future shells
eval "$("$HB_PREFIX/bin/brew" shellenv)"
append_once "$HOME/.zprofile" 'eval "$('"$HB_PREFIX"'/bin/brew shellenv)"'
append_once "$HOME/.zshrc"    'eval "$('"$HB_PREFIX"'/bin/brew shellenv)"'


# ==========================================================
# 2) Install via brew: git, uv, starship
# ==========================================================
brew install git uv starship
echo 'eval "$(starship init zsh)"' >> ~/.zshrc              # Enable starship prompt

# --- uv on PATH (covers both official installer/tap layouts) ---
echo 'export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"' >> ~/.zprofile
echo 'export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"' >> ~/.zshrc


# ==========================================================
# 3) Python 3.13 via uv and make Python 3.13 the default for interactive shells using aliases.
# ==========================================================
uv python install 3.13
uv python pin 3.13


# ==========================================================
# 4) starship.toml from PUBLIC GitHub (fallback to preset)
# ==========================================================
mkdir -p "$HOME/.config"
STARSHIP_DEST="$HOME/.config/starship.toml"
STARSHIP_RAW_URL="https://raw.githubusercontent.com/${STARSHIP_GH_USER}/${STARSHIP_GH_REPO}/${STARSHIP_GH_BRANCH}/${STARSHIP_FILE_PATH}"

cp -f "$STARSHIP_DEST" "$STARSHIP_DEST.bak.$(date +%Y%m%d-%H%M%S)" 2>/dev/null || true
curl -fsSL "$STARSHIP_RAW_URL" -o "$STARSHIP_DEST" || true
[[ -s "$STARSHIP_DEST" ]] || starship preset catppuccin-powerline -o "$STARSHIP_DEST" || true

# ==========================================================
# 5) oh-my-zsh (unattended; idempotent)
# ==========================================================
RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# ==========================================================
# 6) Fetch your .zshrc from the SAME repo (config/.zshrc)
# ==========================================================
ZSHRC_RAW_URL="https://raw.githubusercontent.com/${STARSHIP_GH_USER}/${STARSHIP_GH_REPO}/${STARSHIP_GH_BRANCH}/config/.zshrc"
cp -f "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%Y%m%d-%H%M%S)" 2>/dev/null || true
curl -fsSL "$ZSHRC_RAW_URL" -o "$HOME/.zshrc"

# ==========================================================
# Final checks
# ==========================================================
echo
echo "Installed:"
(brew --version | head -n1) || true
(git --version | head -n1) || true
(uv --version) || true
(uv run python -V) || true
(starship --version) || true

echo
echo "Done. Reload shell:  exec \$SHELL -l"
echo "Expect Python 3.13 via uv"