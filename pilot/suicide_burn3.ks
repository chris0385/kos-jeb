//Frame of references https://ksp-kos.github.io/KOS/math/ref_frame.html#ship-raw
//run suicide_burn3.

// TODO: ship mass change is ignored
// TODO: stay "on rails" until breaking burn; no need to simulate before.
// TODO: we know that the breaking burn has to be done before periapsis -> tooLate = time to periapsis
// TODO: wrap everything in functions
// TODO: document functions
// TODO: test landing on mars with drag disabled by cheat menu (i.e. remove atmosphere of mars). Delta-V needed 3800m/s
//       Mars has Equatorial rotation velocity of 241 m/s (=> surface velocity != orbital velocity)
// TODO: gears, sas...
// TODO: if ship:status = "LANDED" or ship:status = "Splashed"   ===== landing

//KUniverse:QUICKLOADFROM("kos").


parameter maxEndAlt is 100. // TODO: only for simulation far away
parameter logFile is "suicide_burn2.txt".

set config:IPU to 2000. // TODO: rollback after run.

// END conf
log "BEGIN" to logFile.

function simulateBurn {
	parameter posV.
	parameter velV.
	parameter elapsed is 0.
	parameter nextWaitTime is 0.

	// can be set if the simulation goes over multiple physics ticks, to fix it
	parameter body_position is SHIP:BODY:POSITION.
	
	function geopositionOf {
		parameter pos.
		if body_position = SHIP:BODY:POSITION {
			return body:GEOPOSITIONOF(posV).
		}
		return body:GEOPOSITIONOF(posV-SHIP:BODY:POSITION+body_position).
	}
	
	local dt is 1.

	local bodyPositionV is body_position.
	// this is V(0,0,0) as we are in the frame of the ship
	local groundGrav is body:mu/body:radius^2.
	// distance from center of body.
	local radius is bodyPositionV:MAG.
	local nullV is V(0,0,0).
	local accV is nullV.
	local thrustV is nullV.

	local burnTime is 0.

	local prevState is lexicon("V",velV, "P", posV, "Wait", 0).
	local burnStarted is false.

	until false {
		
		if not burnStarted {
			if elapsed >= nextWaitTime {
				set burnStarted to true.
				set prevState to lexicon("V",velV, "P", posV, "Wait", elapsed).
			}
		}
		
		local radarAlt is radius-body:radius-geopositionOf(posV):terrainheight.
		
		// be more precise when close to the body; adjust time step
		local cdt is min(dt, max(radarAlt/(velV:MAG*10), 0.01)).
		
		if radarAlt < 0 {
			//log "Burn sheduled too late at "+nextWaitTime+"; alt="+radarAlt+" at "+elapsed to logFile.
			return list("CRASH", prevState, lexicon("V",velV, "P", posV, "final-time", elapsed, "final-radarAlt", radarAlt, "final-burnTime", burnTime)).
		}
		
		if burnStarted {
			if vdot(velV, bodyPositionV) > 0 and radarAlt > 0 {
				// we are getting closer...

				// Retrograde burn. TODO: surface retrograde??
				set thrustV to SHIP:MAXTHRUST/SHIP:MASS*(-velV:NORMALIZED).
				
				set burnTime to burnTime+cdt.
				//print "Simulated(burn:"+burnTime+",h="+radarAlt+",v="+vdot(velV, bodyPositionV)/radius+")".
			} else {
				//log "Burn sheduled too early at "+nextWaitTime+"; alt="+radarAlt+" at "+elapsed to logFile.
				if radarAlt >= 0 {
					if radarAlt <= maxEndAlt {
						return list("OK", prevState, lexicon("V",velV, "P", posV, "final-time", elapsed, "final-radarAlt", radarAlt, "final-burnTime", burnTime)).
					} else {
						return list("TOO-HIGH", prevState, lexicon("V",velV, "P", posV, "final-time", elapsed, "final-radarAlt", radarAlt, "final-burnTime", burnTime)).
					}
				}
				print "Unexpected state.".
				err.
			}
		}
		set bodyPositionV to (body_position-posV).
		set radius to bodyPositionV:MAG.
		
		set elapsed to elapsed+cdt.
		
		set accV to body:mu/radius^3*bodyPositionV + thrustV.
		set velV to velV + accV*cdt.
		set posV to posV + velV*cdt.
		
	}
}

