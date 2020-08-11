import tables, x11/[x, xlib]

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

    WindowManager* = ref object
        display*: PDisplay
        screen*: PScreen
        colormap*: Colormap
        root*: Window

        clients*: seq[Window]
        focused*: int
        keys*: Table[cuint, objects.Key]

proc key* (mods: cuint, key: string, keyfunc: KeyFunc, command = ""): Key =
    return Key(
        mods: mods,
        key: key,
        command: command,
        keyfunc: keyfunc)