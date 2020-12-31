#COMPILE EXE
#DIM ALL

TYPE AtcoPOINT
    x AS DOUBLE
    y AS DOUBLE
END TYPE
MACRO Pi = 3.141592653589793##
FUNCTION PBMAIN () AS LONG
DIM pointsInEllipse(0 TO 1000) AS AtcoPOINT
DIM deltaAngle AS DOUBLE
DIM circumference AS DOUBLE
DIM arcLength AS DOUBLE
DIM angle AS DOUBLE
DIM rectangleRight AS INTEGER
DIM rectangleLeft  AS INTEGER
DIM rectangleBottom AS INTEGER
DIM rectangleTop AS INTEGER
DIM numPoints AS INTEGER
DIM x AS DOUBLE
DIM y AS DOUBLE
DIM r1 AS DOUBLE
DIM r2 AS DOUBLE
numPoints = 0
deltaAngle = 0.001
rectangleRight = 100
rectangleLeft  = 0
rectangleTop   = 0
rectangleBottom = 100
circumference = GetLengthOfEllipse(deltaAngle)
arcLength = 0.1
angle = 0

FOR  numPoints = 0 TO (numPoints < circumference / arcLength) STEP 1

            angle = GetAngleForArcLengthRecursively(0, arcLength, angle, deltaAngle)
            x = r1 * COS(angle)
            y = r2 * SIN(angle)
            pointsInEllipse(numPoints).x = x
            pointsInEllipse(numPoints).y = y
NEXT numPoints
END FUNCTION

FUNCTION GetLengthOfEllipse(deltaAngle AS DOUBLE) AS DOUBLE
         DIM numIntegrals AS DOUBLE
         numIntegrals =  ROUND((Pi * 2.0/deltaAngle),10)
         DIM radiusX AS DOUBLE
         DIM radiusY AS DOUBLE
         DIM rectangleRight AS INTEGER
         DIM rectangleLeft  AS INTEGER
         DIM rectangleBottom AS INTEGER
         DIM rectangleTop AS INTEGER
         DIM length AS DOUBLE
         DIM i AS INTEGER
         rectangleRight = 100
         rectangleLeft  = 0
         rectangleTop   = 0
         rectangleBottom = 100

         radiusX = (rectangleRight - rectangleLeft) / 2
         radiusY = (rectangleBottom - rectangleTop) / 2
         length = 0.0
'        // integrate over the elipse to get the circumference
         FOR  i = 0 TO  numIntegrals-1 STEP 1
            length = length+ComputeArcOverAngle(radiusX, radiusY, i * deltaAngle, deltaAngle)
         NEXT i
         GetLengthOfEllipse = length
END FUNCTION
FUNCTION ComputeArcOverAngle(r1 AS DOUBLE, r2 AS DOUBLE, angle AS DOUBLE, angleSeg AS DOUBLE) AS DOUBLE
        DIM distance AS DOUBLE
        DIM dpt_sin AS DOUBLE
        DIM dpt_cos AS DOUBLE
        distance = 0.0
        dpt_sin = (r1*SIN(angle))^2.0
        dpt_cos = (r2*COS(angle))^2.0
        distance = SQR(dpt_sin + dpt_cos)
'        // Scale the value of distance
        ComputeArcOverAngle =  distance * angleSeg

END FUNCTION
FUNCTION GetAngleForArcLengthRecursively(currentArcPos AS DOUBLE, goalArcPos AS DOUBLE, angle AS DOUBLE, angleSeg AS DOUBLE) AS DOUBLE
         DIM nextSegLength AS DOUBLE
         DIM majorRadius AS DOUBLE
         DIM minorRadius AS DOUBLE
         DIM ARC_ACCURACY AS DOUBLE
         nextSegLength = ComputeArcOverAngle(majorRadius, minorRadius, angle + angleSeg, angleSeg)
         IF (currentArcPos + nextSegLength > goalArcPos) THEN
            GetAngleForArcLengthRecursively = GetAngleForArcLengthRecursively(currentArcPos, goalArcPos, angle, angleSeg / 2)
         ELSEIF (currentArcPos + nextSegLength) < (goalArcPos - goalArcPos - (currentArcPos * ARC_ACCURACY))THEN
             GetAngleForArcLengthRecursively = GetAngleForArcLengthRecursively(currentArcPos + nextSegLength, goalArcPos, angle + angleSeg, angleSeg)
         ELSE
           GetAngleForArcLengthRecursively = angle
         END IF
END FUNCTION
