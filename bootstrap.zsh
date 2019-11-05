#!/usr/bin/env bash
# this script initialises a new computer with shell settings I am familar with

set -ex

echo "Installing xcode CLI tools"
xcode-select --install || true

if ! command -v brew > /dev/null;
then
  echo "Installing Homebrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "Linking RC files "
mkdir -p  ~/.dotfiles_backup

for f in rc_files/*; do
  file_name=$(basename "$f")
  echo "  processing RC file: \"$file_name\""

  if [ -L ~/.$file_name ]; then
    echo "    Original symlink exists, backing it up"
    mv ~/.$file_name ~/.dotfiles_backup/$file_name
  fi
  echo "    *********** Linking \"$file_name\""
  echo "    SOURCE FILE PATH: ""$PWD"/$f
  ln -s "$PWD"/$f ~/.$file_name 2> /dev/null # || echo "error linking files" && exit 1
  echo "    Linked \"$file_name\""
done


# echo "link Sublime Text"
# if [ -f "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ] \
# && [ ! -e /usr/local/bin/subl ]; then
#   ln -sv "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl
# else
#   echo "already exists, skipping"
# fi


echo "brew installs"
software_list=(  bash tig icdiff
  vim zsh-syntax-highlighting \
  zsh-autosuggestions watch )
for item in "${software_list[@]}"; do
  if ! brew list | grep -q "$item"; then
    echo "Installing fresh $item"
    brew install "$item"
    # add comment and 'source' cmd only if it was not already in zshrc file
    if [ "$item" == "zsh-autosuggestions" ] && ! grep -q "# adding zsh-autosuggestions.zsh" "zshrc" ; then
      echo "Also adding source to zshrc file..."
      printf "\
        \n\n# adding zsh-autosuggestions.zsh \
        \nsource /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> zshrc
    fi
  else
    echo "attempt to upgrade $item"
    # brew upgrade "$item" || true
  fi
done

if [ ! -f ~/.vim/autoload/plug.vim ]; then
  echo "Installing Vim-Plug"
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo "Configuring VIM"
vim +PlugInstall +qall

# cp patches/minimap_settings.py  ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User

echo "Done configuring the system......."
