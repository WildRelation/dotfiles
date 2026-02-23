-- If LuaRocks is installed, make sure that packages installed through it are

-- found (e.g. lgi). If LuaRocks is not installed, do nothing.

pcall(require, "luarocks.loader")


-- Standard awesome library

local gears = require("gears")

local awful = require("awful")

local lain = require("lain")

require("awful.autofocus")

local beautiful = require("beautiful") 

local naughty = require("naughty")   



-- Volume

local wibox     = require("wibox")


-- Volume OSD personalizado (MANTÉN ESTO)

local volume_osd = require("volume-osd")
local brightness_osd = require("brightness-osd")


-- Widget de red con velocidad
local mynet = lain.widget.net({
    settings = function()
        local connected = false
        for _, d in pairs(net_now.devices) do
            if d.state == "up" then connected = true; break end
        end
        if connected then
            local rx = string.format("%.0f", tonumber(net_now.received) or 0)
            local tx = string.format("%.0f", tonumber(net_now.sent) or 0)
            widget:set_markup(string.format(
                " <span color='#89b4fa'> %skb</span> <span color='#a6e3a1'> %skb</span> ",
                rx, tx
            ))
        else
            widget:set_markup(" <span color='#f38ba8'> Sin red</span> ")
        end
    end
})

-- Widget de CPU
local mycpu = lain.widget.cpu({
    timeout = 2,
    settings = function()
        widget:set_markup(string.format(
            " <span color='#89b4fa'>󰻠 %s%%</span> ",
            cpu_now.usage
        ))
    end
})

-- Widget de RAM
local mymem = lain.widget.mem({
    timeout = 2,
    settings = function()
        widget:set_markup(string.format(
            " <span color='#a6e3a1'> %sMB</span> ",
            mem_now.used
        ))
    end
})

-- Widget de batería
local mybattery = lain.widget.bat({
    timeout = 10,
    settings = function()
        -- Verificar que bat_now existe y tiene datos
        if not bat_now or not bat_now.perc then
            widget:set_markup("")
            return
        end
        
        local bat_p = tonumber(bat_now.perc)
        local bat_status = bat_now.status or "Unknown"
        
        -- Si no se puede convertir a número, no mostrar nada
        if not bat_p then
            widget:set_markup("")
            return
        end
        
        local bat_icon  = ""
        local bat_color = "#cdd6f4"

        if bat_status == "Charging" or bat_status == "Full" then
            bat_icon  = ""
            bat_color = "#a6e3a1"
        elseif bat_p <= 20 then
            bat_icon  = ""
            bat_color = "#f38ba8"
        elseif bat_p <= 50 then
            bat_icon  = ""
            bat_color = "#f9e2af"
        end

        widget:set_markup(string.format(
            " <span color='%s'>%s %s%%</span> ",
            bat_color, bat_icon, bat_p
        ))
    end
})

-- Widget de temperatura
local mytemp = lain.widget.temp({
    timeout = 5,
    settings = function()
        widget:set_markup(string.format(
            " <span color='#f9e2af'> %s°C</span> ",
            coretemp_now
        ))
    end
})

-- Notificación de batería baja
local bat_notif_sent = false
gears.timer {
    timeout   = 60,
    autostart = true,
    callback  = function()
        awful.spawn.easy_async("cat /sys/class/power_supply/BAT0/capacity", function(out)
            local perc = tonumber(out) or 100
            awful.spawn.easy_async("cat /sys/class/power_supply/BAT0/status", function(status)
                status = status:gsub("%s+", "")
                if perc <= 15 and status ~= "Charging" and not bat_notif_sent then
                    naughty.notify({
                        title   = "Batería baja",
                        text    = "Queda " .. perc .. "% — conecta el cargador",
                        timeout = 10,
                        preset  = naughty.config.presets.critical,
                    })
                    bat_notif_sent = true
                elseif perc > 15 then
                    bat_notif_sent = false
                end
            end)
        end)
    end
}

