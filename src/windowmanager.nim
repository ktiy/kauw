import 
    x11/[x, xlib],
    config, /types,
    logging, /logger

type 
    WindowManager* = ref object
        display: PDisplay
        root: Window

# Initialiazation stuff
proc initShortcutKeys (wm: WindowManager)

# Error Handlers
proc onWMDetected (display: PDisplay, e: PXErrorEvent): cint{.cdecl.}
proc onXError (display: PDisplay, e: PXErrorEvent): cint{.cdecl.}

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

# Run window manager
proc run* (wm: WindowManager) =
    initShortcutKeys wm

    discard XSetErrorHandler onWMDetected # Temporary error handler if there is another window manager running

    discard wm.display.XSelectInput(wm.root, SubstructureNotifyMask or SubstructureRedirectMask)
    discard wm.display.XSync XBool false

    discard XSetErrorHandler onXError

    while true:
        var e: PXEvent
        discard wm.display.XNextEvent e
        
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
            else: consoleLog.log(lvlWarn, "ignored event")

proc createWindowManager*: WindowManager =
    var display = XOpenDisplay nil
    
    if display == nil:
        consoleLog.log(lvlError, "failed to open X display " & $XDisplayName nil)
        quit QuitFailure
    
    return WindowManager(
        display: display,
        root: display.DefaultRootWindow())

# Initialization Stuff
proc initShortcutKeys (wm: WindowManager) =
    for key in config.keybindings:
        discard wm.display.XGrabKey(
            cint wm.display.XKeysymToKeycode(key.key),
            cuint key.mods,
            wm.root,
            XBool true,
            GrabModeAsync,
            GrabModeAsync)

# Error Handlers
proc onWMDetected (display: PDisplay, e: PXErrorEvent): cint{.cdecl.} = 
    if e.theType == BadAccess:
        consoleLog.log(lvlError, "other window manager detected")
        quit QuitFailure
    
    return 0

proc onXError (display: PDisplay, e: PXErrorEvent): cint{.cdecl.} =
    var errorText = newString 1024

    discard display.XGetErrorText(
        cint e.error_code,
        cstring errorText,
        cint len errorText)
    
    consoleLog.log(
        lvlError, "received X error: \n" &
                  "   request: " & $e.request_code & "\n" &
                  "   error code: " & $e.error_code & " - " & errorText & "\n" &
                  "   resource id: " & $e.resourceid)

    return 0

# Events
proc onCreateNotify (wm: WindowManager, e: PXCreateWindowEvent) = return
proc onDestroyNotify (wm: WindowManager, e: PXDestroyWindowEvent) = return
proc onReparentNotify (wm: WindowManager, e: PXReparentEvent) = return
proc onMapNotify (wm: WindowManager, e: PXMapEvent) = return
proc onUnmapNotify (wm: WindowManager, e: PXUnmapEvent) = return
proc onConfigureNotify (wm: WindowManager, e: PXConfigureEvent) = return
proc onMapRequest (wm: WindowManager, e: PXMapRequestEvent) = return

proc onConfigureRequest (wm: WindowManager, e: PXConfigureRequestEvent) = 
    var changes: PXWindowChanges

    changes.x = e.x
    changes.y = e.y
    changes.width = e.width
    changes.height = e.height
    changes.border_width = e.border_width
    changes.sibling = e.above
    changes.stack_mode = e.detail 

    discard wm.display.XConfigureWindow(e.window, cuint e.value_mask, changes)

proc onButtonPress (wm: WindowManager, e: PXButtonEvent) = return
proc onButtonRelease (wm: WindowManager, e: PXButtonEvent) = return
proc onMotionNotify (wm: WindowManager, e: PXMotionEvent) = return
proc onKeyPress (wm: WindowManager, e: PXKeyEvent) = return
proc onKeyRelease (wm: WindowManager, e: PXKeyEvent) = return