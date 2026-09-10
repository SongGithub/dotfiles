#!/bin/bash
# this script initialises a new computer with shell settings I am familar with
#
# Uses the system /bin/bash (not `env bash`) so a stray x86_64-only bash
# earlier on PATH (e.g. a stale Homebrew install) can't silently pull this
# whole script under Rosetta.

set -e

# This bootstrap targets Apple Silicon only. If still somehow invoked from a
# Rosetta (x86_64) shell, re-launch natively -- CLT's xcrun/libxcrun no
# longer ships x86_64 slices, so oh-my-zsh's git clone (and other tools)
# fail deep inside with a cryptic "unable to load libxcrun" error otherwise.
if [ "$(uname -m)" != "arm64" ]; then
  if arch -arm64 /usr/bin/true 2>/dev/null; then
    echo "Detected Rosetta (x86_64) shell; re-launching natively on arm64..."
    exec arch -arm64 /bin/bash "$0" "$@"
  else
    echo "This bootstrap targets Apple Silicon (arm64); this Mac can't run arm64 binaries." >&2
    exit 1
  fi
fi

if [ -d ~/.oh-my-zsh ]; then
  echo "oh-my-zsh already installed, skipping"
else
  echo "Installing oh-my-zsh"
  # --unattended forces RUNZSH=no and CHSH=no. Without it, when stdin is a
  # tty the installer defaults to *interactive*: it execs a new zsh shell
  # (and/or prompts for a chsh password) after printing its banner, which
  # hands control away from this script instead of returning to it -- this
  # is why bootstrap looked like it stopped dead right after the oh-my-zsh
  # ascii art, with everything after (uv tool install, which creates
  # ~/.local/bin) never running.
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
fi

echo "Installing xcode CLI tools"
xcode-select --install || true

if ! command -v brew > /dev/null;
then
  echo "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Must run every time, not just on fresh install: this is what makes
# /opt/homebrew/bin win over any stale /usr/local Homebrew leftovers (e.g. an
# old x86_64 vim) for the rest of this script. Without it, a script invoked
# with the pre-Homebrew system PATH (/usr/local/bin first) silently runs
# whatever old Intel binaries are still sitting in /usr/local -- which is
# exactly what crashed `vim +PlugInstall` with a dyld "Library not loaded"
# abort against a liblua path that no longer exists.
eval "$(/opt/homebrew/bin/brew shellenv)"


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
