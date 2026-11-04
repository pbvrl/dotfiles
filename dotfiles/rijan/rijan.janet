## WARNING: This is a vibe-coded fork.
# 
# A fork of https://codeberg.org/ifreund/rijan, a window manager for river 0.5.
#
# Changes from upstream, each marked below with a "fork:" comment:
#   - Scratchpads: floating, centered windows toggled by a key. Each is a tag
#     named after its app-id, and showing one hides the others.
#   - Tag rules: init.janet can set the tag a window opens on by its app-id.
#   - Floating windows stay above tiled ones.
#   - init.janet is loaded at build time, so a mistake in it fails the Nix build.
#   - Commands run with sh -c, and startup commands only with --autostart.
#   - Focus follows the cursor into a window.
#   - Keyboard repeat.
#   - The cursor theme is "default".
#
# Removed, as this setup doesn't use them: most actions, pointer bindings, the
# REPL and a few window events.

(import protocols)
(import wayland)
# fork: unused without the REPL, but the build needs every native module imported
(import spork/netrepl)
(import xkbcommon)

(def interfaces
  (wayland/scan
    :wayland-xml protocols/wayland-xml
    :system-protocols-dir protocols/wayland-protocols
    :system-protocols ["stable/viewporter/viewporter.xml"
                       "staging/single-pixel-buffer/single-pixel-buffer-v1.xml"]
    :custom-protocols (map |(string protocols/river-protocols $)
                           ["/river-window-management-v1.xml"
                            "/river-layer-shell-v1.xml"
                            "/river-xkb-bindings-v1.xml"
                            # fork: for keyboard repeat
                            "/river-input-management-v1.xml"])))

(def required-interfaces
  @{"wl_compositor" 4
    "wp_viewporter" 1
    "wp_single_pixel_buffer_manager_v1" 1
    "river_window_manager_v1" 4
    "river_layer_shell_v1" 1
    "river_xkb_bindings_v1" 1
    # fork: for keyboard repeat
    "river_input_manager_v1" 1})

# fork: filled in by init.janet
(def config @{:xkb-bindings @[]})

(def wm @{:config config
          :outputs @[]
          :seats @[]
          :windows @[]
          # Windows in rendering order rather than window management order.
          # The last window in the array is rendered on top.
          :render-order @[]})

(def registry @{})

(defn rgb-to-u32-rgba [rgb]
  [(* (band 0xff (brushift rgb 16)) (/ 0xffff_ffff 0xff))
   (* (band 0xff (brushift rgb 8)) (/ 0xffff_ffff 0xff))
   (* (band 0xff rgb) (/ 0xffff_ffff 0xff))
   0xffff_ffff])

(defn bg/manage [bg output]
  (:sync-next-commit (bg :shell-surface))
  (:place-bottom (bg :node))
  (:set-position (bg :node) (output :x) (output :y))
  (def buffer (:create-u32-rgba-buffer
                (registry "wp_single_pixel_buffer_manager_v1")
                ;(rgb-to-u32-rgba ((wm :config) :background))))
  (:attach (bg :surface) buffer 0 0)
  (:damage-buffer (bg :surface) 0 0 0x7fff_ffff 0x7fff_ffff)
  (:set-destination (bg :viewport) (output :w) (output :h))
  (:commit (bg :surface))
  (:destroy buffer))

(defn bg/destroy [bg]
  (:destroy (bg :viewport))
  (:destroy (bg :shell-surface))
  (:destroy (bg :surface))
  (:destroy (bg :node)))

(defn bg/create []
  (def surface (:create-surface (registry "wl_compositor")))
  (def input-region (:create-region (registry "wl_compositor")))
  (:set-input-region surface input-region)
  (:destroy input-region)
  (def viewport (:get-viewport (registry "wp_viewporter") surface))
  (def shell-surface (:get-shell-surface (registry "river_window_manager_v1") surface))
  @{:surface surface
    :viewport viewport
    :shell-surface shell-surface
    :node (:get-node shell-surface)})

(defn output/visible [output windows]
  (let [tags (output :tags)]
    (filter |(tags ($ :tag)) windows)))

(defn output/usable-area [output]
  (if-let [[x y w h] (output :non-exclusive-area)]
    {:x x :y y :w w :h h}
    {:x (output :x) :y (output :y) :w (output :w) :h (output :h)}))

(defn output/manage-start [output]
  (if (output :removed)
    (do
      (:destroy (output :obj))
      (bg/destroy (output :bg)))
    output))

