

local __THROTTLES is lexicon().

function throttleControl {
	if __THROTTLES:LENGTH = 0 {
		return 0.
	}
	local th is 1.
	for tctl is __THROTTLES:values() {
		set th to th * tctl().
	}
	return th.
}

function throttle_limitAcceleration {
	parameter acc.
	
	if acc < 0 {
		__THROTTLES:remove("limitAcceleration").
		return.
	}
	__THROTTLES:add("limitAcceleration", {
		//TODO: implement
		return 1.
	}).
}

// TODO: limit dyn pressure

// TODO: prevent overheat

function throttle_register {
	parameter name.
	parameter delegate is DONOTHING.
	if delegate = DONOTHING {
		__THROTTLES:remove(name).
	} else {
		set __THROTTLES[name] to delegate.
	}
}

//lock throttle to throttleControl().