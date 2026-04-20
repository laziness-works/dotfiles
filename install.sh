#!/bin/bash

install_app() {
  local COMMAND_NAME=$1
  local INSTALL_SCRIPT=$2
  local POST_INSTALL_SCRIPT=$3
  echo "┌──────────────────────────────────────────────────┐"
  echo "│ $(printf %-49s "$COMMAND_NAME")│"
  echo "└──────────────────────────────────────────────────┘"
  echo "│"
  local ALREADY_INSTALLED=false
  if command -v "$COMMAND_NAME" &> /dev/null; then
    local ALREADY_INSTALLED=true
  elif brew list "$COMMAND_NAME" &> /dev/null; then
    local ALREADY_INSTALLED=true
  fi
  if [[ "$ALREADY_INSTALLED" == "false" ]]; then
    echo "│ 🛠️ Installing: $INSTALL_SCRIPT"
    eval "$INSTALL_SCRIPT"
    local EXIT_CODE=$?
    if [[ $EXIT_CODE -eq 0 ]]; then
      if [[ -n $POST_INSTALL_SCRIPT ]]; then
        echo "│ ⚙️ Running post-install steps...: $POST_INSTALL_SCRIPT"
        eval "$POST_INSTALL_SCRIPT"
      fi
      source /etc/zprofile
      source "$HOME/.zprofile"
      echo "│ ✅ Installation successful!"
    else
      echo "│ ❌ Installation failed with exit code $EXIT_CODE"
      exit 1
    fi
  else
    echo "│ ✅ $COMMAND_NAME is already installed."
  fi
  echo "│"
}

brew_post_install_script() {
  {
    echo ""
    echo "# Homebrew"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"'
  } >> "$HOME/.zprofile"
}
install_app brew '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' 'brew_post_install_script'

install_app rosetta 'softwareupdate --install-rosetta --agree-to-license'

install_app google-chrome 'brew install --cask google-chrome'

install_app docker 'brew install --cask docker'
