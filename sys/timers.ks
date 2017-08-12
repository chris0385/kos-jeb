

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
	local val is false.
	return { 
		if TIME:SECONDS > later {
			set later to TIME:SECONDS + delay.
			set val to not val.
		}
		return val.
	}.
}

if false {
	local tick is everyXSeconds(0.5).
	on tick() {
		dosmth().
		if not done { preserve. }.
	}
}
