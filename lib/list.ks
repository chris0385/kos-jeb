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

function list_map_flat {
	parameter lst.
	parameter mapFunc.
	
	local result is list().
	for i in lst {
		local mapped is mapFunc(i).
		for v in mapped {
			result:add(v).
		}
	}
	return result.
}

function list_reduce {
	parameter lst.
	parameter combine.
	parameter initial is 0.
	parameter mapFunc is 0.
	
	if mapFunc <> 0 {
		for i in lst {
			set initial to combine(mapFunc(i),initial).
		}
	} else {
		for i in lst {
			set initial to combine(i,initial).
		}
	}
	return initial.
}

// ------------------

function object_oriented {
	parameter qLst. // constructor
	local priv is 0. // private member
	return lexicon(
		"q",{ 
			return qLst. 
		},
		"set", { parameter v. set priv to v. },
		"get", { return priv. }
	).
}

local NONE is list("NONE").
local FLATTEN is list("FLAT",0).

function query {
// todo: check parameter:typename to increase flexibility
	parameter qLst.
	
	function process {
		parameter it.
		parameter qIt.
		parameter collector.
		UNTIL NOT qIt:NEXT {
			local q is qIt:value.
			set it to q:call(it).
			if it = FLATTEN { // FAIL. iterator need to start at the same pos for everyone. Use sublist.
				local toFlatten is is[1].
				for it in toFlatten {
					process(it, qIt).
				}
			}
			if it = NONE {
				break.
			}
		}
		if it <> NONE {
			collector:add(it).
		}
	}
	
	return {
		parameter lst.
		parameter collector is list().
		for it in lst {
			local qIt is qLst:ITERATOR.
			process(it, qIt, collector).
		}
		return collector.
	}.
}

function q_filter {
	parameter cond.
	return {
		parameter it.
		if cond(it) {
			return it.
		}
		return NONE.
	}.
}

function q_flat {
	parameter cond.
	return {
		parameter it.
		if cond(it) {
			return it.
		}
		return NONE.
	}.
}


//print query(list(q_filter({parameter f. return f>5.})))(  list(7,32,0,1,8)  ).

// ------

function enumerable_copy {
	parameter src.
	parameter dst is uniqueset().
	
	for i in src {
		dst:add(i).
	}
	return dst.
}

// ----------------------------
function lexicon_merge {
	parameter a.
	parameter b.
	parameter mergeFunc is { parameter a, b. return a+b. }. // default sum
	for k in a:keys {
		if b:haskey(k) {
			set a[k] to mergeFunc(a[k],b[k]).
			b:remove(k).
		}
	}
	for k in b:keys {
		set a[k] to b[k].
	}
	return a.
}
