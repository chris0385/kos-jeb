
@lazyglobal off.

if false {
   //HUDTEXT( string Message,
   //         integer delaySeconds,
   //         integer style,
   //         integer size,
   //         RGBA colour,
   //         boolean doEcho).
   
   HUDTEXT("Test message", 2, 1, 10, RED, true). wait 0. HUDTEXT("Test mesdgssage", 2, 1, 10, GREEN, true).
            

   // Also works in MAPVIEW
   VECDRAW(start, vec, color, label, scale, show, width).

   clearvecdraws().
   set a to VECDRAW(V(0,0,0), LATLNG(-0.096944, -74.5575):POSITION, red, "ksc", 1, true, 1).
   until false {
      set a:vec to LATLNG(-0.096944, -74.5575):POSITION.
   }
}

function debug_printStyle {
   parameter style.
   print "margin-V:" + style:margin:V.
   print "padding-V:" + style:padding:V.
   print "border-V:" + style:border:V.
}

function zeroStyleV {
   // NOTE: you may use GUI:SKIN
   parameter widget.
   local style is widget:style.
   set style:margin:V to 0.
   set style:padding:V to 0.
   set style:border:V to 0.
   return widget.
}

function infoBuilder {
   LOCAL gui IS GUI(200).
   local labelList is list().
   local textCallbacks is list().
   local active is true.
   
   gui:show(). 
   
   local tick is 0.
   when active then {
      set tick to tick + 1.
      if mod(tick, 10) = 0 {
         local itLabel is labelList:iterator.
         local itCallback is textCallbacks:iterator.
         until not itLabel:NEXT {
            itCallback:NEXT.
            set itLabel:VALUE:TEXT to itCallback:VALUE:CALL().
         }
      }
      preserve.
   }
   
   return   {
      parameter label.
      parameter textCallback is { return "MISSING PARAMETER". }.
      parameter format is "$$".
      if label = false {
         set active to false.
         gui:dispose().
         return.
      }
      if label = "" {
         gui:ADDSPACING(3).
         return.
      }
      if format <> "$$" and format {
         local b is textCallback.
         set textCallback to {
            return format:replace("$$", b()).
         }.
      }
      local horLayout is gui:ADDHLAYOUT().

      local tmp is horLayout:addlabel(label).
      zeroStyleV(tmp).
      set tmp:style:fontsize to 9.
      textCallbacks:add(textCallback).
      set tmp to horLayout:addlabel(textCallback()).
      set tmp:style:align to "right".
      zeroStyleV(tmp).
      set tmp:style:fontsize to 9.
      labelList:add(tmp).
   }.
}

if FALSE {
   CLEARGUIS().
   planeInfo().
   until 0 { wait 1. }
}

if false {
   CLEARGUIS().

   LOCAL gui IS GUI(200).
   // Add widgets to the GUI
   LOCAL label IS gui:ADDLABEL("Hello <size=10>small</size> world!\n new line").
   SET label:STYLE:ALIGN TO "CENTER".
   SET label:STYLE:HSTRETCH TO True. // Fill horizontally
   //SET label:STYLE:font to "Liberation Sans".
   SET label:STYLE:font to "Arial".
   
   //SET label:tooltip to "test tooltip".
   
   LOCAL text IS gui:ADDTEXTFIELD("Hello <size=10>small</size> world new line").
   
   LOCAL ok TO gui:ADDBUTTON("OK").
   set ok:style:FONTSIZE to 5.
   // Show the GUI.
   gui:SHOW().

   set ok:ONCLICK to { print "Ok clicked". gui:dispose(). }.
   
}