local idle_warning_widget = wibox.widget {
    text   = "",
    align  = "center",
    valign = "center",
    widget = wibox.widget.textbox
}


gears.timer {
    timeout   = 1,
    autostart = true,
    callback  = function()
        awful.spawn.easy_async("xprintidle", function(stdout)
            local idle = tonumber(stdout) or 0
            if idle > 50000 then  -- últimos 10s antes del script (60s)
                local remaining = math.max(0, 60 - math.floor(idle / 1000))
                idle_warning_widget.text = "⏳ Suspend en " .. remaining .. "s"
            else
                idle_warning_widget.text = ""
            end
        end)
    end
}


-- Notification library

local menubar = require("menubar")

local hotkeys_popup = require("awful.hotkeys_popup")

-- Enable hotkeys help widget for VIM and other apps

-- when client with a matching name is opened:

require("awful.hotkeys_popup.keys")


-- {{{ Error handling

-- Check if awesome encountered an error during startup and fell back to

-- another config (This code will only ever execute for the fallback config)


-- Handle runtime errors after startup

do

    local in_error = false

    awesome.connect_signal("debug::error", function (err)

        -- Make sure we don't go into an endless error loop

        if in_error then return end

        in_error = true


        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })

        in_error = false

    end)

end

-- }}}


-- {{{ Variable definitions

-- Themes define colours, icons, font and wallpapers.

beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/default/theme.lua")


-- This is used later as the default terminal and editor to run.

terminal = "kitty"

editor = os.getenv("EDITOR") or "nano"

editor_cmd = terminal .. " -e " .. editor


-- Default modkey.

-- Usually, Mod4 is the key with a logo between Control and Alt.

-- If you do not like this or do not have such a key,

-- I suggest you to remap Mod4 to another key using xmodmap or other tools.

-- However, you can use another modifier like Mod1, but it may interact with others.

modkey = "Mod4"


-- Table of layouts to cover with awful.layout.inc, order matters.

awful.layout.layouts = {

    awful.layout.suit.floating,

    awful.layout.suit.tile,

    awful.layout.suit.tile.left,

    awful.layout.suit.tile.bottom,

    awful.layout.suit.tile.top,

    awful.layout.suit.fair,

    awful.layout.suit.fair.horizontal,

    awful.layout.suit.spiral,

    awful.layout.suit.spiral.dwindle,

    awful.layout.suit.max,

    awful.layout.suit.max.fullscreen,

    awful.layout.suit.magnifier,

    awful.layout.suit.corner.nw,

    -- awful.layout.suit.corner.ne,

    -- awful.layout.suit.corner.sw,

    --awful.layout.suit.corner.se,

}

-- }}}


-- {{{ Menu

-- Create a launcher widget and a main menu

myawesomemenu = {

   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },

   { "manual", terminal .. " -e man awesome" },

   { "edit config", editor_cmd .. " " .. awesome.conffile },

   { "restart", awesome.restart },

   { "quit", function() awesome.quit() end },

}


mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },

                                    { "open terminal", terminal }

                                  }

                        })


mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,

                                     menu = mymainmenu })


-- Menubar configuration

menubar.utils.terminal = terminal -- Set the terminal for applications that require it

-- }}}


-- Keyboard map indicator and switcher

mykeyboardlayout = awful.widget.keyboardlayout()


