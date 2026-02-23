-- ~/.config/awesome/volume-osd.lua
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local volume_osd = {}

local osd_width  = 180
local osd_height = 50

local progressbar = wibox.widget {
    max_value        = 100,
    value            = 50,
    forced_height    = 4,
    forced_width     = 140,
    color            = "#89b4fa",
    background_color = "#45475a",
    shape            = gears.shape.rounded_bar,
    bar_shape        = gears.shape.rounded_bar,
    widget           = wibox.widget.progressbar,
}

local label = wibox.widget {
    id     = "text_role",
    widget = wibox.widget.textbox,
    align  = "center",
    font   = "sans 10",
}

local widget = wibox.widget {
    {
        {
            label,
            {
                progressbar,
                halign = "center",
                widget = wibox.container.place,
            },
            spacing = 6,
            layout  = wibox.layout.fixed.vertical,
        },
        margins = 10,
        widget  = wibox.container.margin,
    },
    bg     = "#1e1e2eee",
    shape  = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 12) end,
    widget = wibox.container.background,
}

local function update_volume()
    awful.spawn.easy_async_with_shell(
        "wpctl get-volume @DEFAULT_AUDIO_SINK@",
        function(stdout)
            local vol_raw = stdout:match("Volume: ([%d%.]+)")
            local muted   = stdout:match("%[MUTED%]")
            local vol     = math.floor(tonumber(vol_raw or 0) * 100)

            if muted then
                label:get_children_by_id("text_role")[1].text = "Mute"
                progressbar.color = "#f38ba8"
            else
                label:get_children_by_id("text_role")[1].text = "Vol  " .. vol .. "%"
                progressbar.color = "#89b4fa"
            end

            progressbar.value = vol
        end
    )
end

local timer = gears.timer { timeout = 2 }
local osd_wibox = wibox {
    ontop   = true,
    visible = false,
    width   = osd_width,
    height  = osd_height,
    bg      = "#00000000",
}

function volume_osd.show()
    local s = awful.screen.focused()
    osd_wibox.screen = s
    osd_wibox.x = (s.geometry.width - osd_width) / 2
    osd_wibox.y = s.geometry.height * 0.08
    osd_wibox.widget = widget

    update_volume()
    osd_wibox.visible = true
    timer:stop()
    timer:connect_signal("timeout", function()
        osd_wibox.visible = false
        timer:stop()
    end)
    timer:start()
end

return volume_osd
