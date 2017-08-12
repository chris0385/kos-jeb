

// factory method for check function
function afterXSeconds {
	parameter delay.
	local later is TIME:SECONDS + delay.
	return { return TIME:SECONDS > later. }.
}

// factory method for check function
// Note: this will be true one time, then false again until delay passed.
function everyXSeconds {
	parameter delay.
	local later is TIME:SECONDS + delay.
	return { 
		if TIME:SECONDS > later {
			set later to TIME:SECONDS + delay.
			return true.
		}
		return false.
	}.
}

function registerCallback {
	parameter callback.
	parameter cond is { return true. }.
	local active is true.
	
	when cond() then {
		if active {
			callback().
			preserve.
		}
	}
	return { set active to false. }.
}

function registerCallback_deac {
	parameter callback.
	parameter cond is { return true. }.
	parameter active is { return true. }.
	
	when cond() then {
		if active() {
			callback().
			preserve.
		}
	}
}