-- {{{ Wibar

-- Create a textclock widget
mytextclock = wibox.widget.textclock(
    "<span color='#cba6f7'> </span><span color='#cdd6f4'>%H:%M</span>  <span color='#585b70'>%a %d %b</span>  "
)

-- Separador visual entre grupos
local function make_separator()
    return wibox.widget {
        markup = "<span color='#313244'>  │  </span>",
        widget = wibox.widget.textbox,
    }
end

-- Calendario interactivo (click en el reloj para abrir/cerrar)
local cal = awful.widget.calendar_popup.month({
    bg            = "#00000000",
    style_header  = { fg_color = "#cba6f7", bg_color = "#00000000", border_width = 0 },
    style_weekday = { fg_color = "#585b70",  bg_color = "#00000000", border_width = 0 },
    style_normal  = { fg_color = "#cdd6f4",  bg_color = "#00000000", border_width = 0 },
    style_focus   = { fg_color = "#1e1e2e",  bg_color = "#89b4fa",   border_width = 0 },
    style_month   = { fg_color = "#cdd6f4",  bg_color = "#00000000", border_width = 0 },
})
cal:attach(mytextclock, "tr")

-- Quake terminal (F12 para mostrar/ocultar)
local quaketerminal = lain.util.quake({
    app       = "kitty",
    name      = "QuakeKitty",
    argname   = "--name %s",
    height    = 0.4,
    width     = 1,
    vert      = "top",
    horiz     = "left",
    followtag = true,
})

-- Create a wibox for each screen and add it

local taglist_buttons = gears.table.join(

                    awful.button({ }, 1, function(t) t:view_only() end),

                    awful.button({ modkey }, 1, function(t)

                                              if client.focus then

                                                  client.focus:move_to_tag(t)

                                              end

                                          end),

                    awful.button({ }, 3, awful.tag.viewtoggle),

                    awful.button({ modkey }, 3, function(t)

                                              if client.focus then

                                                  client.focus:toggle_tag(t)

                                              end

                                          end),

                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),

                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)

                )


local tasklist_buttons = gears.table.join(

                     awful.button({ }, 1, function (c)

                                              if c == client.focus then

                                                  c.minimized = true

                                              else

                                                  c:emit_signal(

                                                      "request::activate",

                                                      "tasklist",

                                                      {raise = true}

                                                  )

                                              end

                                          end),

                     awful.button({ }, 3, function()

                                              awful.menu.client_list({ theme = { width = 250 } })

                                          end),

                     awful.button({ }, 4, function ()

                                              awful.client.focus.byidx(1)

                                          end),

                     awful.button({ }, 5, function ()

                                              awful.client.focus.byidx(-1)

                                          end))


-- Wallpaper automático por hora del día
local function set_wallpaper(s)
    awful.spawn.easy_async_with_shell(
        os.getenv("HOME") .. "/.local/bin/wallpaper-time.sh",
        function(stdout)
            local wallpaper = stdout:gsub("%s+$", "")
            if wallpaper ~= "" then
                gears.wallpaper.maximized(wallpaper, s, true)
            end
        end
    )
end

-- Re-set wallpaper cuando cambia la resolución
screen.connect_signal("property::geometry", set_wallpaper)

-- Revisar y actualizar el wallpaper cada hora
local wallpaper_timer = gears.timer({
    timeout   = 3600,
    autostart = true,
    callback  = function()
        for s in screen do
            set_wallpaper(s)
        end
    end
})


awful.screen.connect_for_each_screen(function(s)

    -- Wallpaper

    set_wallpaper(s)


    -- Each screen has its own tag table.

    local names = { " 1:term ", " 2:web ", " 3:code ", " 4:univ ", " 5:chat ", " 6:files ", " 7:media " }

    local l = awful.layout.suit 

    local layouts = { l.tile, l.tile, l.tile, l.tile, l.tile, l.tile, l.floating }

    awful.tag(names, s, layouts)


    -- Create a promptbox for each screen

    s.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.

    -- We need one layoutbox per screen.

    s.mylayoutbox = awful.widget.layoutbox(s)

    s.mylayoutbox:buttons(gears.table.join(

                           awful.button({ }, 1, function () awful.layout.inc( 1) end),

                           awful.button({ }, 3, function () awful.layout.inc(-1) end),

                           awful.button({ }, 4, function () awful.layout.inc( 1) end),

                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    -- Create a taglist widget

    s.mytaglist = awful.widget.taglist {

        screen  = s,

        filter  = awful.widget.taglist.filter.all,

        buttons = taglist_buttons

    }


    -- Create a tasklist widget

    s.mytasklist = awful.widget.tasklist {

        screen  = s,

        filter  = awful.widget.tasklist.filter.currenttags,

        buttons = tasklist_buttons

    }


-- 1. PRIMERO CREAMOS LA BARRA (Aquí es donde quitas el azul)

    -- Crea la barra con colores fijos para evitar el error 'nil'

    s.mywibox = awful.wibar({
        position = "top",
        screen   = s,
        height   = 28,
        bg       = beautiful.bg_normal,
        fg       = "#cdd6f4",
        shape    = function(cr, w, h)
            gears.shape.rounded_rect(cr, w, h, 0)
        end,
    })

-- Volume


    -- 2. LUEGO LE PONEMOS LOS WIDGETS

    s.mywibox:setup {

    layout = wibox.layout.align.horizontal,

    { -- Left widgets

        layout = wibox.layout.fixed.horizontal,  

        mylauncher,

        s.mytaglist,

        s.mypromptbox,

    },

    s.mytasklist, -- Middle widget

    { -- Right widgets
        layout = wibox.layout.fixed.horizontal,
        wibox.container.margin(mytemp.widget, 6, 2),
        wibox.container.margin(mycpu.widget, 2, 2),
        wibox.container.margin(mymem.widget, 2, 6),
        make_separator(),
        wibox.container.margin(mybattery.widget, 2, 2),
        wibox.container.margin(mynet.widget, 2, 6),
        make_separator(),
        wibox.widget.systray(),
        wibox.container.margin(idle_warning_widget, 4, 4),
        make_separator(),
        mytextclock,
        wibox.container.margin(s.mylayoutbox, 6, 6),
    },

    }



end)

-- }}}



