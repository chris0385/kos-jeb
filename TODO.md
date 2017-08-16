
@see https://drive.google.com/drive/folders/0Bxkeai7oN35ffl9kb2xGN2Q5cFI0TFg3RmVYYzg0aE9PNW1oUnRmNUwtVzA5VlllOU51eUE?pageId=102089565398677876056



* (1) Landing (hard to do manually) \
    !!! fix refgerential at suicide_burn3
* (2) Staging (usefull for landing if high delta-V required)
* 3) Delta-V & burn-time calculation (usefull for landing)
* (5) More or less precise athmospheric reentry (ie, land close to KSC)
* (9) Circularisation at apoapsis
* (10) Ascent
* (n) Burn together style: autopilot following another vessel (staying in physics load range) \
  Maybe just make script tweakable: e.g.
```c
stayCloseTo(VESSEL("atlas")). // Configures general parameter
runpath("ascendGuidance.ks", 100000). // run ascend script
```
