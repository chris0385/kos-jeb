// TODO: handle manual stage while running (store expected stage number)
function stager {
	list ENGINES in elist.
	if not stage:READY {
		return.
	}
	for e in elist {
		if e:FLAMEOUT {
			stage.
			print "STAGING!" at (0,0).
			break.
		}
	}
}