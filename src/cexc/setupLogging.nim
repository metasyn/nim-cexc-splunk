import logging
from strformat import fmt
from posix import getpid
from ospaths import getEnv, joinPath
from os import getCurrentDir

proc setupLogger*(name: string) =
    let 
      splunkHome = getEnv("SPLUNK_HOME")
      pid = getpid()
      verboseFmtStr = fmt"$levelid, [$datetime] {pid} -- $appname: "
      fileName = fmt"{name}.log"

    let path = if not (splunkHome == ""): 
      joinPath(@[splunkHome, "var", "log", "splunk", fileName]) 
    else: 
      joinPath(@[getCurrentDir(), fileName])

    var fL = newFileLogger(path, fmtStr = verboseFmtStr)
    addHandler(fL)