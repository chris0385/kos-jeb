// TODO: stage recovery + flight manager
//      Implement landing
//      Implement shutdown engine soon enough leaving fuel to land space-X style (=terminal velocity+margin) (if enough ignitions left).

// @see https://www.youtube.com/watch?v=jcjqTdMUO-k
//                         https://www.youtube.com/watch?v=sqqQy8cIVFY
//  doc/examples/space-X1  https://www.youtube.com/watch?v=xsLpwLsRZmM

//0° 05' 49'' S  74° 33' 27'' W
// 
if ADDONS:TR:AVAILABLE  {
ADDONS:TR:IMPACTPOS. // this takes into account burn node.
}