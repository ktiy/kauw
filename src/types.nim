import x11/[x]

type    
    KeyFunc* = enum
        closeWindow,
        nextWindow,
        spawnCustom
    
    Key* = object
        mods*: int
        key*: KeySym
        keyfunc*: KeyFunc
        command*: string

proc initKey* (keyfunc: KeyFunc, mods: int, key: KeySym, command = ""): Key =
    return Key(
        mods: mods,
        key: key,
        command: command,
        keyfunc: keyfunc)