# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set theme to powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# Oh My Zsh plugins
plugins=(
  git
  docker
  docker-compose
  flutter
  zsh-autosuggestions
  zsh-syntax-highlighting
  command-not-found
  history
  sudo
  web-search
  z
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8
export EDITOR='vim'

# NPM global packages in user directory
export PATH="$HOME/.npm-global/bin:$PATH"

# Make package installation commands work without sudo
alias npm='npm'
alias apt='sudo apt'
alias apt-get='sudo apt-get'
alias snap='sudo snap'

# Flutter and Android paths (already set in Dockerfile)
export PATH="$PATH:$HOME/flutter/bin"
export PATH="$PATH:$HOME/android-sdk/cmdline-tools/latest/bin"
export PATH="$PATH:$HOME/android-sdk/platform-tools"

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'

# Flutter aliases
alias fl='flutter'
alias flr='flutter run'
alias flb='flutter build'
alias flt='flutter test'
alias flc='flutter clean'
alias flpg='flutter pub get'
alias fld='flutter doctor'
alias flw='flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'

# Docker aliases
alias dc='docker-compose'
alias dps='docker ps'

# GCP & Firebase aliases
alias gcl='gcloud'
alias fb='firebase'
alias fbdeploy='firebase deploy'
alias fbserve='firebase serve'
alias gcproject='gcloud config get-value project'

# GitHub CLI aliases
alias ghrepo='gh repo'
alias ghpr='gh pr'
alias ghissue='gh issue'

# Testing and automation aliases
alias lighthouse-test='lighthouse --chrome-flags="--headless --no-sandbox"'
alias puppeteer-test='node -e "const puppeteer = require(\"puppeteer\"); (async () => { const browser = await puppeteer.launch({headless: true, args: [\"--no-sandbox\"]}); console.log(\"Puppeteer ready!\"); await browser.close(); })()"'
alias playwright-test='npx playwright test'
alias axe-test='axe'
alias perf-audit='sitespeed.io'
alias security-scan='retire'

# AI Agent helper aliases
alias ai-help='~/ai-agent-helpers.sh'
alias web-dev='~/flutter-web-dev.sh'
alias check='~/ai-agent-helpers.sh check'
alias serve='~/ai-agent-helpers.sh serve'
alias deploy='~/ai-agent-helpers.sh deploy'
alias build-web='~/flutter-web-dev.sh build'
alias test-web='~/flutter-web-dev.sh test'
alias analyze='~/flutter-web-dev.sh analyze'
alias install-package='~/install-package.sh'

# Container management aliases
alias container-status='~/show-container-config.sh'
alias container-info='~/show-container-config.sh'

# Quick commands for AI agents (work from current directory if pubspec.yaml exists)
alias quick-serve='if [ -f pubspec.yaml ]; then flutter run -d web-server --web-port=${WEB_PORT:-8080} --web-hostname=0.0.0.0; else echo "Run from a Flutter project directory"; fi'
alias quick-build='if [ -f pubspec.yaml ]; then flutter build web --release; else echo "Run from a Flutter project directory"; fi'
alias quick-test='if [ -f pubspec.yaml ]; then flutter test; else echo "Run from a Flutter project directory"; fi'
alias quick-fix='if [ -f pubspec.yaml ]; then dart fix --apply && dart format .; else echo "Run from a Flutter project directory"; fi'

# Enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Run authentication setup on first interactive shell
if [ ! -f ~/.auth-setup-completed ] && [ -f ~/setup-authentication.sh ]; then
    ~/setup-authentication.sh && touch ~/.auth-setup-completed
fi

# Setup MCP server on first run (for fresh Claude installation)
if [ ! -f ~/.claude-mcp-configured ] && command -v claude &> /dev/null; then
    echo "🔧 Setting up MCP server..."
    # Initialize Claude config if needed
    mkdir -p ~/.claude
    if [ ! -f ~/.claude.json ]; then
        echo '{}' > ~/.claude.json
    fi
    # Add MCP server
    claude mcp add --transport sse context7 https://mcp.context7.com/sse 2>/dev/null && touch ~/.claude-mcp-configured || true
fi

# Welcome message
echo "🚀 Welcome to Momentous Flutter Development Environment - ${AGENT_NAME:-Development} Container"
echo "📱 Flutter $(flutter --version | head -n 1 | cut -d' ' -f2) is ready!"
echo "💡 Type 'flw' to run Flutter web on port ${WEB_PORT:-8080}"
echo "🤖 Claude Code is available - use 'claude login' to authenticate"
echo "📡 MCP server context7 is pre-configured"
echo "🧪 Testing tools: lighthouse, puppeteer, playwright, axe-core available"