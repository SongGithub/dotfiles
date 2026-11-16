{ pkgs, ... }:

{
  # zsh + oh-my-zsh, ported like-for-like from rc_files/zshrc. Nix packages
  # oh-my-zsh itself (`pkgs.oh-my-zsh`), so the git-clone installer that used
  # to run inside bootstrap.zsh (and the whole --unattended/RUNZSH story
  # fixed on the bootstrap.zsh side) simply doesn't exist in this path
  # anymore -- there's nothing imperative left to hang.
  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "docker" "z" ];
    };

    # zsh-syntax-highlighting / zsh-autosuggestions used to be `brew
    # install`ed with a conditional `>> zshrc` append bolted on in
    # bootstrap.zsh to source them. Native home-manager options replace both
    # the install step and the manual sourcing in one place.
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    # Runs before oh-my-zsh.sh loads -- the correct point for the plain
    # shell variables oh-my-zsh itself reads on startup (matches where they
    # sat, above `source $ZSH/oh-my-zsh.sh`, in the original rc_files/zshrc).
    initExtraBeforeCompInit = ''
      export UPDATE_ZSH_DAYS=13
      CASE_SENSITIVE="true"
      HIST_STAMPS="dd/mm/yyyy"
    '';

    # rc_files/aliases, /functions and /exports are kept as plain shell
    # files rather than hand-translated into Nix attrsets -- some of it
    # (the `ls` colorflag detection, the HTTP-method alias loop, etc.) is
    # real conditional shell logic, not simple `alias x=y` pairs, so a
    # faithful port means home-manager places the *same* files and sources
    # them, exactly like bootstrap.zsh's old `custom_list` loop did, just
    # via a Nix-managed symlink instead of a hand-rolled one.
    initExtra = ''
      for f in ~/.aliases ~/.functions ~/.exports; do
        source "$f"
      done

      test -e "''${HOME}/.iterm2_shell_integration.zsh" && source "''${HOME}/.iterm2_shell_integration.zsh"

      # kubectl completion -- guarded. kubectl may be missing entirely, or
      # (on a Mac migrated from Intel) be a stale x86_64 binary that cannot
      # exec without Rosetta. `command -v` passes in that second case, so
      # actually run it once and only source if it succeeded.
      _kubectl_completion="$(kubectl completion zsh 2>/dev/null)" \
        && source <(printf '%s\n' "$_kubectl_completion")
      unset _kubectl_completion

      # OpenClaw completion -- guarded, not present on every machine
      test -e "''${HOME}/.openclaw/completions/openclaw.zsh" \
        && source "''${HOME}/.openclaw/completions/openclaw.zsh"

      # LM Studio CLI (lms) -- guarded, not present on every machine
      test -d "''${HOME}/.lmstudio/bin" && export PATH="$PATH:''${HOME}/.lmstudio/bin"
    '';
  };

  home.file.".aliases".source = ../rc_files/aliases;
  home.file.".functions".source = ../rc_files/functions;
  home.file.".exports".source = ../rc_files/exports;
}
