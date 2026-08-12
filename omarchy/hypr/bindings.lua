-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
--


-- Application bindings

-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.
--
-- See current bindings and descriptions:
--   omarchy menu keybindings --print


-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.
--
-- See current bindings and descriptions:
--   omarchy menu keybindings --print


-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.
--
-- See current bindings and descriptions:
--   omarchy menu keybindings --print


-- ============================================================
-- Application bindings
-- ============================================================

hl.unbind("SUPER + SHIFT + ALT + E")
o.bind(
  "SUPER + SHIFT + ALT + E",
  "Emacs",
  "~/.config/hypr/scripts/emacs-open-or-focus.sh"
)

hl.unbind("SUPER + SHIFT + ALT + C")
o.bind(
  "SUPER + SHIFT + ALT + C",
  "Org Capture",
  "~/.config/hypr/scripts/emacs-launcher '(my/org-capture-grouped-wl)'"
)

hl.unbind("SUPER + SHIFT + ALT + R")
o.bind(
  "SUPER + SHIFT + ALT + R",
  "Consult Omni Local",
  "emacsclient -n -e '(my/omni-local)'"
)

hl.unbind("SUPER + SHIFT + ALT + W")
o.bind(
  "SUPER + SHIFT + ALT + W",
  "Elfeed",
  "~/.config/hypr/scripts/emacs-launcher '(elfeed)'"
)

hl.unbind("SUPER + SHIFT + ALT + RETURN")
o.bind(
  "SUPER + SHIFT + ALT + RETURN",
  "Terminal",
  'uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)"'
)

hl.unbind("SUPER + ALT + SHIFT + F")
o.bind(
  "SUPER + SHIFT + ALT + F",
  "Dirvish",
  "~/.config/hypr/scripts/emacs-launcher '(dirvish)'"
)

hl.unbind("SUPER + SHIFT + CTRL + ALT + F")
o.bind(
  "SUPER + SHIFT + CTRL + ALT + F",
  "File manager",
  "uwsm-app -- nautilus --new-window"
)

hl.unbind("SUPER + SHIFT + ALT + B")
o.bind(
  "SUPER + SHIFT + ALT + B",
  "Browser",
  "omarchy-launch-browser"
)

hl.unbind("SUPER + SHIFT + CTRL + ALT + B")
o.bind(
  "SUPER + SHIFT + CTRL + ALT + B",
  "Browser (private)",
  "~/.config/hypr/scripts/browser-private.sh"
)

hl.unbind("SUPER + SHIFT + ALT + M")
o.bind(
  "SUPER + SHIFT + ALT + M",
  "Music",
  "omarchy-launch-or-focus spotify"
)

hl.unbind("SUPER + SHIFT + ALT + N")
o.bind(
  "SUPER + SHIFT + ALT + N",
  "Editor",
  "omarchy-launch-editor"
)

hl.unbind("SUPER + SHIFT + ALT + D")
o.bind(
  "SUPER + SHIFT + ALT + D",
  "Docker",
  "omarchy-launch-tui lazydocker"
)

hl.unbind("SUPER + SHIFT + ALT + G")
o.bind(
  "SUPER + SHIFT + ALT + G",
  "Signal",
  'omarchy-launch-or-focus signal "uwsm-app -- signal-desktop"'
)

hl.unbind("SUPER + SHIFT + ALT + O")
o.bind(
  "SUPER + SHIFT + ALT + O",
  "Org Browser",
  "~/.config/hypr/scripts/emacs-launcher '(my-org-browser-show)'"
)

hl.unbind("SUPER + SHIFT + ALT + SLASH")
o.bind(
  "SUPER + SHIFT + ALT + SLASH",
  "Passwords",
  "uwsm-app -- 1password"
)

hl.unbind("SUPER + SHIFT + ALT + V")
o.bind(
  "SUPER + SHIFT + ALT + V",
  nil,
  "~/.config/hypr/scripts/record-toggle"
)


-- ============================================================
-- Web apps
-- ============================================================

hl.unbind("SUPER + SHIFT + ALT + A")
o.bind(
  "SUPER + SHIFT + ALT + A",
  "ChatGPT",
  "omarchy-launch-webapp https://chatgpt.com"
)

