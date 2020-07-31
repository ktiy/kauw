import /keys, x11/x

# settings, or something along those lines
const 
    # default mod key, run xmodmap to see what the mod keys are on your current keyboard layout
    # Mod1 is alt and Mod4 is super
    modifier* = Mod1Mask

    # if it isn't obvious, hex values go here
    colours* = (
        focused:    "#fbfdff",
        unfocused:  "#295eb3",
        background: "#232323")
    
    init* = @[
        "xsetroot -solid \"" & colours.background & "\""]
    
    # in pixels
    frameWidth* = 2

    # store keybindings here
    keybindings*: seq[Key] = @[
        # alt + shift + q will close the focused window
        initKey(
            closeWindow,
            key = "q",
            mods = modifier or ShiftMask),

        # alt + tab will cycle the focus through the windows
        initKey(
            nextWindow,
            key = "Tab",
            mods = modifier),
        
        # alt + return will open st, you can replace this with whatever your preferred terminal is
        initKey(
            spawnCustom,
            key = "Return",
            mods = modifier,
            command = "st")] 