(defn output/manage [output]
  (bg/manage (output :bg) output)
  (when (output :new)
    (let [unused (find (fn [tag] (not (find |(($ :tags) tag) (wm :outputs)))) (range 1 10))]
      (put (output :tags) unused true))))

(defn output/manage-finish [output]
  (put output :new nil))

(defn output/create [obj]
  (def output @{:obj obj
                :bg (bg/create)
                :layer-shell (:get-output (registry "river_layer_shell_v1") obj)
                :new true
                :tags @{}})
  (defn output/handle-event [event]
    (match event
      [:removed] (put output :removed true)
      [:position x y] (do (put output :x x) (put output :y y))
      [:dimensions w h] (do (put output :w w) (put output :h h))))
  (defn output/handle-layer-shell-event [event]
    (match event
      [:non-exclusive-area x y w h] (put output :non-exclusive-area [x y w h])))
  (:set-user-data obj output)
  (:set-handler obj output/handle-event)
  (:set-handler (output :layer-shell) output/handle-layer-shell-event)
  output)

(defn window/set-position
  "Set position, adjusting for border width"
  [window x y]
  (let [border-width ((wm :config) :border-width)
        x (+ x border-width)
        y (+ y border-width)]
    (put window :x x)
    (put window :y y)
    (:set-position (window :node) x y)))

(defn window/propose-dimensions
  "Propose dimensions, adjusting for border width"
  [window w h]
  (def border-width ((wm :config) :border-width))
  (:propose-dimensions (window :obj)
                       (max 1 (- w (* 2 border-width)))
                       (max 1 (- h (* 2 border-width)))))

(defn window/set-float [window float]
  (if float
    (:set-tiled (window :obj) {})
    (:set-tiled (window :obj) {:left true :bottom :true :top :true :right true}))
  (put window :float float))

(defn window/set-fullscreen [window fullscreen-output]
  (if-let [output fullscreen-output]
    (do
      (put window :fullscreen true)
      (:inform-fullscreen (window :obj))
      (:fullscreen (window :obj) (output :obj)))
    (do
      (put window :fullscreen false)
      (:inform-not-fullscreen (window :obj))
      (:exit-fullscreen (window :obj)))))

(defn window/tag-output [window]
  (find |(($ :tags) (window :tag)) (wm :outputs)))

(defn window/max-overlap-output [window]
  (var max-overlap 0)
  (var max-overlap-output nil)
  (each output (wm :outputs)
    (def overlap-w (- (min (+ (window :x) (window :w))
                           (+ (output :x) (output :w)))
                      (max (window :x) (output :x))))
    (def overlap-h (- (min (+ (window :y) (window :h))
                           (+ (output :y) (output :h)))
                      (max (window :y) (output :y))))
    (when (and (> overlap-w 0) (> overlap-h 0))
      (def overlap (* overlap-w overlap-h))
      (when (> overlap max-overlap)
        (set max-overlap overlap)
        (set max-overlap-output output))))
  max-overlap-output)

(defn window/update-tag [window]
  (when-let [output (window/max-overlap-output window)]
    (unless (= output (window/tag-output window))
      (put window :tag (or (min-of (keys (output :tags))) 1)))))

(defn window/create [obj]
  (def window @{:obj obj
                :node (:get-node obj)
                :new true
                :tag 1})
  (defn window/handle-event [event]
    (match event
      [:closed] (put window :closed true)
      [:dimensions w h] (do (put window :w w) (put window :h h))
      [:app-id app-id] (put window :app-id app-id)
      [:parent parent] (put window :parent (if parent (:get-user-data parent)))
      [:pointer-move-requested seat] (put window :pointer-move-requested
                                          {:seat (:get-user-data seat)})
      [:pointer-resize-requested seat edges] (put window :pointer-resize-requested
                                                  {:seat (:get-user-data seat)
                                                   :edges edges})
      [:fullscreen-requested output] (put window :fullscreen-requested
                                          [:enter (if output (:get-user-data output))])
      [:exit-fullscreen-requested] (put window :fullscreen-requested [:exit])))
  (:set-handler obj window/handle-event)
  (:set-user-data obj window)
  # fork: windows opening on a hidden tag aren't focused, which would add them
  (array/insert (wm :render-order) 0 window)
  window)