hl.unbind("SUPER + SHIFT + CTRL + ALT + A")
o.bind(
  "SUPER + SHIFT + CTRL + ALT + A",
  "Grok",
  "omarchy-launch-webapp https://grok.com"
)

hl.unbind("SUPER + SHIFT + ALT + Y")
o.bind(
  "SUPER + SHIFT + ALT + Y",
  "YouTube",
  "omarchy-launch-webapp https://youtube.com/"
)

hl.unbind("SUPER + SHIFT + ALT + G")
o.bind(
  "SUPER + SHIFT + ALT + G",
  "WhatsApp",
  "omarchy-launch-or-focus-webapp WhatsApp https://web.whatsapp.com/"
)

hl.unbind("SUPER + SHIFT + CTRL + ALT + G")
o.bind(
  "SUPER + SHIFT + CTRL + ALT + G",
  "Google Messages",
  "omarchy-launch-or-focus-webapp 'Google Messages' https://messages.google.com/web/conversations"
)

hl.unbind("SUPER + SHIFT + ALT + P")
o.bind(
  "SUPER + SHIFT + ALT + P",
  "Google Photos",
  "omarchy-launch-or-focus-webapp 'Google Photos' https://photos.google.com/"
)

hl.unbind("SUPER + SHIFT + ALT + X")
o.bind(
  "SUPER + SHIFT + ALT + X",
  "X",
  "omarchy-launch-webapp https://x.com/"
)

hl.unbind("SUPER + SHIFT + CTRL + ALT + X")
o.bind(
  "SUPER + SHIFT + CTRL + ALT + X",
  "X Post",
  "omarchy-launch-webapp https://x.com/compose/post"
)

hl.unbind("SUPER + SHIFT + ALT + S")
o.bind(
  "SUPER + SHIFT + ALT + S",
  "Search Engine",
  "~/.local/bin/web-search"
)


-- ============================================================
-- Window management
-- ============================================================

hl.unbind("SUPER + SHIFT + ALT + Q")
o.bind(
  "SUPER + SHIFT + ALT + Q",
  "Close window",
  hl.dsp.window.close()
)

hl.unbind("CTRL + ALT + DELETE")
o.bind(
  "CTRL + ALT + DELETE",
  "Close all windows",
  "omarchy-hyprland-window-close-all"
)

hl.unbind("SUPER + P")
o.bind(
  "SUPER + P",
  "Pseudo window",
  hl.dsp.window.pseudo()
)

hl.unbind("SUPER + T")
o.bind(
  "SUPER + T",
  "Toggle window floating/tiling",
  hl.dsp.window.float({ action = "toggle" })
)

hl.unbind("SUPER + F")
o.bind(
  "SUPER + F",
  "Full screen",
  hl.dsp.window.fullscreen({ mode = "fullscreen" })
)

hl.unbind("SUPER + CTRL + F")
o.bind(
  "SUPER + CTRL + F",
  "Tiled full screen",
  "omarchy-hyprland-window-tiled-fullscreen-toggle"
)

hl.unbind("SUPER + ALT + F")
o.bind(
  "SUPER + ALT + F",
  "Full width",
  hl.dsp.window.fullscreen({ mode = "maximized" })
)

hl.unbind("SUPER + O")
o.bind(
  "SUPER + O",
  "Pop window out (float & pin)",
  "omarchy-hyprland-window-pop"
)


-- ============================================================
-- Move focus
-- ============================================================

hl.unbind("SUPER + LEFT")
o.bind(
  "SUPER + LEFT",
  "Move window focus left",
  hl.dsp.focus({ direction = "l" })
)

hl.unbind("SUPER + RIGHT")
o.bind(
  "SUPER + RIGHT",
  "Move window focus right",
  hl.dsp.focus({ direction = "r" })
)

hl.unbind("SUPER + UP")
o.bind(
  "SUPER + UP",
  "Move window focus up",
  hl.dsp.focus({ direction = "u" })
)

hl.unbind("SUPER + DOWN")
o.bind(
  "SUPER + DOWN",
  "Move window focus down",
  hl.dsp.focus({ direction = "d" })
)


