
print ship:termvelocity.
print body:atm:ALTITUDEPRESSURE(meter).

function calcDrag {
	parameter altitude.
	parameter projectedArea.
	// depends on Reynolds number and mach number
	local dragCoefficient is 0.7.
	local massDensityAtm is body:atm:ALTITUDEPRESSURE(altitude) * 0.1. // ???
	// https://en.wikipedia.org/wiki/Drag_coefficient
	return dragCoefficient * projectedArea * velocity^2 * massDensityAtm / 2.
}
