import 
    x11/[x, xlib],
    config, /keys,
    logging, /logger,
    tables, os

type 
    WindowManager* = ref object
        display: PDisplay
        screen: PScreen
        colormap: Colormap
        root: Window

        clients: seq[Window]
        keys: Table[cuint, Key]

# Initialiazation stuff
proc initKeybindings (wm: WindowManager)
proc initButtons (wm: WindowManager)
proc initCommands (wm: WindowManager)

# Error Handlers
proc onWMDetected (display: PDisplay, e: PXErrorEvent): cint{.cdecl.}
proc onXError (display: PDisplay, e: PXErrorEvent): cint{.cdecl.}

# Function
proc addWindow (wm: WindowManager, w: Window)
proc tileWindows (wm: WindowManager)

# Events
proc onCreateNotify (wm: WindowManager, e: PXCreateWindowEvent)
proc onDestroyNotify (wm: WindowManager, e: PXDestroyWindowEvent)
proc onReparentNotify (wm: WindowManager, e: PXReparentEvent)
proc onMapNotify (wm: WindowManager, e: PXMapEvent)
proc onUnmapNotify (wm: WindowManager, e: PXUnmapEvent)
proc onConfigureNotify (wm: WindowManager, e: PXConfigureEvent)
proc onMapRequest (wm: WindowManager, e: PXMapRequestEvent)
proc onConfigureRequest (wm: WindowManager, e: PXConfigureRequestEvent)
proc onButtonPress (wm: WindowManager, e: PXButtonEvent)
proc onButtonRelease (wm: WindowManager, e: PXButtonEvent)
proc onMotionNotify (wm: WindowManager, e: PXMotionEvent)
proc onKeyPress (wm: WindowManager, e: PXKeyEvent)
proc onKeyRelease (wm: WindowManager, e: PXKeyEvent)

# Create a window manager
proc createWindowManager*: WindowManager =
    var display = XOpenDisplay nil
    
    if display == nil:
        lvlError.log("failed to open X display " & $XDisplayName nil)
        quit QuitFailure
    
    var 
        screen = display.DefaultScreenOfDisplay()
    
    return WindowManager(
        display: display,
        screen: screen,
        colormap: screen.DefaultColormapOfScreen(),
        root: display.DefaultRootWindow(),
        
        clients: @[],
        keys: initTable[cuint, Key](1))

# Run window manager
proc run* (wm: WindowManager) =
    initKeybindings wm
    initButtons wm
    initCommands wm

    discard XSetErrorHandler onWMDetected # Temporary error handler if there is another window manager running

    discard wm.display.XSelectInput(wm.root, SubstructureNotifyMask or SubstructureRedirectMask)
    discard wm.display.XSync XBool false

    discard XSetErrorHandler onXError

    while true:
        var e: XEvent
        discard wm.display.XNextEvent(addr e)
        
        tileWindows wm

        case e.theType:
            of CreateNotify: wm.onCreateNotify addr e.xcreatewindow
            of DestroyNotify: wm.onDestroyNotify addr e.xdestroywindow
            of ReparentNotify: wm.onReparentNotify addr e.xreparent
            of MapNotify: wm.onMapNotify addr e.xmap
            of UnmapNotify: wm.onUnmapNotify addr e.xunmap
            of ConfigureNotify: wm.onConfigureNotify addr e.xconfigure
            of MapRequest: wm.onMapRequest addr e.xmaprequest
            of ConfigureRequest: wm.onConfigureRequest addr e.xconfigurerequest
            of ButtonPress: wm.onButtonPress addr e.xbutton
            of ButtonRelease: wm.onButtonRelease addr e.xbutton
            of MotionNotify: wm.onMotionNotify addr e.xmotion
            of KeyPress: wm.onKeyPress addr e.xkey
            of KeyRelease: wm.onKeyRelease addr e.xkey
            else: lvlWarn.log("ignored event " & $e.theType)

# Initialization Stuff
proc initKeybindings (wm: WindowManager) =
    discard wm.display.XUngrabKey(AnyKey, AnyModifier, wm.root)

    for key in config.keybindings:
        let keycode = wm.display.XKeysymToKeycode(XStringToKeysym key.key)

        wm.keys[cuint keycode] = key

        discard wm.display.XGrabKey(
            cint keycode,
            key.mods,
            wm.root, 
            XBool true,
            GrabModeAsync,
            GrabModeAsync)