function dichotomySearch {
	
	local body_position is SHIP:BODY:POSITION.
	local posV is ship:position.
	local velV is ship:velocity:orbit.
	
	local prevState is lexicon("V",velV, "P", posV, "Wait", 0).
	
	local tooEarly is 0.
	local tooLate is 1e10. // unknown yet
	local nextWaitTime is 0.
	
	local maxTooEarly is 0.
	
	local searchStartTime is time:seconds.
	
	until false {
		local simRes is simulateBurn(prevState["P"], prevState["V"], prevState["Wait"], nextWaitTime, body_position).
		local simStatus is simRes[0].
		local simState is simRes[2].
		
		if simStatus = "CRASH" {
			set tooLate to min(nextWaitTime, simState["final-time"]).
			set nextWaitTime to (tooEarly+tooLate)/2.
			log simStatus+"#nextWaitTime="+nextWaitTime to logFile.
		} else if simStatus = "TOO-HIGH" {
			set maxTooEarly to max(tooEarly, maxTooEarly).
			set tooEarly to nextWaitTime.
			set nextWaitTime to (tooEarly+tooLate)/2.
			set prevstate to simRes[1]. // state before burn start.
			log simStatus+"#nextWaitTime="+nextWaitTime to logFile.
		} else if simStatus = "OK" {
			print simRes.
			return list(searchStartTime+nextWaitTime, nextWaitTime).
		}
		print "Search wait time ["+tooEarly+", "+tooLate+"]" .
		
		if tooLate-tooEarly<=0.01 {
			print "interval empty ["+tooEarly+", "+tooLate+"]" .
			return list(searchStartTime+maxTooEarly, nextWaitTime).
		}
	}
}

function buildBurnController {
	parameter MINOUTPUT is 0.
	
	local pid is pidloop(0.1, 0.07, 0.01, MINOUTPUT, 1).
	local lastTh is 0.
	set pid:setpoint to ship:velocity:surface:mag.
	local tasks is list().
	
	return {
		local finalState to simulateBurn(ship:position, ship:velocity:surface)[2].
		// end alt minus remaining breaking distance
		local pidAlt is finalState["final-radarAlt"] - finalState["V"]:MAG^2/((SHIP:MAXTHRUST - body:mu/body:radius^2)/SHIP:MASS).
		local newSetPoint is ship:velocity:surface:mag/2 + 300.  // TODO:magic constant
		if pid:setpoint-newSetPoint > newSetPoint/3 {
			print "CHANGING SETPOINT TO "+newSetPoint+" ---------------".
			set pid:setpoint to newSetPoint.
		}
		
		// deal with unstable fuels (Real fuel)
		if tasks:length > 0 {
			for t in tasks { t(). }
			tasks:clear().
		}
		if lastTh > 0 {
			list engines in engs.
			for e in engs {
				if e:stage >= stage:number and e:flameout and e:thrust = 0 {
					e:shutdown().
					print "Reset engine "+e.
					tasks:add( { e:activate(). } ).
				}
			}
		}
		
		print "pidAlt="+pidAlt.
		set lastTh to pid:update(time:seconds, pidAlt).
		return lastTh.
	}.
}

function calcThrottle_pid {
	
	// pidloop(KP, KI, KD, MINOUTPUT, MAXOUTPUT).
	local MINOUTPUT is 0.
	local pid is pidloop(0.5, 0.4, 0.1, MINOUTPUT, 1).
	
	local maxAcceleration is SHIP:MAXTHRUST/SHIP:MASS-body:mu/body:radius^2.
	local AC_CONSTANT is 2*0.9*maxAcceleration.
	
	local calcSetPoint is { return round(-max(1, sqrt(AC_CONSTANT*ALT:RADAR))). }.
	set pid:setpoint to calcSetPoint().
	
	return {
		local wantedSetPoint is calcSetPoint().
		if pid:setpoint <> wantedSetPoint {
			print "Changing setpoint to "+wantedSetPoint.
			set pid:setpoint to wantedSetPoint.
		}
		local actualV is vdot(SHIP:VELOCITY:SURFACE, Up:VECTOR).
		print actualV.
		return pid:update(time:seconds, actualV). 
	}.
}

print "Searching required burn moment.".
set searchResult to dichotomySearch().
print searchResult.

print "Warping...".
kuniverse:timewarp:warpto(searchResult[0]-60).
wait 1.
wait until kuniverse:timewarp:rate = 1.

print "Enabling breaking burn controller..".
// TODO: minoutput
set burnController to buildBurnController(0.01).
lock steering to (-1) * SHIP:VELOCITY:SURFACE.
lock throttle to burnController().

wait until alt:radar < 5 or SHIP:VELOCITY:SURFACE:MAG < 6.

lock throttle to 0.
lock steering to UP.

//vcrs(up:vector,north:vector)

/// -----------------------------------
print "Last approach..".

set vDraw to VECDRAW(
		V(0,0,0),
		V(0,0,0),
		RGB(1,0,0),
		"Steering",
		1.0,
		TRUE,
		0.2
	).
	
	
when true then {
	if vDraw:SHOW { 
		if steering:typename = "Vector" {
			set vDraw:VEC to steering * 10. 
		}
		preserve. 
	}
}


lock steering to (ANGLEAXIS(min(20, max(-20, VANG(UP:VECTOR, (-1)*SHIP:VELOCITY:SURFACE) )),vcrs(UP:VECTOR, -SHIP:VELOCITY:SURFACE)) * UP:VECTOR).

wait until alt:radar < 200.

set c to calcThrottle_pid().
lock throttle to c().

wait until ship:status="LANDED" or (alt:radar < 10 and vdot(UP:VECTOR, SHIP:VELOCITY:SURFACE)>=0).

lock steering to UP.
set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
wait 2. // stabilise with steering active.
set vDraw:SHOW to false.
unlock steering.
unlock throttle.
wait 0.
CLEARVECDRAWS().


//run suicide_burn3.
if false {
switch to 0.
run suicide_burn3.

}
