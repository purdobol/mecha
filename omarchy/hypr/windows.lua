-- Personal Hyprland window rules
--
-- Migrated from the old ~/.config/hypr/hyprland.conf
--
-- See:
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- ============================================================
-- Emacs minibuffer
-- ============================================================

o.window(
  {
    class = "Emacs",
    title = ".*mini-frame.*",
  },
  {
    float = true,
  }
)

-- ============================================================
-- Zathura PDF viewer
-- ============================================================

o.window(
  "Zathura",
  {
    float = true,
    size = "1200 900",
    center = true,
  }
)

-- ============================================================
-- Omni windows
-- ============================================================

o.window(
  {
    title = "^omni-local$",
  },
  {
    float = true,
    center = true,
  }
)

o.window(
  {
    title = "^omni-web$",
  },
  {
    float = true,
    center = true,
  }
)

o.window(
  {
    title = "^omni-multi$",
  },
  {
    float = true,
    center = true,
  }
)

o.window(
  {
    title = "^omni-deep$",
  },
  {
    float = true,
    center = true,
  }
)

o.window(
  {
    title = "^(omni)$",
  },
  {
    float = true,
    center = true,
  }
)

-- ============================================================
-- Godot
-- Disable Omarchy transparency / frosted glass
-- ============================================================

o.window(
  "Godot",
  {
    opacity = "1.0 1.0",
    no_blur = true,
  }
)

-- ============================================================
-- Zen Browser
-- Normal Zen windows -> workspace 1
-- ============================================================

o.window(
  {
    class = "^zen$",
    title = "^Zen Browser$",
  },
  {
    workspace = "1",
  }
)
