#!/usr/bin/env bash
# this script initialises a new computer with shell settings I am familar with

set -e

if [ -d ~/.oh-my-zsh ]; then
  echo "oh-my-zsh already installed, skipping"
else
  echo "Installing oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

echo "Installing xcode CLI tools"
xcode-select --install || true

if ! command -v brew > /dev/null;
then
  echo "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi


echo "Linking RC files "
mkdir -p  ~/.dotfiles_backup

for f in rc_files/*; do
  file_name=$(basename "$f")
  echo "  processing RC file: \"$file_name\""

  if [ -e ~/.$file_name ] || [ -L ~/.$file_name ]; then
    echo "    Original file/symlink exists, backing it up"
    mv ~/.$file_name ~/.dotfiles_backup/$file_name
  fi
  echo "    *********** Linking \"$file_name\""
  echo "    SOURCE FILE PATH: ""$PWD"/$f
  ln -s "$PWD"/$f ~/.$file_name
  echo "    Linked \"$file_name\""
done


echo "link Sublime Text"
subl_src="/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl"
subl_bin_dir=/opt/homebrew/bin

if [ -f "$subl_src" ] && [ ! -e "$subl_bin_dir/subl" ]; then
  ln -sv "$subl_src" "$subl_bin_dir/subl"
else
  echo "already exists, skipping"
fi


echo "Creating workspace folder"
mkdir -p ~/workspace


echo "brew installs"
software_list=( gcc bash tig icdiff
  vim zsh-syntax-highlighting \
  zsh-autosuggestions python kubectx watch uv )
for item in "${software_list[@]}"; do
  if ! brew list | grep -q "$item"; then
    echo "Installing fresh $item"
    brew install "$item"
    # add comment and 'source' cmd only if it was not already in zshrc file
    if [ "$item" == "zsh-autosuggestions" ] && ! grep -q "# adding zsh-autosuggestions.zsh" "zshrc" ; then
      echo "Also adding source to zshrc file..."
      printf "\
        \n\n# adding zsh-autosuggestions.zsh \
        \nsource /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> zshrc
    fi
  else
    echo "attempt to upgrade $item"
    # brew upgrade "$item" || true
  fi
done

echo "Installing uv tools (GitHub Spec Kit / specify)"
# uv drops entrypoints into ~/.local/bin, which rc_files/exports puts on PATH.
# Deliberately not using `uv tool update-shell` -- that writes an untracked
# ~/.zshenv, which does not follow you to the next machine.
uv_tool_list=( specify-cli )
for tool in "${uv_tool_list[@]}"; do
  if uv tool list 2>/dev/null | grep -q "^$tool "; then
    echo "  $tool already installed, upgrading"
    uv tool upgrade "$tool" || true
  else
    echo "  Installing $tool"
    uv tool install "$tool"
  fi
done

if [ ! -f ~/.vim/autoload/plug.vim ]; then
  echo "Installing Vim-Plug"
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo "Configuring VIM"
vim +PlugInstall +qall

cp patches/minimap_settings.py  ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User

echo "Done configuring the system......."