--bling.signal.playerctl.enable()



-- {{{ Mouse bindings

root.buttons(gears.table.join(

    awful.button({ }, 3, function () mymainmenu:toggle() end),

    awful.button({ }, 4, awful.tag.viewnext),

    awful.button({ }, 5, awful.tag.viewprev)

))

-- }}}


-- {{{ Key bindings

globalkeys = gears.table.join(

    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,

              {description="show help", group="awesome"}),

    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,

              {description = "view previous", group = "tag"}),

    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,

              {description = "view next", group = "tag"}),

    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,

              {description = "go back", group = "tag"}),


    awful.key({ modkey,           }, "j",

        function ()

            awful.client.focus.byidx( 1)

        end,

        {description = "focus next by index", group = "client"}

    ),

    awful.key({ modkey,           }, "k",

        function ()

            awful.client.focus.byidx(-1)

        end,

        {description = "focus previous by index", group = "client"}

    ),

    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,

              {description = "show main menu", group = "awesome"}),


    -- Layout manipulation

    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,

              {description = "swap with next client by index", group = "client"}),

    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,

              {description = "swap with previous client by index", group = "client"}),

    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,

              {description = "focus the next screen", group = "screen"}),

    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,

              {description = "focus the previous screen", group = "screen"}),

    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,

              {description = "jump to urgent client", group = "client"}),

    awful.key({ modkey,           }, "Tab",

        function ()

            awful.client.focus.history.previous()

            if client.focus then

                client.focus:raise()

            end

        end,

        {description = "go back", group = "client"}),


   awful.key({ "Mod1" }, "Tab",
     function ()
        awful.menu.clients({ theme = { width = 250 } })
     end,
    {description = "Mostrar lista de ventanas (Alt-Tab)", group = "client"}),


-- Show applications

   awful.key({ modkey }, "d", function () awful.spawn("rofi -show drun -show-icons -theme ~/.config/rofi/catppuccin-mocha.rasi") end,

          {description = "mostrar aplicaciones", group = "launcher"}),

