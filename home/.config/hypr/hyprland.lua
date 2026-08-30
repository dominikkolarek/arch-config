-- Hyprland configuration
-- Migrated from hyprland.conf

local home = os.getenv("HOME") or ""

------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "thunar"
local menu        = "wofi --show drun"


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in     = 4,
        gaps_out    = 8,
        border_size = 2,
        layout      = "dwindle",

        col = {
            active_border   = "rgba(8ab88cff)",
            inactive_border = "rgba(3a5140ff)",
        },
    },

    decoration = {
        rounding = 8,

        active_opacity   = 1.0,
        inactive_opacity = 0.92,

        blur = {
            enabled           = true,
            size              = 4,
            passes            = 2,
            new_optimizations = true,
            xray              = true,
            ignore_opacity    = true,
        },

        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 2,
            color        = "rgba(00000055)",
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        disable_hyprland_logo = true,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout    = "jp",
        follow_mouse = 1,

        touchpad = {
            natural_scroll = true,
            tap_to_click   = true,
        },
    },
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

-- AirPods
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("bluetoothctl connect CC:4B:04:59:47:CB"))

-- Focus
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Workspaces
for i = 1, 4 do
    hl.bind(mainMod .. " + " .. i,           hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i,   hl.dsp.window.move({ workspace = i }))
end

-- Mouse drag
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Alt-tab
hl.bind("ALT + TAB", function()
    hl.dispatch(hl.dsp.window.cycle_next({ next = true }))
    hl.dispatch(hl.dsp.window.bring_to_top())
end, { repeating = true, description = "Next window" })

hl.bind("ALT + SHIFT + TAB", function()
    hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
    hl.dispatch(hl.dsp.window.bring_to_top())
end, { repeating = true, description = "Previous window" })

-- Rofi window switcher
hl.bind(mainMod .. " + TAB",
    hl.dsp.exec_cmd(home .. "/.config/rofi/window-switcher.sh"))

-- Brightness and volume
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true })

-- Media
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Screenshot
hl.bind("PRINT", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))


---------------------
---- WINDOW RULES ----
---------------------

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})


-----------------
---- HYPRBARS ----
-----------------

if hl.plugin.hyprbars ~= nil then
    hl.config({
        plugin = {
            hyprbars = {
                enabled                    = true,
                bar_height                 = 40,
                bar_padding                = 12,
                bar_button_padding         = 12,
                bar_color                  = "rgba(0f1610ee)",
                bar_blur                   = false,
                bar_title_enabled          = true,
                bar_text_size              = 14,
                bar_text_font              = "JetBrainsMono Nerd Font",
                bar_text_align             = "left",
                bar_buttons_alignment      = "right",
                bar_part_of_window         = true,
                bar_precedence_over_border = true,
                icon_on_hover              = false,
                col = {
                    text = "rgba(8ab88cff)",
                },
            },
        },
    })

    -- bg_color is the circle behind the glyph.
    -- Matching it to bar_color makes the circle disappear.
    hl.plugin.hyprbars.add_button({
        bg_color = "rgba(00000000)",
        fg_color = "rgb(8ab88c)",
        size     = 26,
        icon     = "󰅖",
        action   = "hyprctl dispatch killactive",
    })

    hl.plugin.hyprbars.add_button({
        bg_color = "rgba(00000000)",
        fg_color = "rgb(6b8f6d)",
        size     = 26,
        icon     = "󰊓",
        action   = "hyprctl dispatch fullscreen 1",
    })
end


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("sh -c 'sleep 1 && awww img " .. home .. "/Pictures/wallpapers/wall.png'")
    hl.exec_cmd("hyprpm reload -n")
end)
