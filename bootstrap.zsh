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
for f in "aliases" "exports" "functions" "vimrc" "zshrc" "kuberc" "admin_kuberc" "myob_rc"; do
  echo "Linking \"$f\""
  if [ -f ~/.$f ]; then
    echo "Original file exists, backing it up"
    mv ~/.$f ~/.dotfiles_backup/$f
  fi
  ln -s ~/.dotfiles/$f ~/.$f
  echo "Linked \"$f\""
done


echo "Linking RC files"
mkdir -p  ~/.dotfiles_backup

# for filename in ./rc_files/*; do echo "put ${filename}"; done

for f in ./rc_files/*; do
  echo "Linking RC files\"$f\""
  if [ -f ~/.$f ]; then
    echo "Original file exists, backing it up"
    mv ~/.$f ~/.dotfiles_backup/$f
  fi
  ln -s ~/.dotfiles/rc_files/$f ~/.$f
  echo "Linked \"$f\""
done


# link Sublime Text
if [ -f "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ] \
&& [ ! -e /usr/local/bin/subl ]; then
  ln -sv "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl
else
  echo "already exists, skipping"
fi


# brew installs
software_list=( bash tig icdiff vim zsh-syntax-highlighting \
  zsh-autosuggestions python3 )
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


# pip installs

software_list=( virtualenv virtualenvwrapper )
for item in "${software_list[@]}"; do
  if ! pip3 freeze | grep -q "$item"==*; then
    echo "installing fresh $item"
    pip3 install --user "$item"
  else
    echo "upgrading $item"
    pip3 install --user --upgrade "$item"
  fi
done


echo "Done configuring the system, please reboot :D"