-- Screenshot

   awful.key({ modkey, "Shift" }, "s", function () awful.spawn("flameshot gui") end,

          {description = "Captura de pantalla", group = "screenshot"}),





    -- Standard program

    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,

              {description = "open a terminal", group = "launcher"}),

    awful.key({ modkey, "Control" }, "r", awesome.restart,

              {description = "reload awesome", group = "awesome"}),

    awful.key({ modkey, "Shift"   }, "q", awesome.quit,

              {description = "quit awesome", group = "awesome"}),


    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,

              {description = "increase master width factor", group = "layout"}),

    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,

              {description = "decrease master width factor", group = "layout"}),

    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,

              {description = "increase the number of master clients", group = "layout"}),

    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,

              {description = "decrease the number of master clients", group = "layout"}),

    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,

              {description = "increase the number of columns", group = "layout"}),

    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,

              {description = "decrease the number of columns", group = "layout"}),

    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,

              {description = "select next", group = "layout"}),

    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,

              {description = "select previous", group = "layout"}),


-- Subir Volumen (Fn + F3)
awful.key({ }, "XF86AudioRaiseVolume", function ()
    awful.spawn.easy_async("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+", function()
        volume_osd.show()
    end)
end, {description = "Subir volumen", group = "Sonido"}),

-- Bajar Volumen (Fn + F2)
awful.key({ }, "XF86AudioLowerVolume", function ()
    awful.spawn.easy_async("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-", function()
        volume_osd.show()
    end)
end, {description = "Bajar volumen", group = "Sonido"}),

-- Silenciar (Fn + F1)
awful.key({ }, "XF86AudioMute", function ()
    awful.spawn.easy_async("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", function()
        volume_osd.show()
    end)
end, {description = "Silenciar", group = "Sonido"}),

-- Controles de música
awful.key({ }, "XF86AudioPlay",  function() awful.spawn("playerctl play-pause") end,
    {description = "Play/Pause", group = "Música"}),
awful.key({ }, "XF86AudioNext",  function() awful.spawn("playerctl next") end,
    {description = "Siguiente", group = "Música"}),
awful.key({ }, "XF86AudioPrev",  function() awful.spawn("playerctl previous") end,
    {description = "Anterior", group = "Música"}),

-- Portapapeles (Super+V)
awful.key({ modkey }, "v", function()
    awful.spawn("rofi -modi 'clipboard:greenclip print' -show clipboard -theme ~/.config/rofi/catppuccin-mocha.rasi")
end, {description = "portapapeles", group = "launcher"}),

-- Menú de apagado (Super+Shift+E)
awful.key({ modkey, "Shift" }, "e", function()
    local options = "Apagar\nReiniciar\nSuspender\nCerrar sesión"
    awful.spawn.easy_async_with_shell(
        "echo -e '" .. options .. "' | rofi -dmenu -p ' Sistema' -theme ~/.config/rofi/catppuccin-mocha.rasi",
        function(choice)
            choice = choice:gsub("%s+", "")
            if     choice == "Apagar"        then awful.spawn("systemctl poweroff")
            elseif choice == "Reiniciar"     then awful.spawn("systemctl reboot")
            elseif choice == "Suspender"     then awful.spawn("systemctl suspend")
            elseif choice == "Cerrarsesión"  then awesome.quit()
            end
        end
    )
end, {description = "menú de apagado", group = "Sistema"}),


awful.key({ }, "XF86MonBrightnessUp",
    function ()
        awful.spawn.easy_async("brightnessctl set +10%", function()
            brightness_osd.show()
        end)
    end,
    {description = "Subir brillo", group = "Pantalla"}
),

awful.key({ }, "XF86MonBrightnessDown",
    function ()
        awful.spawn.easy_async("brightnessctl set 10%-", function()
            brightness_osd.show()
        end)
    end,
    {description = "Bajar brillo", group = "Pantalla"}
),


-- Lock Screen (Super + L)
awful.key({ modkey }, "l", function ()
    awful.spawn("betterlockscreen -l")
end, {description = "Bloquear pantalla", group = "Sistema"}),


awful.key({ modkey, "Shift" }, "p",
    function ()
        awful.spawn("systemctl suspend")
    end,
    {description = "Suspender sistema", group = "Sistema"}
),



