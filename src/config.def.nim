import objects, x11/x

const 
    MOD* = Mod1Mask
    SHIFT* = ShiftMask

    colours* = (
        focused:    "#fbfdff",
        unfocused:  "#295eb3",
        background: "#232323")
    
    frameWidth* = 2

    init* = [
        "xsetroot -solid \"" & colours.background & "\""]

    keybindings* = [
        key( MOD or SHIFT,  "q",        closeWindow     ),      # alt + shift + q will close the focused window
        key( MOD,           "Tab",      nextWindow      ),      # alt + tab will cycle the focus through the windows
        key( MOD,           "period",   setMaster       ),      # alt + period will set the focused window to the master window
        key( MOD,           "Return",   spawnCustom,    "st")]  # alt + return will open st, you can replace this with whatever your preferred terminal is