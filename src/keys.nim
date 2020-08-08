type    
    KeyFunc* = enum
        closeWindow,
        nextWindow,
        setMaster,
        spawnCustom
    
    Key* = object
        mods*: cuint
        key*: string
        keyfunc*: KeyFunc
        command*: string

proc initKey* (keyfunc: KeyFunc, mods: cuint, key: string, command = ""): Key =
    return Key(
        mods: mods,
        key: key,
        command: command,
        keyfunc: keyfunc)