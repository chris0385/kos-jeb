@lazyglobal off.

runoncepath("lib/list.ks").

runoncepath("data/db_maxThrust.ks").

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
			print e:name.
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