-- Restaurar ventanas

awful.key({ modkey, "Control" }, "n",

    function ()

        local c = awful.client.restore()

        if c then

            c:emit_signal("request::activate", "key.unminimize", {raise = true})

        end

    end, {description = "restore minimized", group = "client"}),


-- Prompt

awful.key({ modkey }, "r", function () awful.screen.focused().mypromptbox:run() end,

          {description = "run prompt", group = "launcher"}),


awful.key({ modkey }, "x",

          function ()

              awful.prompt.run {

                prompt       = "Run Lua code: ",

                textbox      = awful.screen.focused().mypromptbox.widget,

                exe_callback = awful.util.eval,

                history_path = awful.util.get_cache_dir() .. "/history_eval"

              }

          end,

          {description = "lua execute prompt", group = "awesome"}),

-- Menubar

awful.key({ modkey }, "p", function() menubar.show() end,

          {description = "show the menubar", group = "launcher"}),

-- Quake terminal
awful.key({ }, "F12", function() quaketerminal:toggle() end,
          {description = "quake terminal", group = "launcher"})

) -- ESTE CIERRA EL gears.table.join(globalkeys, ...)




clientkeys = gears.table.join(

    awful.key({ modkey,           }, "f",

        function (c)

            c.fullscreen = not c.fullscreen

            c:raise()

        end,

        {description = "toggle fullscreen", group = "client"}),

    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,

              {description = "close", group = "client"}),

    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,

              {description = "toggle floating", group = "client"}),

    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,

              {description = "move to master", group = "client"}),

    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,

              {description = "move to screen", group = "client"}),

    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,

              {description = "toggle keep on top", group = "client"}),

    awful.key({ modkey,           }, "n",

        function (c)

            -- The client currently has the input focus, so it cannot be

            -- minimized, since minimized clients can't have the focus.

            c.minimized = true

        end ,

        {description = "minimize", group = "client"}),

    awful.key({ modkey,           }, "m",

        function (c)

            c.maximized = not c.maximized

            c:raise()

        end ,

        {description = "(un)maximize", group = "client"}),

    awful.key({ modkey, "Control" }, "m",

        function (c)

            c.maximized_vertical = not c.maximized_vertical

            c:raise()

        end ,

        {description = "(un)maximize vertically", group = "client"}),

    awful.key({ modkey, "Shift"   }, "m",

        function (c)

            c.maximized_horizontal = not c.maximized_horizontal

            c:raise()

        end ,

        {description = "(un)maximize horizontally", group = "client"})

)


-- Bind all key numbers to tags.

-- Be careful: we use keycodes to make it work on any keyboard layout.

-- This should map on the top row of your keyboard, usually 1 to 9.

for i = 1, 7 do

    globalkeys = gears.table.join(globalkeys,

        -- View tag only.

        awful.key({ modkey }, "#" .. i + 9,

                  function ()

                        local screen = awful.screen.focused()

                        local tag = screen.tags[i]

                        if tag then

                           tag:view_only()

                        end

                  end,

                  {description = "view tag #"..i, group = "tag"}),

        -- Toggle tag display.

        awful.key({ modkey, "Control" }, "#" .. i + 9,

                  function ()

                      local screen = awful.screen.focused()

                      local tag = screen.tags[i]

                      if tag then

                         awful.tag.viewtoggle(tag)

                      end

                  end,

                  {description = "toggle tag #" .. i, group = "tag"}),

        -- Move client to tag.

        awful.key({ modkey, "Shift" }, "#" .. i + 9,

                  function ()

                      if client.focus then

                          local tag = client.focus.screen.tags[i]

                          if tag then

                              client.focus:move_to_tag(tag)

                          end

                     end

                  end,

                  {description = "move focused client to tag #"..i, group = "tag"}),

        -- Toggle tag on focused client.

        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,

                  function ()

                      if client.focus then

                          local tag = client.focus.screen.tags[i]

                          if tag then

                              client.focus:toggle_tag(tag)

                          end

                      end

                  end,

                  {description = "toggle focused client on tag #" .. i, group = "tag"})

    )

