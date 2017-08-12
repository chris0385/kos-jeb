@lazyglobal off.
local __TEST_CONTEXT is lexicon("testname","", "failed", 0).

function __assertMessage {
	parameter m is "#DUMMY#".
	local mes is "[ASSERT FAILED in "+__TEST_CONTEXT["testname"]+"] ".
	if m = "#DUMMY#" {
		return mes.
	}
	return mes+m.
}

function fail {
	parameter mes.
	print mes.
	set __TEST_CONTEXT["failed"] to __TEST_CONTEXT["failed"]+1.
	err.
}

function assert {
	parameter m.
	parameter t is "#".
	
	if t = "#" {
		if not m {
			fail(__assertMessage).
		}
	} else {
		if not t {
			fail(__assertMessage+m).
		}
	}
}

function assertEquals {
	parameter m.
	parameter expected.
	parameter actual is "#DUMMY".
	if actual="#DUMMY" {
		if m<>expected {
			fail(__assertMessage+"expected ["+m+"] but was ["+expected+"]").
		}
	} else {
		if expected<>actual {
			fail(__assertMessage+"expected ["+expected+"] but was ["+actual+"]").
		}
	}
}

function test {
	parameter name.
	parameter callable.
	set __TEST_CONTEXT["testname"] to name.
	callable().
	set __TEST_CONTEXT["testname"] to "".
}

