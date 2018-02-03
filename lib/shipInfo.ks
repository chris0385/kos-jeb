@lazyglobal off.

runoncepath("lib/list.ks").

runoncepath("data/db_maxThrust.ks").

runoncepath("lib/gui.ks").

function maxThrust {
	parameter eng.
	return DB_MAXTHRUST[eng:name].
}

function curThrust {
	local engs is 0.
	list engines in engs.
	local sumTh is 0.
	for e in engs {
		if e:ignition and not e:flameout {
			// print e:name.
			set sumTh to sumTh + vdot(e:facing:forevector,ship:facing:forevector) * e:thrust.
		}
	}
	return sumTh.
}

function ancestorDecoupler {
	parameter apart.
	if not apart:hasparent {
		return false.
	}
	local par is apart:parent.
	until par:MODULES:CONTAINS("ModuleDecouple") or par:MODULES:CONTAINS("ModuleAnchoredDecoupler") {
		if not par:hasparent {
			return false.
		}
		set par to par:parent.
	}
	return par.
}

function ejectionStage {
	parameter apart.
	local decoupler is ancestorDecoupler(apart).
	if decoupler:typename = "Boolean" {
		return -1.
	}
	return decoupler:stage.
}

function thrustForStage {
	parameter stageId.
	local engs is 0.
	list engines in engs.
	local sumTh is 0.
	for e in engs {
		if e:stage >= stageId and ejectionStage(e) < stageId {
			//print e:name+"+#"+maxThrust(e)+" eject="+ejectionStage(e).
			set sumTh to sumTh + vdot(e:facing:forevector,ship:facing:forevector) * maxThrust(e).
		}
	}
	return sumTh.
}

function availableStageRessources {
	return list_filter( stage:resources, { parameter r. return r:capacity > 0.01. } ).
}


function availableShipRessources {
	return list_filter( ship:resources, { parameter r. return r:capacity > 0.01. } ).
}

function curFlow {
	local engs is 0.
	list engines in engs.
	local sumFlow is 0.
	for e in engs {
		//print e:name + " # "+e:fuelflow.
		set sumFlow to sumFlow + e:fuelflow.
	}
	return sumFlow.
}

function energy {
   local vessel is ship.
   local m is vessel:mass*1000.
   local v is ship:velocity:surface:mag.
   // h is distance from center of planet
   local h is vessel:BODY:POSITION:mag.
   //local h is vessel:geoposition:terrainheight
   local ec is 0.5*m*v*v.
   local epx is -vessel:body:mu *m/h.
   local ep0 is -vessel:body:mu *m/vessel:body:radius.
   local ep is epx-ep0.
   //print epx+"#"+ep0+"->"+ep.
   local e is ec+ep.
   //print "ec="+ec+", ep="+ep+" E="+e.
   
   //print "Vg "+ship:groundspeed.
   return list(e,ec,ep).
}


function fuelQuery {
   parameter partFilter is 0.
   parameter resourceFilter is { parameter p. return true. }.
   parameter vessel is ship.
   if not partFilter {
      set partFilter to { parameter p. return true. }.
   }
   local parts is list_filter(ship:parts, { 
      parameter p. 
      return p:RESOURCES:length > 0 and partFilter(p) and list_filter(p:resources, resourceFilter):length>0. 
   }).
   local t is list_map_flat(parts, { parameter p. return list_filter(p:resources, resourceFilter). }).
   return list_reduce(t, lexicon_merge@, lexicon(), {
      parameter r. 
      return lexicon(r:name, r:capacity). // TODO: make configurable
   }).
}


