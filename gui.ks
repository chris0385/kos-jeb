

if false {
HUDTEXT( string Message,
         integer delaySeconds,
         integer style,
         integer size,
         RGBA colour,
         boolean doEcho).
         

// Also works in MAPVIEW
VECDRAW(start, vec, color, label, scale, show, width).


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
