
@lazyglobal off.

runoncepath("lib/shipInfo.ks").


function showModule {
	parameter module.
	parameter logFile is "module-info.txt".
	parameter gtab is "".
	local tab is "  ".
	
	log gtab+"module("+module:name+")" to logFile.
	for field in module:allfieldnames {
		log gtab+tab+"(F) "+field+" = "+module:getfield(field) to logFile.
	}
	for event in module:allevents {
		log gtab+tab+"(E) "+event to logFile.
	}
	for action in module:allactions {
		log gtab+tab+"(A) "+action to logFile.
	}
}

function showPart {
	parameter apart.
	parameter logFile is "engine-info.txt".
	parameter gtab is "".
	local tab is "  ".
	
	log gtab+"mass = "+apart:mass to logFile.
	log gtab+"drymass = "+apart:drymass to logFile.
	log gtab+"tag = "+apart:tag to logFile.
	log gtab+"stage = "+apart:stage to logFile.
	if not apart:resources:empty {
		log gtab+"resources = "+apart:resources:join(", ") to logFile.
	}
	for module in apart:modules {
		showModule(apart:getmodule(module), logFile, gtab).
	}
}

function showEngine {
	parameter engine.
	parameter logFile is "engine-info.txt".
	parameter gtab is "".
	local tab is "  ".
	
	log gtab+"engine("+engine:name+")" to logFile.
	
	log gtab+tab+"ignition = "+engine:ignition to logFile.  //=was activated
	log gtab+tab+"maxthrust = "+engine:maxthrust to logFile.
	log gtab+tab+"fuelflow = "+engine:fuelflow to logFile.
	log gtab+tab+"modes = "+engine:modes:join(", ") to logFile.
	log gtab+tab+"THROTTLELOCK = "+engine:THROTTLELOCK to logFile. // does this work for real fuels?
	showPart(engine, logFile, gtab+tab).
}

list engines in engs.
local a is 0.
for e in engs {
	showEngine(e).
	if e:stage >= stage:number {
		print e.
		print e:suffixnames.
		//if e:getmodule("ModuleEnginesRF"):getfield("status") = "Nominal" and a:getmodule("ModuleEnginesRF"):getfield("ignitions remaining")>0 {
		// a:getmodule("ModuleEnginesRF"):getfield("propellant") = "Very Stable"
		//}
	}
}
//run "lib/ship_debug".