-- ============================================================
-- Workspace switching
--
-- Keep Omarchy's normal SUPER + 1..0 behavior.
--
-- Add the old custom:
--   SUPER + SHIFT + ALT + 1..0
-- ============================================================

for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)

  hl.unbind("SUPER + SHIFT + ALT + " .. key)

  o.bind(
    "SUPER + SHIFT + ALT + " .. key,
    "Switch to workspace " .. workspace,
    hl.dsp.focus({ workspace = tostring(workspace) })
  )
end


-- ============================================================
-- Move active window silently to workspace
--
-- SUPER + SHIFT + CTRL + ALT + 1..0
-- ============================================================

for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)

  hl.unbind("SUPER + SHIFT + CTRL + ALT + " .. key)

  o.bind(
    "SUPER + SHIFT + CTRL + ALT + " .. key,
    "Move window silently to workspace " .. workspace,
    hl.dsp.window.move({
      workspace = tostring(workspace),
      follow = false
    })
  )
end


-- ============================================================
-- Scratchpad
-- ============================================================

-- hl.unbind("SUPER + S")
-- o.bind(
--   "SUPER + S",
--   "Toggle scratchpad",
--   hl.dsp.workspace.toggle_special("scratchpad")
-- )

-- hl.unbind("SUPER + ALT + S")
-- o.bind(
--   "SUPER + ALT + S",
--   "Move window to scratchpad",
--   hl.dsp.window.move({
--     workspace = "special:scratchpad",
--     follow = false
--   })
-- )


-- ============================================================
-- Workspace navigation
-- ============================================================

-- hl.unbind("SUPER + TAB")
-- o.bind(
--   "SUPER + TAB",
--   "Next workspace",
--   hl.dsp.focus({ workspace = "e+1" })
-- )

-- hl.unbind("SUPER + SHIFT + TAB")
-- o.bind(
--   "SUPER + SHIFT + TAB",
--   "Previous workspace",
--   hl.dsp.focus({ workspace = "e-1" })
-- )

-- hl.unbind("SUPER + CTRL + TAB")
-- o.bind(
--   "SUPER + CTRL + TAB",
--   "Former workspace",
--   hl.dsp.focus({ workspace = "previous" })
-- )


-- ============================================================
-- Move workspaces between monitors
-- ============================================================

-- hl.unbind("SUPER + SHIFT + ALT + LEFT")
-- o.bind(
--   "SUPER + SHIFT + ALT + LEFT",
--   "Move workspace to left monitor",
--   hl.dsp.workspace.move({ monitor = "l" })
-- )

-- hl.unbind("SUPER + SHIFT + ALT + RIGHT")
-- o.bind(
--   "SUPER + SHIFT + ALT + RIGHT",
--   "Move workspace to right monitor",
--   hl.dsp.workspace.move({ monitor = "r" })
-- )

-- hl.unbind("SUPER + SHIFT + ALT + UP")
-- o.bind(
--   "SUPER + SHIFT + ALT + UP",
--   "Move workspace to up monitor",
--   hl.dsp.workspace.move({ monitor = "u" })
-- )

-- hl.unbind("SUPER + SHIFT + ALT + DOWN")
-- o.bind(
--   "SUPER + SHIFT + ALT + DOWN",
--   "Move workspace to down monitor",
--   hl.dsp.workspace.move({ monitor = "d" })
-- )


-- ============================================================
-- Swap windows
-- ============================================================

-- hl.unbind("SUPER + SHIFT + LEFT")
-- o.bind(
--   "SUPER + SHIFT + LEFT",
--   "Swap window to the left",
--   hl.dsp.window.swap({ direction = "l" })
-- )

-- hl.unbind("SUPER + SHIFT + RIGHT")
-- o.bind(
--   "SUPER + SHIFT + RIGHT",
--   "Swap window to the right",
--   hl.dsp.window.swap({ direction = "r" })
-- )

-- hl.unbind("SUPER + SHIFT + UP")
-- o.bind(
--   "SUPER + SHIFT + UP",
--   "Swap window up",
--   hl.dsp.window.swap({ direction = "u" })
-- )

-- hl.unbind("SUPER + SHIFT + DOWN")
-- o.bind(
--   "SUPER + SHIFT + DOWN",
--   "Swap window down",
--   hl.dsp.window.swap({ direction = "d" })
-- )


