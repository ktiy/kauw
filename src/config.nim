import types

# settings, or something along those lines
# currently unused
const 
    # default mod key, run xmodmap to see what the mod keys are on your current keyboard layout
    # Mod1 is alt and Mod4 is super
    modifier* = "mod1"

    # if it isn't obvious, hex values go here
    colours* = (
        focused:    0xFBFDFF,
        unfocused:  0x9BCDFF,
        background: 0x232323)

    # store keybindings here
    keybindings*: seq[Key] = @[
        closeWindow.initKey(
            keys = @["c"],
            mods = @[modifier, "shift"]),

        nextWindow.initKey(
            keys = @["tab"],
            mods = @[modifier]),
        
        spawnCustom.initKey(
            keys = @["return"],
            mods = @[modifier],
            "st")]