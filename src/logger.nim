import logging

const debug = false # set this to true to get debug messages

var consoleLog* = newConsoleLogger(fmtStr="kauw/ $time/ $levelname: ")

proc log* (lvl: Level, str: string) =
    if lvl == lvlDebug: 
        if not debug: return
    consoleLog.log(lvl, str)