(defn xkb-binding/create [seat keysym mods action]
  (def binding @{:obj (:get-xkb-binding (registry "river_xkb_bindings_v1")
                                        (seat :obj) (xkbcommon/keysym keysym) mods)})
  (defn handle-event [event]
    (match event
      [:pressed] (put seat :pending-action [binding action])))
  (:set-handler (binding :obj) handle-event)
  (:enable (binding :obj))
  (array/push (seat :xkb-bindings) binding))

(defn seat/focus-output [seat output]
  (unless (= output (seat :focused-output))
    (put seat :focused-output output)
    (when output (:set-default (output :layer-shell)))))

(defn seat/focus [seat window]
  (defn focus-window [window]
    (unless (= (seat :focused) window)
      (:focus-window (seat :obj) (window :obj))
      (put seat :focused window)
      (if-let [i (find-index |(= $ window) (wm :render-order))]
        (array/remove (wm :render-order) i))
      (array/push (wm :render-order) window)
      (:place-top (window :node))))
  (defn clear-focus []
    (when (seat :focused)
      (:clear-focus (seat :obj))
      (put seat :focused nil)))
  (defn focus-non-layer []
    (when window
      (when-let [output (window/tag-output window)]
        (seat/focus-output seat output)))
    (when-let [output (seat :focused-output)]
      (defn visible? [w] (and w ((output :tags) (w :tag))))
      (def visible (output/visible output (wm :render-order)))
      (cond
        # The top fullscreen window always grabs focus when present.
        (def fullscreen (last (filter |($ :fullscreen) visible)))
        (focus-window fullscreen)
        # If there is a visible explict target window, focus it.
        (visible? window) (focus-window window)
        # Otherwise, don't change focus if the current focus is visible.
        (visible? (seat :focused)) (do)
        # When no visible window is focused, focus the top one, if any.
        (def top-visible (last visible)) (focus-window top-visible)
        # When no windows are visible, clear focus.
        (clear-focus))))
  (case (seat :layer-focus)
    :exclusive (put seat :focused nil)
    :non-exclusive (if window
                     (do
                       (put seat :layer-focus :none)
                       (focus-non-layer))
                     (put seat :focused nil))
    :none (focus-non-layer)))

(defn seat/pointer-move [seat window]
  (unless (seat :op)
    (seat/focus seat window)
    (window/set-float window true)
    (:op-start-pointer (seat :obj))
    (put seat :op @{:type :move
                    :window window
                    :start-x (window :x) :start-y (window :y)
                    :dx 0 :dy 0})))

(defn seat/pointer-resize [seat window edges]
  (unless (seat :op)
    (seat/focus seat window)
    (window/set-float window true)
    (:op-start-pointer (seat :obj))
    (put seat :op @{:type :resize
                    :window window
                    :edges edges
                    :start-x (window :x) :start-y (window :y)
                    :start-w (window :w) :start-h (window :h)
                    :dx 0 :dy 0})))

(defn window/manage-start [window]
  (if (window :closed)
    (do
      (:destroy (window :obj))
      (:destroy (window :node)))
    window))

(defn window/manage [window]
  (when (window :new)
    (:use-ssd (window :obj))
    # fork: for all new windows rather than only children. Those ruled onto a
    # hidden tag aren't laid out, and need this to map. Layout or a rule can
    # still propose a size later in this sequence.
    (:propose-dimensions (window :obj) 0 0)
    (if-let [parent (window :parent)]
      (do
        (window/set-float window true)
        (put window :tag (parent :tag)))
      (do
        (window/set-float window false)
        (when-let [seat (first (wm :seats))
                   output (seat :focused-output)]
          (put window :tag (or (min-of (keys (output :tags))) 1))))))
  # fork: tag rules and scratchpads. A scratchpad is a tag named after its app-id,
  # so upstream's handling of tags shows and hides it. The app-id may arrive with
  # the window or later.
  (when (and (window :app-id) (not (window :parent)) (not (window :ruled)))
    (put window :ruled true)
    # Upstream's window/render expects only children to lack a position, but this
    # window may be on a hidden tag. Layout moves it if not.
    (window/set-position window 0 0)
    (when-let [tag ((config :tags) (window :app-id))]
      (put window :tag tag))
    (when-let [scratchpad ((config :scratchpads) (window :app-id))]
      (put window :tag (window :app-id))
      (window/set-float window true)
      (window/propose-dimensions window ;(scratchpad :size))))
  (match (window :fullscreen-requested)
    [:enter] (if-let [seat (first (wm :seats))
                      output (seat :focused-output)]
               (window/set-fullscreen window output))
    [:enter output] (window/set-fullscreen window output)
    [:exit] (window/set-fullscreen window nil))
  (when-let [move (window :pointer-move-requested)]
    (seat/pointer-move (move :seat) window))
  (when-let [resize (window :pointer-resize-requested)]
    (seat/pointer-resize (resize :seat) window (resize :edges))))

