import 
    /windowmanager,
    logging, /logger

proc main() =
    let wm = createWindowManager()

    if wm == nil:
        consoleLog.log(lvlError, "failed to initialize window manager")
        quit QuitFailure
    
    wm.run()

    quit QuitSuccess
    
main()