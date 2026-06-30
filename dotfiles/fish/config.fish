set -Ux EDITOR hx # Environment variable
set -g fish_key_bindings fish_vi_key_bindings
set fish_greeting # Disable greeting

# Cursor settings
set fish_cursor_default block blink
set fish_cursor_insert line blink
set fish_cursor_replace_one underscore blink
set fish_cursor_replace underscore
set fish_cursor_external line
set fish_cursor_visual block

# Disable mode prompt
function fish_mode_prompt
end

# Add blank space after outputs
function postexec --on-event fish_postexec
    echo
    echo
end

# Aliases
alias y="yazi"
alias fix-wl='set -gx WAYLAND_DISPLAY (ls -t /run/user/(id -u)/wayland-* | head -n 1 | xargs basename)'

if status is-interactive
    atuin init fish | sed 's/-k up/up/' | source
end

function fish_prompt
    ## Last command status
    set -l last_status $status

    # Nix shell status
    set -l nix_shell_info ""
    if test -n "$IN_NIX_SHELL"
        set nix_shell_info "(nix-shell) "
    end

    ## Git branch status
    set -l git_branch (git rev-parse --abbrev-ref HEAD 2>/dev/null)
    set -l git_info ""
    if test -n "$git_branch"
        set git_info "($git_branch) "
    end

    ##
    set_color 5277C3
    echo -n -s "$nix_shell_info"
    set_color F05032
    echo -n "$git_info"
    set_color a8a8a8
    echo -n (prompt_pwd)
    echo -n " > "
end
