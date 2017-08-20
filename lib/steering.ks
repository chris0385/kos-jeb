

// steering while ignoring roll direction: 
//lock steering to LOOKDIRUP(someDirection:vector, facing:topvector).

function killrotation {
	lock steering to facing.
	when ship:angularvel:mag < 0.01 then {
		print "killrotation done".
		if steering = facing {
			unlock steering.
		}
	}
}
