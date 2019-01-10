# dotfiles


## Why you need this

- Setup a new machine with exactly same familiar settings in __one__ go.
- Keep installed software up to date.
- Ease of maintain your dotfiles: this even adopts programming concept of _separate-of-concern_


## What is this about:

Just a bunch of dotfiles

- zsh
- vim
- homebrew
- aliases
- ...

## Getting started
- install iTerm2 and follow [this doc](https://apple.stackexchange.com/questions/136928/using-alt-cmd-right-left-arrow-in-iterm) to customise.
- Clone source code `git clone git@github.com:songgithub/dotfiles.git ~/.dotfiles`
- Run setup script `./bootstrap.zsh`


## when you need to add a new RC file

- put the `*_rc` file into rc_files dir
- `cd` into `~/.dotfiles`, and run `~/bootstrap.zsh` in order to create a symlink for the new file.

## Reference

[Gus's dotfile](https://github.com/gugahoi/dotfiles)