end



clientbuttons = gears.table.join(

    awful.button({ }, 1, function (c)

        c:emit_signal("request::activate", "mouse_click", {raise = true})

    end),

    awful.button({ modkey }, 1, function (c)

        c:emit_signal("request::activate", "mouse_click", {raise = true})

        awful.mouse.client.move(c)

    end),

    awful.button({ modkey }, 3, function (c)

        c:emit_signal("request::activate", "mouse_click", {raise = true})

        awful.mouse.client.resize(c)

    end)

)


-- Set keys

root.keys(globalkeys)

-- }}}





-- Configuración global de notificaciones (Naughty) - Catppuccin Mocha
naughty.config.defaults.ontop        = true
naughty.config.defaults.timeout      = 5
naughty.config.defaults.margin       = 12
naughty.config.defaults.border_width = 2
naughty.config.defaults.position     = "top_right"
naughty.config.defaults.bg           = "#1e1e2eee"
naughty.config.defaults.fg           = "#cdd6f4"
naughty.config.defaults.border_color = "#89b4fa"

naughty.config.presets.low.bg           = "#1e1e2eee"
naughty.config.presets.low.fg           = "#cdd6f4"
naughty.config.presets.low.border_color = "#a6e3a1"

naughty.config.presets.critical.bg           = "#1e1e2eee"
naughty.config.presets.critical.fg           = "#f38ba8"
naughty.config.presets.critical.border_color = "#f38ba8"


-- Ajustar tamaño máximo de los iconos y la notificación

naughty.config.defaults.icon_size = 64

naughty.config.presets.low.width = 300

naughty.config.presets.normal.width = 300

naughty.config.presets.critical.width = 300




-- {{{ Rules

-- Rules to apply to new clients (through the "manage" signal).

awful.rules.rules = {

    -- All clients will match this rule.

    { rule = { },

      properties = { border_width = beautiful.border_width,

                     border_color = beautiful.border_normal,

                     focus = awful.client.focus.filter,

                     raise = true,

                     keys = clientkeys,

                     buttons = clientbuttons,

                     screen = awful.screen.preferred,

                     placement = awful.placement.no_overlap+awful.placement.no_offscreen

     }

    },


    -- Floating clients.

    { rule_any = {

        instance = {

          "DTA",  -- Firefox addon DownThemAll.

          "copyq",  -- Includes session name in class.

          "pinentry",

        },

        class = {

          "Arandr",

          "Blueman-manager",

          "Gpick",

          "Kruler",

          "MessageWin",  -- kalarm.

          "Sxiv",

          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.

          "Wpa_gui",

          "veromix",

          "xtightvncviewer"},


        -- Note that the name property shown in xprop might be set slightly after creation of the client

        -- and the name shown there might not match defined rules here.

        name = {

          "Event Tester",  -- xev.

        },

        role = {

          "AlarmWindow",  -- Thunderbird's calendar.

          "ConfigManager",  -- Thunderbird's about:config.

          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.

        }

      }, properties = { floating = true }},

-- 3. ASIGNACIÓN POR ESCRITORIO (Workflows)
    
    -- Web (Tag 2)
    { rule = { class = "Firefox" },
      properties = { screen = 1, tag = " 2:web " } },

    -- Desarrollo (Tag 3)
   { rule = { class = "jetbrains-idea" },
      properties = { screen = 1, tag = " 3:code " } },






-- Regla mejorada para la universidad
{ rule_any = { 
    class = { 
        "Zathura", 
        "libreoffice", 
        "libreoffice-writer", 
        "libreoffice-calc", 
        "libreoffice-impress", 
        "LibreOffice",
        "Soffice", -- A veces la clase interna es esta
    },
    instance = {
        "libreoffice",
        "soffice",
    }
  }, 
  properties = { screen = 1, tag = " 4:univ " } 
},

{ rule = { class = "obsidian" },
  properties = { screen = 1, tag = " 4:univ " }
},

    -- Chat (Tag 5)
    { rule = { class = "discord" },
      properties = { screen = 1, tag = " 5:chat " } },

    -- Multimedia (Tag 7)
    { rule = { class = "Spotify" },
      properties = { screen = 1, tag = " 7:media " } },


-- 2. Notificaciones (esto evitará que Discord se confunda)

{ rule = { type = "notification" },

  properties = { 

      floating = true, 

      ontop = true, 

      focusable = false,

      placement = awful.placement.top_right

  } 

},



    -- Add titlebars to normal clients and dialogs

    { rule_any = {type = { "normal", "dialog" }

      }, properties = { titlebars_enabled = false }

    },


}

-- }}}


