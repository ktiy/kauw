import objects, x11/xlib

proc masterStack* (wm: WindowManager, w: cuint, h: cuint, offset: cuint) =
    var 
        n = cuint wm.clients.len
        leftoverPixels = h - ((n-1) * (h div (n-1)))
        lastEnd: cint = 0
    
    for i in 1..n-1:
        var height = (h div (n-1))
        if leftoverPixels > 0: 
            height += 1
            leftoverPixels -= 1

        discard wm.display.XMoveResizeWindow(wm.clients[i], cint w div 2, lastEnd, (w div 2)-offset, height-offset)
        
        lastEnd += cint height