function planeInfo {
   local bld is infoBuilder().
   local geoPos is ship:GEOPOSITION.
   local f_range is "".
   local fuelUse is fuelUseCalculator({
      parameter name.
      parameter value.
      set value to ""+value.
      if name = "range" {
		set f_range to value.
      }
   }).
   
   bld("Alt (GND)", { 
      set geoPos to ship:GEOPOSITION.
      return round(ship:ALTITUDE-max(geoPos:TERRAINHEIGHT,0))+" m".
   }).
   bld("Speed (surf)", { return round(ship:VELOCITY:SURFACE:MAG)+" m/s". }, "<color=orange>$$</color>").
   bld("").
   bld("Grnd-speed", { return round(ship:groundspeed)+" m/s". }).
   bld("Vert-speed", { return round(ship:verticalspeed,1)+" m/s". }).
   bld("Mass", { return round(ship:mass,1)+" t". }).
   bld("Dyn-Pressure", { return round(ship:DYNAMICPRESSURE,3)+" ATM". }).
   bld("Pos", { return round(geoPos:LAT,2)+"N "+round(geoPos:LNG,2)+"W "+round(ship:ALTITUDE)+" Up". }).
   bld("").
   bld("Throttle", { return round(throttle*100)+"%". }).
   bld("State", {
      local s is "".
      if gear {
         set s to s+"GEARS ".
      }
      if BRAKES {
         set s to s+"BRAKES ".
      }
      if LIGHTS {
         set s to s+"LIGHT ".
      }
      if RCS {
         set s to s+"RCS ".
      }
      if SAS {
         set s to s+"SAS ".
      }
      return s. 
   }).
   bld("Range", {
		fuelUse().
		return f_range+" km".
   }).
   return bld.
}

function fuelUseCalculator {
   parameter callback is {
      parameter name.
      parameter value.
      print name+" = "+value. 
   }.
   LOCAL vessel IS ship.

   
   local eLast is 0.
   local tLast is time:seconds.
   local maxEff is 0.

   return {
		if vessel:status <> "FLYING" {
			return.
		}
		local t to time:seconds.
		if tLast = t {
			return.
		}
      
               //  TODO: dirty, buggy
         //set maxFuel to list_filter( ship:resources, { parameter r. return r:capacity > 0.01 and r:name:contains("fuel"). } )[0]:capacity.
         local maxFuel to fuelQuery(0, { parameter r. return r:enabled. })["LiquidFuel"].
      
         local m is vessel:mass*1000. // kg
         local v to ship:velocity:surface:mag. // m/s
         local e to energy()[0].
         local flow to curFlow().
         //local vg to ship:groundspeed.
         local thrust to curThrust()*1000. // Newton= kg.m/s2
         
         local dt to t-tLast.

         local thrustPower to thrust*v.

         local expectedAcc to thrust/m. // m/s2
        
         
         if thrustPower<0.1 {
           set thrustPower to 0.1. //TODO handle zero
         }
         if flow=0 {
           set flow to 0.00000001. //TODO handle zero
         }
         local expectedEnergy to eLast+thrustPower*dt.
         local lostE to expectedEnergy-e.
         
         local effFlow to flow*(lostE/dt)/thrustPower.
         
         local consump to effFlow*1000/v.
         
         callback("Unit/km", consump).
         callback("Range", round(maxFuel/consump)). // km
         callback("Power", round(thrustPower)). // watt
         callback("Eff-flow", effFlow). // unit/sec
         
         //local outp to "Unit/km: "+consump.
         //set outp to outp + " range: "+round(maxFuel/consump).
         
         //set outp to outp + " Power: "+floor(thrustPower)+" W".
         //set outp to outp + " Flow:"+effFlow +" ("+flow+")".
         //set outp to outp + " Thrust="+thrust+" -> expect-acc="+expectedAcc.
         //set outp to outp + " expectedEnergy="+floor(expectedEnergy)+" lostPower="+floor(lostE/dt).
         
         if false {
            set efficiency to thrustPower/1000000/flow. 
            // 276 MJoule/Unit max  5kg/Unit of fuel  (Kerosene has 214 MJoule for 5 kg)
            //    -> Maybe buggy calculation of KSP when accelerating over the normal operating speed?
            if count > 100 {
               set maxEff to max(maxEff,efficiency).
               print "Eff:"+efficiency+"/"+maxEff.
            }
         }
         
         //print outp.
         //print flow*
         
         set tLast to t.
         set eLast to e.
      }.
}

function printFuelUse {
	local count is 0.
	local fuse is fuelUseCalculator().
	when count < 100000 then {
		set count to count+1.

		//and vessel:status = "FLYING"
		if mod(count,10)=0  {
			fuse().
		}
      preserve.
   }
}