-- {{{ Signals

-- Signal function to execute when a new client appears.

client.connect_signal("manage", function (c)

    -- Set the windows at the slave,

    -- i.e. put it at the end of others instead of setting it master.

    -- if not awesome.startup then awful.client.setslave(c) end


    if awesome.startup

      and not c.size_hints.user_position

      and not c.size_hints.program_position then

        -- Prevent clients from being unreachable after screen count changes.

        awful.placement.no_offscreen(c)

    end

end)


-- Add a titlebar if titlebars_enabled is set to true in the rules.

client.connect_signal("request::titlebars", function(c)

    -- buttons for the titlebar

    local buttons = gears.table.join(

        awful.button({ }, 1, function()

            c:emit_signal("request::activate", "titlebar", {raise = true})

            awful.mouse.client.move(c)

        end),

        awful.button({ }, 3, function()

            c:emit_signal("request::activate", "titlebar", {raise = true})

            awful.mouse.client.resize(c)

        end)

    )


    awful.titlebar(c) : setup {

        { -- Left

            awful.titlebar.widget.iconwidget(c),

            buttons = buttons,

            layout  = wibox.layout.fixed.horizontal

        },

        { -- Middle

            { -- Title

                align  = "center",

                widget = awful.titlebar.widget.titlewidget(c)

            },

            buttons = buttons,

            layout  = wibox.layout.flex.horizontal

        },

        { -- Right

            awful.titlebar.widget.floatingbutton (c),

            awful.titlebar.widget.maximizedbutton(c),

            awful.titlebar.widget.stickybutton   (c),

            awful.titlebar.widget.ontopbutton    (c),

            awful.titlebar.widget.closebutton    (c),

            layout = wibox.layout.fixed.horizontal()

        },

        layout = wibox.layout.align.horizontal

    }

end)


-- Enable sloppy focus, so that focus follows mouse.

--client.connect_signal("mouse::enter", function(c)

--    c:emit_signal("request::activate", "mouse_enter", {raise = false})

--end)



client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)

beautiful.useless_gap = 5

client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)



-- Focus management al cambiar de tag lo maneja awful.autofocus


-- }}}

local function run_once(cmd)
    local name = cmd:match("^%S+")
    awful.spawn.with_shell(string.format("pgrep -u \"$USER\" -x '%s' > /dev/null || %s", name, cmd))
end


awful.spawn.with_shell(
  "pkill xidlehook; " ..
  "xidlehook " ..
  "--not-when-fullscreen " ..
  "--not-when-audio " ..
  "--timer 60 'bash ~/.local/bin/awesome-suspend.sh' ''"
)



run_once("redshift-gtk")

-- 4. Estética y Red

awful.spawn.with_shell("killall -q picom; sleep 0.5; picom -b")

run_once("nm-applet")
awful.spawn.with_shell("wmname LG3D")
-- Al final de ~/.config/awesome/rc.lua
run_once("gentle_pipewire_start")

awful.spawn.with_shell("xsetroot -cursor_name left_ptr")
run_once("greenclip daemon")
awful.spawn.with_shell("killall -q conky; sleep 0.5 && conky -c ~/.config/conky/conky.conf")
run_once("udiskie --tray")
run_once("blueman-applet")
