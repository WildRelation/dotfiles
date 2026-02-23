
local themes_path = os.getenv("HOME") .. "/.config/awesome/themes/default/"
local gears = require("gears")
local theme = {}

theme.font          = "sans 10"

-- Catppuccin Mocha
theme.bg_normal     = "#1e1e2ecc"  -- base con transparencia
theme.bg_focus      = "#313244"    -- surface0
theme.bg_urgent     = "#f38ba8"    -- red
theme.bg_minimize   = "#00000000"
theme.fg_normal     = "#6c7086"    -- overlay0
theme.fg_focus      = "#cdd6f4"    -- text
theme.fg_urgent     = "#1e1e2e"
theme.fg_minimize   = "#45475a"    -- surface1

-- Layouts con iconos blancos (el 'w' al final es de white)
theme.layout_tile       = "/usr/share/awesome/themes/default/layouts/tilew.png"
theme.layout_tileleft   = "/usr/share/awesome/themes/default/layouts/tileleftw.png"
theme.layout_tilebottom = "/usr/share/awesome/themes/default/layouts/tilebottomw.png"
theme.layout_tiletop    = "/usr/share/awesome/themes/default/layouts/tiletopw.png"
theme.layout_floating   = "/usr/share/awesome/themes/default/layouts/floatingw.png"
theme.layout_fairh      = "/usr/share/awesome/themes/default/layouts/fairhw.png"
theme.layout_fairv      = "/usr/share/awesome/themes/default/layouts/fairvw.png"
theme.layout_magnifier  = "/usr/share/awesome/themes/default/layouts/magnifierw.png"
theme.layout_max        = "/usr/share/awesome/themes/default/layouts/maxw.png"
theme.layout_fullscreen = "/usr/share/awesome/themes/default/layouts/fullscreenw.png"
theme.layout_spiral     = "/usr/share/awesome/themes/default/layouts/spiralw.png"
theme.layout_dwindle    = "/usr/share/awesome/themes/default/layouts/dwindlew.png"
theme.layout_cornernw   = "/usr/share/awesome/themes/default/layouts/cornernww.png"
theme.layout_cornerne   = "/usr/share/awesome/themes/default/layouts/cornernew.png"
theme.layout_cornersw   = "/usr/share/awesome/themes/default/layouts/cornersww.png"
theme.layout_cornerse   = "/usr/share/awesome/themes/default/layouts/cornersew.png"


theme.tasklist_bg_focus    = "#313244"
theme.tasklist_fg_focus    = "#cdd6f4"
theme.tasklist_shape_focus = gears.shape.rounded_bar

-- Bordes Catppuccin
theme.border_width  = 2
theme.border_normal = "#313244"    -- surface0
theme.border_focus  = "#89b4fa"    -- blue
theme.border_marked = "#f38ba8"    -- red

theme.useless_gap   = 8
theme.wallpaper = themes_path .. "background.jpg"

theme.menu_height = 20
theme.menu_width  = 150
theme.menu_border_width = 0
theme.menu_border_color = "#00000000"
theme.menu_bg_normal = "#1e1e2eee"
theme.menu_bg_focus  = "#313244"
theme.menu_fg_normal = "#6c7086"
theme.menu_fg_focus  = "#cdd6f4"

theme.awesome_icon = "/usr/share/awesome/icons/awesome16.png"
return theme
