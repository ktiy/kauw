import 
    types,
    x11/[x, keysym]

# settings, or something along those lines
# currently unused
const 
    # default mod key, run xmodmap to see what the mod keys are on your current keyboard layout
    # Mod1 is alt and Mod4 is super
    modifier* = Mod1Mask

    # if it isn't obvious, hex values go here
    colours* = (
        focused:    0xFBFDFF,
        unfocused:  0x9BCDFF,
        background: 0x232323)

    # store keybindings here
    keybindings*: seq[Key] = @[
        closeWindow.initKey(
            key = XK_c,
            mods = modifier),

        nextWindow.initKey(
            key = XK_Tab,
            mods = modifier),
        
        spawnCustom.initKey(
            key = XK_Return,
            mods = modifier,
            command = "st")]