{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.vim ];

  # rc_files/vimrc kept as a plain file (vim-plug's `Plug` calls plus the
  # go/neocomplete/tagbar vimscript settings) rather than translated into
  # home-manager's `programs.vim` plugin-management DSL -- that would be a
  # redesign, not a like-for-like port.
  home.file.".vimrc".source = ../rc_files/vimrc;

  # Same two steps bootstrap.zsh ran: install vim-plug itself if missing,
  # then run PlugInstall. `vim +PlugInstall +qall` is itself idempotent
  # (only fetches plugins that aren't already there), so running it on every
  # activation is safe, exactly as it was safe on every bootstrap.zsh run.
  home.activation.vimPlug = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
      run ${pkgs.curl}/bin/curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
    run ${pkgs.vim}/bin/vim +PlugInstall +qall
  '';
}
