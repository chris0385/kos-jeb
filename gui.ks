

if false {
HUDTEXT( string Message,
         integer delaySeconds,
         integer style,
         integer size,
         RGBA colour,
         boolean doEcho).
         

// Also works in MAPVIEW
VECDRAW(start, vec, color, label, scale, show, width).

clearvecdraws().
set a to VECDRAW(V(0,0,0), LATLNG(-0.096944, -74.5575):POSITION, red, "ksc", 1, true, 1).
until false {
	set a:vec to LATLNG(-0.096944, -74.5575):POSITION.
}


LOCAL gui IS GUI(200).
// Add widgets to the GUI
LOCAL label IS gui:ADDLABEL("Hello world!").
SET label:STYLE:ALIGN TO "CENTER".
SET label:STYLE:HSTRETCH TO True. // Fill horizontally
LOCAL ok TO gui:ADDBUTTON("OK").
// Show the GUI.
gui:SHOW().

set ok:ONCLICK to { print "Ok clicked". }.
}
