@lazyglobal off.

function list_filter {
	parameter lst.
	parameter filterFunc.
	
	local result is list().
	for i in lst {
		if filterFunc(i) {
			result:add(i).
		}
	}
	return result.
}

function list_map {
	parameter lst.
	parameter mapFunc.
	
	local result is list().
	for i in lst {
		result:add(mapFunc(i)).
	}
	return result.
}