-- ============================================================
-- Window cycling
-- ============================================================

-- hl.unbind("ALT + TAB")
-- o.bind(
--   "ALT + TAB",
--   "Focus on next window",
--   hl.dsp.window.cycle_next()
-- )

-- hl.unbind("ALT + SHIFT + TAB")
-- o.bind(
--   "ALT + SHIFT + TAB",
--   "Focus on previous window",
--   hl.dsp.window.cycle_next({ next = false })
-- )


-- ============================================================
-- Resize active window
-- ============================================================

-- hl.unbind("SUPER + code:20")
-- o.bind(
--   "SUPER + code:20",
--   "Expand window left",
--   hl.dsp.window.resize({ x = -100, y = 0, relative = true })
-- )

-- hl.unbind("SUPER + code:21")
-- o.bind(
--   "SUPER + code:21",
--   "Shrink window left",
--   hl.dsp.window.resize({ x = 100, y = 0, relative = true })
-- )

-- hl.unbind("SUPER + SHIFT + code:20")
-- o.bind(
--   "SUPER + SHIFT + code:20",
--   "Shrink window up",
--   hl.dsp.window.resize({ x = 0, y = -100, relative = true })
-- )

-- hl.unbind("SUPER + SHIFT + code:21")
-- o.bind(
--   "SUPER + SHIFT + code:21",
--   "Expand window down",
--   hl.dsp.window.resize({ x = 0, y = 100, relative = true })
-- )


-- ============================================================
-- Scroll through workspaces
-- ============================================================

-- hl.unbind("SUPER + mouse_down")
-- o.bind(
--   "SUPER + mouse_down",
--   "Scroll active workspace forward",
--   hl.dsp.focus({ workspace = "e+1" })
-- )

-- hl.unbind("SUPER + mouse_up")
-- o.bind(
--   "SUPER + mouse_up",
--   "Scroll active workspace backward",
--   hl.dsp.focus({ workspace = "e-1" })
-- )


-- ============================================================
-- Move / resize windows with mouse
-- ============================================================

-- hl.unbind("SUPER + mouse:272")
-- o.bind(
--   "SUPER + mouse:272",
--   "Move window",
--   hl.dsp.window.drag(),
--   { mouse = true }
-- )

-- hl.unbind("SUPER + mouse:273")
-- o.bind(
--   "SUPER + mouse:273",
--   "Resize window",
--   hl.dsp.window.resize(),
--   { mouse = true }
-- )


-- ============================================================
-- Groups
-- ============================================================

-- hl.unbind("SUPER + G")
-- o.bind(
--   "SUPER + G",
--   "Toggle window grouping",
--   hl.dsp.group.toggle()
-- )

-- hl.unbind("SUPER + ALT + G")
-- o.bind(
--   "SUPER + ALT + G",
--   "Move active window out of group",
--   hl.dsp.window.move({ out_of_group = true })
-- )

-- hl.unbind("SUPER + ALT + LEFT")
-- o.bind(
--   "SUPER + ALT + LEFT",
--   "Move window to group on left",
--   hl.dsp.window.move({ into_group = "l" })
-- )

-- hl.unbind("SUPER + ALT + RIGHT")
-- o.bind(
--   "SUPER + ALT + RIGHT",
--   "Move window to group on right",
--   hl.dsp.window.move({ into_group = "r" })
-- )

-- hl.unbind("SUPER + ALT + UP")
-- o.bind(
--   "SUPER + ALT + UP",
--   "Move window to group on top",
--   hl.dsp.window.move({ into_group = "u" })
-- )

-- hl.unbind("SUPER + ALT + DOWN")
-- o.bind(
--   "SUPER + ALT + DOWN",
--   "Move window to group on bottom",
--   hl.dsp.window.move({ into_group = "d" })
-- )

-- hl.unbind("SUPER + ALT + TAB")
-- o.bind(
--   "SUPER + ALT + TAB",
--   "Next window in group",
--   hl.dsp.group.next()
-- )

-- hl.unbind("SUPER + ALT + SHIFT + TAB")
-- o.bind(
--   "SUPER + ALT + SHIFT + TAB",
--   "Previous window in group",
--   hl.dsp.group.prev()
-- )
