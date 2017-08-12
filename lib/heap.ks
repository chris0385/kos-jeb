@lazyglobal off.

// min heap
function heap_init {
	return list().
}

function heap_add {
	parameter heap.
	parameter key.
	parameter data.
	
	local ent is list(key,data).
	local minIdx is 0.
	local maxIdx is heap:length.
	if maxIdx = -1 {
		set maxIdx to 0.
	}
	until minIdx = maxIdx {
		local mid is floor((minIdx+maxIdx)/2).
		if key = heap[mid][0] {
			set minIdx to mid. 
			break.
		} else if key > heap[mid][0] {
			set minIdx to mid+1.
		} else if key < heap[mid][0] {
			set maxIdx to mid.
		}
	}
	if minIdx = heap:length {
		heap:add(ent).
	} else {
		heap:insert(minIdx, ent).
	}
}

function heap_peek {
	parameter heap.
	return heap[0][1].
}

function heap_pop {
	parameter heap.
	local ent is heap[0].
	heap:remove(0).
	return ent[1].
}