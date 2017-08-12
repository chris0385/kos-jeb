// https://www.youtube.com/watch?v=hIuU0ZMOCVY  + blog https://amyparent.com/post/automating-rocket-launches/

// runpath("pilot/ascent.ks", 100000).

parameter paltitude.
parameter pinclination is 0.

runoncepath("library/lib_lazcalc.ks").
runoncepath("lib/shipInfo.ks").
runoncepath("utils/staging.ks").
runoncepath("sys/timers.ks").

function hud {
	parameter text.
	parameter delaySec is 8.
	HUDTEXT( text,
			 delaySec,
			 1,
			 25,
			 white,
			 true).
}

SET AZcalc to LAZcalc_init(paltitude,pinclination).
SET launchAzimuth to LAZcalc(AZcalc).

SET pit to 90.
set th to 0.

sas off.
rcs off.

lock steering to heading(launchAzimuth, pit).
lock throttle to th.

hud("Starting ascent").

function boost {
	set th to 1.
	if ship:velocity:Surface:Mag > 80 or alt:radar > 1000 { 
		set launchState to turn@.
	}
}

function turn {
	local apo is ship:OBT:APOAPSIS.
	//eta:APOAPSIS
	local angle is 90*apo / paltitude.
	set pit to 90-angle.
	if apo >= paltitude {
		set launchState to circularize@.
	}
}

function circularize {
	set ended to true.
}

until ship:status <> "PRELAUNCH" {
	stage.
	wait 0.1.
}

set launchState to boost@.
set ended to false.

registerCallback_deac(stager@, everyXSeconds(0.5), {return not ended.}).

until ended { 
	launchState().
	wait 0.
}

unlock steering.
unlock throttle.