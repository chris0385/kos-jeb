
runoncepath("lib/list.ks").

local BD_ModuleNames is UNIQUESET("BDAdjustableRail", "RadarWarningReceiver", "ModuleECMJammer", "ModuleTurret", "MissileTurret", "ModuleWingCommander", "MissileLauncher", "BDModulePilotAI", "BDACategoryModule", "CMDropper", "BDModulePilotAI", "ModuleTargetingCamera", "MissileFire", "ModuleRadar").

function isBDPart {
	parameter apart.
	for module in apart:modules {
		if BD_ModuleNames:contains(module) {
            return true.
        }
	}
    return false.
}


function findBdParts {
    return list_filter(ship:parts, isBDPart@).
}


function ballistic {
//TODO
    SET myNode to NODE( TIME:SECONDS+10, 500000, 0, 0000 ). ADD myNode.
    if ADDONS:TR:AVAILABLE {                                           
        if ADDONS:TR:HASIMPACT {      
            PRINT ADDONS:TR:IMPACTPOS.
        } else {                                     
            PRINT "Impact position is not available".
        }   
    } else {                                   
        PRINT "Trajectories is not available.".
    }
}

if 0 {
    print enumerable_copy(list_map(findBdParts(), {parameter p. return p:name.})).
}
