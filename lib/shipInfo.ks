
@lazyglobal off.

runoncepath("lib/list.ks").

function curThrust {
	list engines in engs.
	local sumTh is 0.
	for e in engs {
		set sumTh to sumTh + vdot(e:facing:forevector,ship:facing:forevector) * e:thrust.
	}
	return sumTh.
}

function availableStageRessources {
	return list_filter( stage:resources, { parameter r. return r:capacity > 0.01. } ).
}
