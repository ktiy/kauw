type    
    KeyFunc* = enum
        closeWindow,
        nextWindow,
        spawnCustom
    
    Key* = object
        mods*: seq[string]
        keys*: seq[string]
        keyfunc*: KeyFunc
        command*: string

proc initKey* (keyfunc: KeyFunc, mods: seq[string], keys: seq[string], command = ""): Key =
    return Key(
        mods: mods,
        keys: keys,
        command: command,
        keyfunc: keyfunc)