#!/usr/bin/env bash


if [[ $SHELL != *"zsh"* ]];
then
  echo "Installing oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi


if ! xcode-select -p > /dev/null;
then
  echo "Installing xcode CLI tools"
  xcode-select --install
fi

if ! command -v brew > /dev/null;
then
  echo "Installing Homebrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi


echo "Linking files"
mkdir -p  ~/.dotfiles_backup
for f in "aliases" "exports" "functions" "vimrc" "zshrc"; do
  echo "Linking \"$f\""
  if [ -f ~/.$f ]; then
    echo "Original file exists, backing it up"
    mv ~/.$f ~/.dotfiles_backup/$f
  fi
  ln -s ~/.dotfiles/$f ~/.$f
  echo "Linked \"$f\""
done


# link Sublime Text
if [ -f "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ] \
&& [ ! -e /usr/local/bin/subl ]; then
  ln -sv "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl
else
  echo "already exists, skipping"
fi

software_list=( bash tig icdiff vim zsh-syntax-highlighting \
  zsh-autosuggestions python3 )
for item in "${software_list[@]}"; do
  if ! brew list | grep -q "$item"; then
    echo "installing fresh $item"
    brew install "$item"
  else
    echo "upgrading $item"
    brew upgrade "$item" 2>/dev/null
  fi
done

if [ ! -f ~/.vim/autoload/plug.vim ]; then
  echo "Installing Vim-Plug"
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo "Configuring VIM"
vim +PlugInstall +qall

sudo pip3 install virtualenv virtualenvwrapper

echo "Done configuring the system, please reboot :D"
