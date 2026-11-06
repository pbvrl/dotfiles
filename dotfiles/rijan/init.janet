(def super {:mod4 true})
(def super-shift {:mod4 true :shift true})
(def alt {:mod1 true})
(def large [1870 1150])

(merge-into
  config
  {:background 0x002b36
   :border-width 0
   :border-normal 0x646464
   :border-focused 0xffffff
   :outer-padding 0
   :inner-padding 0
   :main-ratio 0.5
   :repeat [75 250]
   :autostart @["fcitx5"
                "quickshell"
                "fnott"
                "gammastep -O 3800"
                "handy --start-hidden"
                "$HOME/.config/nixos/scripts/quickshell__keybindhelper.qml"
                `ghostty --class=tmux.term --gtk-tabs-location=hidden --initial-command="sesh connect $(zoxide query ~/projects/*/master)"`
                "firefox"
                `ghostty --class=notes.term --gtk-tabs-location=hidden --initial-command="cd $HOME/notes/ && hx Systems.md"`]
   :tags {"tmux.term" 1 "firefox" 2 "notes.term" 3}
   :scratchpads
   {"wifi.term"
    {:key [:q super] :size [700 700]
     :command `ghostty --class=wifi.term --gtk-tabs-location=hidden --initial-command='nmtui connect; exec bash'`}
    "audio.term"
    {:key [:w super] :size [700 500]
     :command `ghostty --class=audio.term --gtk-tabs-location=hidden --initial-command='wiremix --tab output --tabs output input configuration; exec bash'`}
    "brightness.term"
    {:key [:e super] :size [700 200]
     :command `ghostty --class=brightness.term --gtk-tabs-location=hidden --initial-command="$HOME/.config/nixos/scripts/brightnessctl.sh; exec bash"`}
    "private.term"
    {:key [:h alt] :size large
     :command `wezterm --config initial_cols=184 --config initial_rows=49 start --class private.term --workspace private -- bash -c '$HOME/.config/nixos/private/scripts/scratchpad.sh; exec bash'`}
    "localai.term"
    {:key [:i alt] :size large
     :command `WEZTERM_TITLEBAR=light wezterm --config initial_cols=184 --config initial_rows=49 start --class localai.term --workspace localai -- bash -c 'cd ~/.config/nixos; claude --resume; exec bash'`}
    # opencode attach http://vps:4096
    "remoteai.term"
    {:key [:u alt] :size large
     :command `wezterm --config initial_cols=184 --config initial_rows=49 start --class remoteai.term --workspace remoteai -- bash -c 'opencode; exec bash'`}
    # "ghdash.term"
    # {:key [:s alt] :size large
    #  :command `ghostty --class=ghdash.term --title=ghdash --gtk-tabs-location=hidden --window-decoration=auto --initial-command='gh-dash; exec bash'`}
    "news.term"
    {:key [:d alt] :size large
     :command `ghostty --class=news.term --title=news --gtk-tabs-location=hidden --window-decoration=auto --initial-command=newsraft`}}})

(array/push
  (config :xkb-bindings)
  [:p super (sh "fuzzel")]
  [:c alt (sh "grim - | wl-copy")]
  [:a alt (sh "$HOME/.config/nixos/scripts_as_dotfiles/fnott/dismiss_oldest_notification.sh")]
  [:space alt (sh "handy --toggle-transcription")]
  [:h super (sh "qs ipc -p $HOME/.config/nixos/scripts/quickshell__keybindhelper.qml call KeybindHelperHandler toggle")]
  [:q super-shift (action/close)]
  [:e super-shift (action/exit-session)])

(for i 1 10
  (def keysym (keyword i))
  (array/push
    (config :xkb-bindings)
    [keysym super (action/focus-tag i)]
    [keysym super-shift (action/set-tag i)]))