(defn window/manage-finish [window]
  (put window :new nil)
  (put window :pointer-move-requested nil)
  (put window :pointer-resize-requested nil)
  (put window :fullscreen-requested nil))

(defn- set-borders [window status config]
  (def rgb (case status
             :normal (config :border-normal)
             :focused (config :border-focused)))
  (:set-borders (window :obj)
                {:left true :bottom :true :top :true :right true}
                (config :border-width)
                ;(rgb-to-u32-rgba rgb)))

(defn window/render [window]
  (when (and (not (window :x)) (window :w))
    # Windows that start with a parent have nil x/y until rijan receives
    # a dimensions event and a render sequence is completed.
    (if-let [output (window/max-overlap-output (window :parent))]
      (window/set-position window
                           (+ (output :x) (div (- (output :w) (window :w)) 2))
                           (+ (output :y) (div (- (output :h) (window :h)) 2)))
      (window/set-position window 0 0)))
  (if (find |(= ($ :focused) window) (wm :seats))
    (set-borders window :focused (wm :config))
    (set-borders window :normal (wm :config))))

(defn seat/manage-start [seat]
  (if (seat :removed)
    (:destroy (seat :obj))
    seat))

(defn seat/manage [seat]
  (when (seat :new)
    (each binding (config :xkb-bindings)
      (xkb-binding/create seat ;binding)))
  (when-let [window (seat :focused)]
    (when (window :closed)
      (put seat :focused nil)))
  # fork: for focus following the cursor
  (when-let [window (seat :pointer-target)]
    (when (window :closed)
      (put seat :pointer-target nil)))
  (when-let [op (seat :op)]
    (when ((op :window) :closed)
      (put seat :op nil)))
  (if (or (not (seat :focused-output))
          ((seat :focused-output) :removed))
    (seat/focus-output seat (first (wm :outputs))))

  (seat/focus seat nil)
  # fork: focus follows the cursor into a window, but only when it moved: windows
  # shifting under a still cursor shouldn't take focus.
  (when (and (seat :pointer-entered) (seat :pointer-moved) (not (seat :op)))
    (seat/focus seat (seat :pointer-target)))
  (each window (wm :windows)
    (when (window :new)
      (seat/focus seat window)))
  (if-let [window (seat :window-interaction)]
    (seat/focus seat window))

  (when-let [[binding action] (seat :pending-action)]
    (action seat binding))

  # Ensure focus is consistent after action (e.g. may have switched tags)
  (seat/focus seat nil)

  (when-let [op (seat :op)]
    (when (= :resize (op :type))
      # Resize from bottom right corner
      (window/propose-dimensions (op :window)
                                 (max 1 (+ (op :start-w) (op :dx)))
                                 (max 1 (+ (op :start-h) (op :dy))))))
  (when (and (seat :op-release) (seat :op))
    (:op-end (seat :obj))
    (window/update-tag ((seat :op) :window))
    # TODO why do I need this focus-output call here??
    (seat/focus-output seat (window/tag-output ((seat :op) :window)))
    (put seat :op nil)))

(defn seat/manage-finish [seat]
  (put seat :new nil)
  (put seat :window-interaction nil)
  (put seat :pending-action nil)
  (put seat :op-release nil)
  # fork: for focus following the cursor
  (put seat :pointer-entered nil)
  (put seat :pointer-moved nil))

(defn seat/render [seat]
  (when-let [op (seat :op)]
    (when (= :move (op :type))
      (window/set-position (op :window)
                           (+ (op :start-x) (op :dx))
                           (+ (op :start-y) (op :dy))))))

