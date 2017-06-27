#!/usr/bin/env zsh

DIR="$( echo "$( dirname "$0" )" && pwd )"

if [[ $SHELL != *"zsh"* ]]; 
then
  echo "Installing oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

xcode-select -p > /dev/null
if [ $? -ne 0 ]; 
then
  echo "Installing xcode CLI tools"
  xcode-select --install
fi

if ! command -v brew > /dev/null;
then
  echo "Installing Homebrew"
  #/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "Linking files"
mkdir -p  ~/.dotfiles_backup
for f in "aliases" "exports" "functions" "vimrc" "zshrc"
do
  echo "Linking \"$f\"" 
  if [ -f ~/.$f ]; then
    echo "Original file exists, backing it up"
    mv ~/.$f ~/.dotfiles_backup/$f
  fi
  ln -s ~/.dotfiles/$f ~/.$f
  echo "Linked \"$f\""
done

echo "Installing zsh-syntax-highlighting"
brew install zsh-syntax-highlighting

# Install vim + plugins
brew install vim --with-lua

if [ ! -f ~/.vim/autoload/plug.vim ];
then
  echo "Installing Vim-Plug"
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo "Configuring VIM"
vim +PlugInstall +qall

brew install tig icdiff

echo "Done configuring the system, please reboot :D"
