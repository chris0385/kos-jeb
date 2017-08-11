set config:IPU to max(300,config:IPU).
set config:TELNET to true. // port 5410 by default

global logFile is ("log/log_"+SHIP:NAME+".txt").

global debug_drawVec is false.

// wait for communication link
wait 1.
switch to 0.

log "Starting..." to logFile.

writejson(SHIP:RESOURCES, "log/"+SHIP:NAME+"-resources.json").

writejson(stage:resources, "log/stage-resources.json").

list engines in _e.
writejson(_e, "log/"+SHIP:NAME+"-engines.json"). 