proc initButtons (wm: WindowManager) =
    discard wm.display.XUngrabButton(AnyButton, AnyModifier, wm.root)

    for button in [1, 3]:
        discard wm.display.XGrabButton(
            cuint button,
            cuint Mod1Mask,
            wm.root,
            XBool true,
            ButtonPressMask or ButtonReleaseMask or PointerMotionMask,
            GrabModeAsync,
            GrabModeAsync,
            None,
            None)

proc initCommands (wm: WindowManager) =
    for cmd in config.init:
        discard execShellCmd cmd

proc λcloseWindow (wm: WindowManager) = return
proc λnextWindow (wm: WindowManager) = return
proc λspawnCustom (wm: WindowManager, key: Key) = return

# Error Handlers
proc onWMDetected (display: PDisplay, e: PXErrorEvent): cint{.cdecl.} = 
    if e.theType == BadAccess:
        lvlError.log("another window manager is already running")
        quit QuitFailure
    
    return 0

proc onXError (display: PDisplay, e: PXErrorEvent): cint{.cdecl.} =
    var errorText = newString 1024

    discard display.XGetErrorText(
        cint e.error_code,
        cstring errorText,
        cint len errorText)
    
    lvlError.log(
        "received X error: \n" &
        "   request: " & $e.request_code & "\n" &
        "   error code: " & $e.error_code & " - " & errorText & "\n" &
        "   resource id: " & $e.resourceid)

    return 0


proc addWindow (wm: WindowManager, w: Window) =
    wm.clients.add w

proc tileWindows (wm: WindowManager) =
    var 
        n = cuint wm.clients.len
        w = cuint wm.display.XDisplayWidth 0
        h = cuint wm.display.XDisplayHeight 0

    if n == 0:
        return
    if n == 1:
        discard wm.display.XMoveResizeWindow(wm.clients[0], 0, 0, w, h)
    else:
        # resize master window to take up half the screen
        discard wm.display.XMoveResizeWindow(wm.clients[0], 0, 0, cuint (w div 2), h)
    
        # maths, sort of explained here: https://i.imgur.com/fGxdfDh.png
        for i in 1..wm.clients.len-1:
            discard wm.display.XMoveResizeWindow(wm.clients[i], cint w div 2, cint (i-1) * cint (h div (n-1)), w div 2, h div (n-1))

# Events
proc onCreateNotify (wm: WindowManager, e: PXCreateWindowEvent) = return
proc onDestroyNotify (wm: WindowManager, e: PXDestroyWindowEvent) = return
proc onReparentNotify (wm: WindowManager, e: PXReparentEvent) = return
proc onMapNotify (wm: WindowManager, e: PXMapEvent) = return
proc onUnmapNotify (wm: WindowManager, e: PXUnmapEvent) =
    wm.clients.delete wm.clients.find(e.window)
    # seq.delete preserves order while seq.del may scramble it a little
    wm.tileWindows()

proc onConfigureNotify (wm: WindowManager, e: PXConfigureEvent) = return

proc onMapRequest (wm: WindowManager, e: PXMapRequestEvent) =
    discard wm.display.XMapWindow e.window
    wm.addWindow e.window
    wm.tileWindows()

proc onConfigureRequest (wm: WindowManager, e: PXConfigureRequestEvent) =
    var changes: XWindowChanges

    changes.x = e.x
    changes.y = e.y
    changes.width = e.width
    changes.height = e.height
    changes.border_width = e.border_width
    changes.sibling = e.above
    changes.stack_mode = e.detail 

    discard wm.display.XConfigureWindow(e.window, cuint e.value_mask, addr changes)

proc onButtonPress (wm: WindowManager, e: PXButtonEvent) = return
proc onButtonRelease (wm: WindowManager, e: PXButtonEvent) = return
proc onMotionNotify (wm: WindowManager, e: PXMotionEvent) = return
proc onKeyPress (wm: WindowManager, e: PXKeyEvent) =
    let key = wm.keys[e.keycode]
    case key.keyfunc:
        of closeWindow: wm.λcloseWindow()
        of nextWindow: wm.λnextWindow()
        of spawnCustom: wm.λspawnCustom key

proc onKeyRelease (wm: WindowManager, e: PXKeyEvent) = return