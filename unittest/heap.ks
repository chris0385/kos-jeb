
// runpath("unittest/heap.ks").
runoncepath("unittest/test.ks").
runpath("lib/heap.ks").

test("heapfill", {
	local heap is heap_init().

	heap_add(heap, 5, "5").
	heap_add(heap, 2, "2").
	heap_add(heap, 6, "6").
	heap_add(heap, 8, "8").
	heap_add(heap, 1, "1").

	local s is "".
	until heap:length = 0 {
		set s to s +","+ heap_pop(heap).
	}
	assertEquals("Heap has wrong order", ",1,2,5,6,8", s).
}).
