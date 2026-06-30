{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g @extrakto_key 'none'
      run-shell ${pkgs.tmuxPlugins.extrakto}/share/tmux-plugins/extrakto/extrakto.tmux
      bind -n M-escape run-shell "${pkgs.tmuxPlugins.extrakto}/share/tmux-plugins/extrakto/scripts/open.sh '#{pane_id}'"
    '';
  };
}
