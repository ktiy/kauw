import 
    os,
    /windowmanager,
    logging, /logger

const version = "0.0.1"

proc main() =
    if paramCount() > 0:
        if paramStr(1) == "-v":
            echo "kauw version " & version
            quit QuitSuccess

    let wm = createWindowManager()

    if wm == nil:
        consoleLog.log(lvlError, "failed to initialize window manager")
        quit QuitFailure

    wm.run()

    quit QuitSuccess
    
main()