(defn seat/create [obj]
  (def seat @{:obj obj
              :layer-shell (:get-seat (registry "river_layer_shell_v1") obj)
              :layer-focus :none
              :xkb-bindings @[]
              :new true})
  (defn seat/handle-event [event]
    (match event
      [:removed] (put seat :removed true)
      # fork: :pointer-entered and :pointer-position, for focus following the cursor
      [:pointer-enter window] (do
                                (put seat :pointer-target (:get-user-data window))
                                (put seat :pointer-entered true))
      [:pointer-leave] (put seat :pointer-target nil)
      [:pointer-position x y] (put seat :pointer-moved true)
      [:window-interaction window] (put seat :window-interaction (:get-user-data window))
      [:op-delta dx dy] (do (put (seat :op) :dx dx) (put (seat :op) :dy dy))
      [:op-release] (put seat :op-release true)))
  (defn seat/handle-layer-shell-event [event]
    (match event
      [:focus-exclusive] (put seat :layer-focus :exclusive)
      [:focus-non-exclusive] (put seat :layer-focus :non-exclusive)
      [:focus-none] (put seat :layer-focus :none)))
  (:set-handler obj seat/handle-event)
  (:set-handler (seat :layer-shell) seat/handle-layer-shell-event)
  (:set-user-data obj seat)
  # fork: no cursor theme is installed, so this is river-classic's fallback
  (:set-xcursor-theme obj "default" 24)
  seat)

# fork: keyboard repeat
(defn input-device/create [obj]
  (defn handle-event [event]
    (match event
      [:type :keyboard] (:set-repeat-info obj ;((wm :config) :repeat))
      [:removed] (:destroy obj)))
  (:set-handler obj handle-event))

(defn input/handle-event [event]
  (match event
    [:input-device obj] (input-device/create obj)))

(defn wm/show-hide []
  (def all-tags @{})
  (each output (wm :outputs)
    (merge-into all-tags (output :tags))
    # Ensure the output on which windows are fullscreen is updated
    # if they become visible on a different output.
    (each window (wm :windows)
      (when (and (window :fullscreen)
                 ((output :tags) (window :tag)))
        (:fullscreen (window :obj) (output :obj)))))
  (each window (wm :windows)
    (if (all-tags (window :tag))
      (:show (window :obj))
      (:hide (window :obj)))))

(defn wm/layout [output]
  (def windows (filter |(not ($ :float)) (output/visible output (wm :windows))))
  (def side-count (- (length windows) 1))
  (def usable (output/usable-area output))
  (def total-w (max 0 (- (usable :w) (* 2 ((wm :config) :outer-padding)))))
  (def total-h (max 0 (- (usable :h) (* 2 ((wm :config) :outer-padding)))))
  (def main-w (if (= 0 side-count) total-w (math/round (* total-w ((wm :config) :main-ratio)))))
  (def side-w (- total-w main-w))
  (def side-h (div total-h side-count))
  (def side-h-rem (% total-h side-count))
  (->> (range (length windows))
       (map (fn [i]
              (case i
                0 [0 0 main-w total-h]
                1 [main-w 0 side-w (+ side-h side-h-rem)]
                [main-w (+ side-h-rem (* side-h (- i 1)))
                 side-w side-h])))
       (map (fn [[x y w h]]
              (def outer ((wm :config) :outer-padding))
              (def inner ((wm :config) :inner-padding))
              [(+ x outer inner) (+ y outer inner)
               (- w (* 2 inner)) (- h (* 2 inner))]))
       (map (fn [[x y w h]]
              [(+ x (usable :x)) (+ y (usable :y)) w h]))
       (map (fn [window box]
              (window/set-position window ;(slice box 0 2))
              (window/propose-dimensions window ;(slice box 2 4)))
            windows)))

# fork: scratchpads stay centered in the output's usable area
(defn wm/center-scratchpads [output]
  (def area (output/usable-area output))
  (each window (output/visible output (wm :windows))
    (when (and ((config :scratchpads) (window :tag)) (window :w))
      (window/set-position window
                           (+ (area :x) (div (- (area :w) (window :w)) 2))
                           (+ (area :y) (div (- (area :h) (window :h)) 2))))))

(defn wm/manage []
  (update wm :render-order |(->> $ (filter (fn [window] (not (window :closed))))))

  (update wm :outputs |(keep output/manage-start $))
  (update wm :windows |(keep window/manage-start $))
  (update wm :seats |(keep seat/manage-start $))

  (map output/manage (wm :outputs))
  (map window/manage (wm :windows))
  (map seat/manage (wm :seats))

  # fork: floating windows stay above tiled ones, which don't overlap each other
  (each window (wm :render-order)
    (when (window :float) (:place-top (window :node))))

  (map wm/layout (wm :outputs))
  (wm/show-hide)

  (map output/manage-finish (wm :outputs))
  (map window/manage-finish (wm :windows))
  (map seat/manage-finish (wm :seats))

  (:manage-finish (registry "river_window_manager_v1")))

