#COMPILE EXE
#DIM ALL
TYPE POINT
    x AS LONG
    y AS LONG
END TYPE

FUNCTION PBMAIN () AS LONG
DIM pointsInEllipse(0 TO 1000) AS POINT
DIM deltaAngle AS DOUBLE
DIM circumference AS DOUBLE
DIM arcLength AS DOUBLE
DIM angle AS DOUBLE

deltaAngle = 0.001
circumference = GetLengthOfEllipse(deltaAngle)
arcLength = 0.1
angle = 0

END FUNCTION

FUNCTION GetLengthOfEllipse(deltaAngle AS DOUBLE) AS DOUBLE
END FUNCTION

'void main()
'    {
'        List<Point> pointsInEllipse = new List<Point>();
''
'        // Distance in radians between angles measured on the ellipse
'        double deltaAngle = 0.001;
'        double circumference = GetLengthOfEllipse(deltaAngle);
'
'        double arcLength = 0.1;
'
'        double angle = 0;

'        // Loop until we get all the points out of the ellipse
'        for (int numPoints = 0; numPoints < circumference / arcLength; numPoints++)
'        {
'            angle = GetAngleForArcLengthRecursively(0, arcLength, angle, deltaAngle);
'
'            double x = r1 * Math.Cos(angle);
'            double y = r2 * Math.Sin(angle);
'            points.Add(new Point(x, y));
'        }
'    }

'    private double GetLengthOfEllipse()
'    {
'        // Distance in radians between angles
'        double deltaAngle = 0.001;
'        double numIntegrals = Math.Round(Math.PI * 2.0 / deltaAngle);

'        double radiusX = (rectangleRight - rectangleLeft) / 2;
'        double radiusY = (rectangleBottom - rectangleTop) / 2;

'        // integrate over the elipse to get the circumference
'        for (int i = 0; i < numIntegrals; i++)
'        {
'            length += ComputeArcOverAngle(radiusX, radiusY, i * deltaAngle, deltaAngle);
'        }

'        return length;
'    }

'    private double GetAngleForArcLengthRecursively(double currentArcPos, double goalArcPos, double angle, double angleSeg)
'    {

'        // Calculate arc length at new angle
'        double nextSegLength = ComputeArcOverAngle(majorRadius, minorRadius, angle + angleSeg, angleSeg);

'        // If we've overshot, reduce the delta angle and try again
'        if (currentArcPos + nextSegLength > goalArcPos) {
'            return GetAngleForArcLengthRecursively(currentArcPos, goalArcPos, angle, angleSeg / 2);

'            // We're below the our goal value but not in range (
'        } else if (currentArcPos + nextSegLength < goalArcPos - ((goalArcPos - currentArcPos) * ARC_ACCURACY)) {
'            return GetAngleForArcLengthRecursively(currentArcPos + nextSegLength, goalArcPos, angle + angleSeg, angleSeg);

'            // current arc length is in range (within error), so return the angle
'        } else
'            return angle;
'   }

'    private double ComputeArcOverAngle(double r1, double r2, double angle, double angleSeg)
'    {
'        double distance = 0.0;

'        double dpt_sin = Math.Pow(r1 * Math.Sin(angle), 2.0);
'        double dpt_cos = Math.Pow(r2 * Math.Cos(angle), 2.0);
'        distance = Math.Sqrt(dpt_sin + dpt_cos);

'        // Scale the value of distance
'        return distance * angleSeg;
'    }
