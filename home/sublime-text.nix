{ pkgs, lib, ... }:

let
  # Same logic as the python3 heredoc bootstrap.zsh used to embed inline:
  # merge update_check=false into Preferences.sublime-settings rather than
  # overwriting it, since it may already hold unrelated user settings. Kept
  # as its own store-path script (instead of a bash heredoc) so indentation
  # inside the Nix file doesn't fight with heredoc delimiter matching.
  setUpdateCheckFalse = pkgs.writeText "sublime-set-update-check-false.py" ''
    import json
    import sys

    path = sys.argv[1]
    try:
        with open(path) as f:
            data = json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        data = {}
    data["update_check"] = False
    with open(path, "w") as f:
        json.dump(data, f, indent=4)
        f.write("\n")
  '';
in
{
  # Sublime Text itself is not installed by this flake -- see
  # darwin/homebrew.nix's comment and README's Assumptions: it has to be
  # installed manually (it needs its own paid license; see
  # specs/001-declarative-machine-setup for the ST3/ST4/Rosetta discussion).
  # Everything *around* it that bootstrap.zsh used to set up is ported here
  # like-for-like.

  home.file."Library/Application Support/Sublime Text 3/Packages/User/minimap_settings.py".source =
    ../patches/minimap_settings.py;

  home.activation.sublimeTextShimAndPrefs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    subl_src="/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl"
    subl_bin_dir="/opt/homebrew/bin"

    if [ -f "$subl_src" ] && [ ! -e "$subl_bin_dir/subl" ]; then
      run ln -sv "$subl_src" "$subl_bin_dir/subl"
    fi

    # ST3 hasn't shipped a release since 2020 and will never get an arm64
    # build (see specs/001-declarative-machine-setup/spec.md), so its
    # built-in update checker permanently nags that ST4 is available. Merge
    # update_check=false in rather than overwriting the file, since it may
    # already hold unrelated user settings -- identical logic to the
    # bootstrap.zsh version, just re-run on every activation (idempotent:
    # setting the same key to the same value twice is a no-op).
    subl_prefs_dir="$HOME/Library/Application Support/Sublime Text 3/Packages/User"
    if [ -d "$subl_prefs_dir" ]; then
      run ${pkgs.python3}/bin/python3 ${setUpdateCheckFalse} "$subl_prefs_dir/Preferences.sublime-settings"
    fi
  '';
}