(defn wm/render []
  (map window/render (wm :windows))
  # fork: here because dimensions arrive just before a render sequence
  (map wm/center-scratchpads (wm :outputs))
  (map seat/render (wm :seats))
  (:render-finish (registry "river_window_manager_v1")))

(defn wm/handle-event [event]
  (match event
    [:unavailable] (do
                     (print "another window manager is already running")
                     (os/exit 1))
    [:finished] (os/exit 0)
    [:manage-start] (wm/manage)
    [:render-start] (wm/render)
    [:output obj] (array/push (wm :outputs) (output/create obj))
    [:seat obj] (array/push (wm :seats) (seat/create obj))
    [:window obj] (array/insert (wm :windows) 0 (window/create obj))))

(defn registry/handle-event [event]
  (def obj (registry :obj))
  (match event
    [:global name interface version]
    (when-let [required-version (get required-interfaces interface)]
      (when (< version required-version)
        (errorf "wayland compositor supported %s version too old (need %d, got %d)"
                interface required-version version))
      (put registry interface (:bind (registry :obj) name interface required-version)))))

(defn action/spawn [command]
  (fn [seat binding]
    (ev/spawn
      (os/proc-wait (os/spawn command :p)))))

# fork: run commands the way riverctl spawn does
(defn sh [command]
  (action/spawn ["sh" "-c" command]))

(defn action/close []
  (fn [seat binding]
    (if-let [window (seat :focused)]
      (:close (window :obj)))))

(defn action/set-tag [tag]
  (fn [seat binding]
    (if-let [window (seat :focused)]
      (put window :tag tag))))

(defn fallback-tags [outputs]
  (for tag 1 10
    (unless (find |(($ :tags) tag) outputs)
      # fork: an output showing only a scratchpad needs a numbered tag too
      (when-let [output (find |(empty? (filter number? (keys ($ :tags)))) outputs)]
        (put (output :tags) tag true)))))

(defn action/focus-tag [tag]
  (fn [seat binding]
    (when-let [output (seat :focused-output)]
      (map |(put ($ :tags) tag nil) (wm :outputs))
      (put output :tags @{tag true})
      (fallback-tags (wm :outputs)))))

# fork: like upstream's action/toggle-tag, but also hides the output's other
# scratchpads, and calls spawn if the scratchpad isn't open.
(defn action/scratchpad [app-id spawn]
  (fn [seat binding]
    (when-let [output (seat :focused-output)]
      (def shown ((output :tags) app-id))
      (map |(put ($ :tags) app-id nil) (wm :outputs))
      (eachk other (config :scratchpads)
        (put (output :tags) other nil))
      (unless shown
        (put (output :tags) app-id true)
        (if-let [window (find |(= app-id ($ :tag)) (wm :windows))]
          (seat/focus seat window)
          (spawn seat binding))))))

(defn action/exit-session []
  (fn [seat binding]
    (:exit-session (registry "river_window_manager_v1"))))

(defn main [& args]
  (def display (wayland/connect interfaces))

  # Avoid passing WAYLAND_DEBUG on to our children.
  # It only matters if it's set when the display is created.
  (os/setenv "WAYLAND_DEBUG" nil)

  (put registry :obj (:get-registry display))
  (:set-handler (registry :obj) registry/handle-event)
  (:roundtrip display)
  (eachk i required-interfaces
    (unless (get registry i)
      (errorf "wayland compositor does not support %s" i)))

  (:set-handler (registry "river_window_manager_v1") wm/handle-event)
  # fork: for keyboard repeat
  (:set-handler (registry "river_input_manager_v1") input/handle-event)

  # fork: do a roundtrip to give the compositor the chance to send the
  # :unavailable event, so we exit before autostarting anything if another
  # window manager is running.
  (:roundtrip display)

  # fork: ../rijan.nix passes --autostart only on the first start of a session
  (when (index-of "--autostart" args)
    (each command (config :autostart)
      ((sh command) nil nil)))

  (forever (:dispatch display)))

# fork: upstream loads init.janet when it starts. Loading it here, at build time,
# means a mistake in it fails the Nix build instead of breaking the session.
(dofile "init.janet" :env (curenv))

# fork: each scratchpad gets its key, and starts at login
(eachp [app-id {:key [key mods] :command command}] (config :scratchpads)
  (array/push (config :xkb-bindings) [key mods (action/scratchpad app-id (sh command))])
  (array/push (config :autostart) command))

# fork: otherwise a mistyped key would only fail at login
(each [key] (config :xkb-bindings)
  (xkbcommon/keysym key))
