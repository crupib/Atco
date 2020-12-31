#COMPILE EXE
#DIM ALL


MACRO CONST = MACRO
CONST Interval = 0.001000##    '// servo cycle time in seconds


GLOBAL mincnts AS LONG         '// position travel limit
GLOBAL maxcnts AS LONG         '// position travel limit
GLOBAL maxaccel AS DOUBLE       '// max acceleration allowed
GLOBAL maxvel AS DOUBLE       '// max velocity allowed

'// persistent vars used by motion limit function
GLOBAL oldTarget AS DOUBLE     '// previous input
GLOBAL oldCntsOut AS DOUBLE    '// previous output
GLOBAL oldTargetVel AS DOUBLE      '// previous 1st derivative

GLOBAL mintravel AS LONG    '// absolute position limits -
GLOBAL maxtravel AS LONG    '// absolute position limits +
GLOBAL maxvel AS DOUBLE       '// maximum velocity allowed
GLOBAL maxaccel AS DOUBLE       '// maximum accelleration allowed

GLOBAL period_ns AS DOUBLE '// typical 1000000ns = 1ms
GLOBAL periodsec AS DOUBLE
GLOBAL enabled AS LONG      '// 0 or 1
GLOBAL deadband AS LONG    '// position error where no loop correction occurs
GLOBAL pgain AS DOUBLE     '// loop parameter that compensates for position error
GLOBAL igain AS DOUBLE     '// loop parameter that compensates for long term error
GLOBAL dgain AS DOUBLE     '// loop parameter that is used to stablize loop
GLOBAL ff1gain AS DOUBLE   '// loop parameter that compensates for motor back emf
GLOBAL ff2gain AS DOUBLE   '// loop parameter that compensates for acceleration lag


'// persistent vars used by PID calcs
GLOBAL error_i AS DOUBLE    '// cumulative integrator term
GLOBAL prev_cmd AS LONG
GLOBAL prev_cmd_d AS DOUBLE
GLOBAL prev_error AS DOUBLE
GLOBAL drive AS DOUBLE      '//current drive (-1.0 to 1.0)(not affected by enabled)
GLOBAL errcnts AS LONG      '// current posn error in motor encoder counts

GLOBAL MotorDrive_Period_us AS LONG 'PWM Freq // 3khz should be high enough
GLOBAL MotorDrive AS DOUBLE         '// set pwm pin duty cycle
GLOBAL MotorDirection AS LONG       'direction PIN
GLOBAL MotorLimit AS LONG           '// init the status outputs PIN?
GLOBAL MotorFault AS LONG           '//  "

GLOBAL MotorEncoder AS LONG

GLOBAL TargetPosn AS LONG

GLOBAL TargetCnts AS LONG


FUNCTION PBMAIN () AS LONG



    '// set up all our tuning parameters and motion limits
    period_ns = Interval / 1e-9## '// typical 1000000ns = 1ms
    enabled = 0        '// 0 or 1
    deadband = 0       '// position error where no loop correction occurs
    pgain = 1.0##      '// loop parameter that compensates for position error
    igain = 0.0##      '// loop parameter that compensates for long term error
    dgain = 0.0##      '// loop parameter that is used to stablize loop
    ff1gain = 0.0##    '// loop parameter that compensates for motor back emf
    ff2gain = 0.0##    '// loop parameter that compensates for acceleration lag

    mintravel = -10000      '// absolute position limits -
    maxtravel = 10000       '// absolute position limits +
    maxvel = 100000.0##     '// maximum velocity allowed
    maxaccel = 30000.0##    '// maximum accelleration allowed

    mincnts = mintravel
    maxcnts = maxtravel

    oldTarget = 0.0##
    oldCntsOut = 0.0##
    oldTargetVel = 0.0##

    '// calc internal variables
    periodsec = period_ns * 1e-9##    '=.001    '// usually .001 sec

    LOCAL OffsetEncoder AS LONG

    MotorEncoder =  0
    OffsetEncoder = 0

    '// init the pwm drive to motor
    MotorDrive_Period_us = 333  'PWM Freq // 3khz should be high enough
    MotorDrive = 0.0##          '// set pwm pin duty cycle
    MotorDirection = 0          'direction PIN
    MotorLimit = 0              '// init the status outputs PIN?
    MotorFault = 1              '//  "

    enabled = 1         '// turn on servo loop
    pgain = 5.0##       '// loop parameter that compensates for position error
    igain = 1.0##       '// loop parameter that compensates for long term error
    dgain = 10.0##      '// loop parameter that is used to stablize loop
    ff1gain = 1.0##     '// loop parameter that compensates for motor back emf
    ff2gain = 1.0##     '// loop parameter that compensates for acceleration lag


    'pc.baud(9600);              '// set up coms with pc via USB serial port
    'pc.format(8,SerialBase::NONED,1);

    '// Splash screen :}
    'print "\r\n\nLGSERVO demo program\r\n"

    '// attach our service routine to 1ms timer for servo calcs
    'OnemsTimer.attach_us(&mstimer, Interval / 1e-6f);

    MotorEncoder = 0
    TargetPosn = 5000
    LOCAL Ctr AS LONG
    LOCAL pause AS LONG
    LOCAL ecnts,in_Target AS LONG
    LOCAL tcnt AS LONG

    'timer

    ecnts = 10
    pause = 8
    tcnt = 0


    DO

        TargetPosn = -TargetPosn

        LOCATE 8,1: PRINT "Target Position=" + STR$(TargetPosn) + "        ";


        DO

            INCR tcnt

            IF tcnt MOD 100 THEN
                'MotorEncoder = MotorQei.getPulses()
                'OffsetEncoder = OffsetQei.getPulses()
                LOCATE 2,1: PRINT "  motor encoder =" + STR$(MotorEncoder)+"      ";
                LOCATE 3,1: PRINT " PID Err Counts =" + STR$(errcnts)     +"      ";
                LOCATE 5,1: PRINT "Motor Direction =" + STR$(MotorDirection) +"      ";
                LOCATE 6,1: PRINT "    Motor Drive =" + STR$(ROUND(MotorDrive*255&,0)) +"      ";
                tcnt = 0
            END IF

            MotorEncoder += (errcnts * MotorDrive)' * .7)

            mstimer

            IF TargetPosn <= 0 THEN    'in_Target is in negative direction
               IF MotorEncoder <= (TargetPosn+20) THEN 'errcnts) then '+20) then 'ecnts) then
                  EXIT DO
               END IF
            ELSE                      'in_Target is in positive direction
               IF MotorEncoder >= (TargetPosn-20) THEN 'errcnts) then '-20) then 'ecnts) THEN
                  EXIT DO
               END IF
            END IF



            SLEEP 10

        LOOP



    LOOP



END FUNCTION



'// function to service the 1ms ticks
'// this should be run at a low priority so encoder intr can interrupt it
SUB mstimer

    LOCAL RequiredDrive AS DOUBLE
    LOCAL smpCounts AS LONG
    MotorFault = 1

    'MotorEncoder = MotorQei.getPulses();

    smpCounts = calcNewPosn(TargetPosn)

    RequiredDrive = calcPID(MotorEncoder,smpCounts)
    IF ( RequiredDrive >= 0.0## ) THEN
       MotorDirection = 0   'positive direction
       MotorDrive = RequiredDrive
    ELSE
       MotorDirection = 1   'negative direction
       MotorDrive = -RequiredDrive
    END IF

    MotorFault = 0

END SUB


 '/**
        ' * new position calculation.
        ' * Should be called every interval ns
        ' *
        ' * @return  computes and returns a new reasonable target position
        ' * that should be reachable during the next interval
        ' * each time it is called (on a periodic basis, typically 1ms/call)
        ' * ensure positioning occurs in a controlled manner with acceleration
        ' * and max velocity contrained.
        '*/
'// Call repeatedly to calc a new motor position value for servo
'// typically every 1ms.

'// Limit the output signal to fall between min and max,
'// limit its slew rate to less than maxvel per second,
'// and limit its second derivative to less than maxaccel per second squared.
'// When the signal is a position, this means that the position, velocity,
'// and acceleration are limited.

'// this routine computes and returns a new target position each time it is called
'// (on a periodic basis, typically 1ms/call)

FUNCTION calcNewPosn(in_Target0 AS LONG) AS LONG

        LOCAL cnts_Out, newTarget_vel,in_Target, min_vel, max_vel, ramp_a, avg_v, err_0, dv_, dp_ AS DOUBLE
        LOCAL Min_CntsOut, max_CntsOut, match_time, est_in, est_out AS DOUBLE

        'est_in = est_out = match_time = 0

        '// make sure our incoming position command is within limits
        in_Target = in_Target0

        'KJL: commented out - not applicable to this application
        'IF ( in_Target < mincnts ) THEN in_Target = mincnts
        'IF ( in_Target > maxcnts ) THEN in_Target = maxcnts

        'kjl: added, would not change direction on the next commanded target after intial target is reached!
        '**************************************************************************************************
        IF in_Target < oldTarget THEN
           oldTargetVel = -ABS(oldTargetVel)  'target change, new target < old target
        ELSEIF in_Target > oldTarget THEN
           oldTargetVel = ABS(oldTargetVel)   'target change, new target > old target
        END IF
        '**************************************************************************************************

        '// calculate input derivative
        'limits the input ratio of change, to the computed change in newTarget_vel, as it approaches zero
        newTarget_vel = (in_Target - oldTarget) / periodsec   'periodsec= .001 (if set to 1kHz)

        '// determine v and out that can be reached in one period
        min_vel = oldTargetVel - maxaccel * periodsec
        IF ( min_vel < -maxvel ) THEN min_vel = -maxvel

        max_vel= oldTargetVel + maxaccel * periodsec   '.001
        IF ( max_vel > maxvel ) THEN max_vel = maxvel

        min_CntsOut = oldCntsOut + min_vel * periodsec
        max_CntsOut = oldCntsOut + max_vel * periodsec

        IF ( (in_Target >= Min_CntsOut) AND (in_Target <= max_CntsOut) AND (newTarget_vel >= min_vel) AND (newTarget_vel <= max_vel) ) THEN
           '// we can follow the command without hitting a limit
           cnts_Out= in_Target
           oldTargetVel = ( cnts_Out-oldCntsOut ) / periodsec
        ELSE
            '// can't follow commanded path while obeying limits
            '// determine which way we need to ramp to match v
            IF ( newTarget_vel > oldTargetVel ) THEN
                ramp_a = maxaccel
            ELSE
                ramp_a = -maxaccel
            END IF

            '// determine how long the match would take
            match_time = ( newTarget_vel - oldTargetVel ) / ramp_a
            '// where we will be at the end of the match
            avg_v = ( newTarget_vel + oldTargetVel + ramp_a * periodsec) * 0.500##
            est_out = oldCntsOut + avg_v * match_time
            '// calculate the expected command position at that time
            est_in = oldTarget + newTarget_vel * match_time
            '// calculate position error at that time
            err_0 = est_out - est_in
            '// calculate change in final position if we ramp in the opposite direction for one period
            dv_ = -2.0 * ramp_a * periodsec
            dp_ = dv_ * match_time

            '// decide what to do
            IF ( ABS(err_0+dp_*2.0##) < ABS(err_0) ) THEN ramp_a = -ramp_a

            IF ( ramp_a < 0.0## ) THEN
                cnts_Out= min_CntsOut
                oldTargetVel = min_vel
            ELSE
                cnts_Out= max_CntsOut
                oldTargetVel = max_vel
            END IF

        END IF

        oldCntsOut = cnts_Out
        oldTarget = in_Target

        FUNCTION = CLNG(cnts_Out)

END FUNCTION

' * This library contains the code for a smart servo positioning loop.
' * The loop is tuned using quite traditional PID plus 2 feed forward
' * terms. The library also implements a trapazodal motion profile.
' * This motion profile is tuned with max velocity and acceleration
' * parameters. This allows for nicely controlled motion when giving the
' * loop a Target position. It still allows for an external motion profile
' * planner to drip feed positions to this library on a regular interval,
' * with the bonus of large steps in position being handled in a nicely
' * controlled manner.


'// Call repeatedly to calc a new motor drive value for selected servo
'// typically every 1ms.
'// Returns a float representing the motor drive required.
'// -100.0 <= drive <= +100.0
'// Note: due to static vars used to hold data between calls, this function
'// is NOT thread safe.
'//
FUNCTION calcPID(actual_posn AS LONG, cmd_posn AS LONG) AS DOUBLE

        LOCAL tmp1 AS DOUBLE
        LOCAL max_i AS DOUBLE
        LOCAL error_d AS DOUBLE  '// derivative term
        LOCAL cmd_d AS DOUBLE    '// cycle by cycle delta posncmd = commanded velocity
        LOCAL cmd_dd AS DOUBLE   '// cycle by cycle delta velocity = commanded accel

        '// calculate the error
        errcnts = cmd_posn - actual_posn   '// posn err in encoder cnts

        '// apply the deadband
        IF (errcnts > deadband) THEN
            errcnts -= deadband
        ELSEIF (errcnts < -deadband) THEN
            errcnts += deadband
        ELSE
            errcnts = 0
        END IF

        tmp1 = errcnts              '// position error in floating point counts

        '// do integrator calcs only if enabled
        IF ((igain > 0) AND (enabled <> 0)) THEN
           '// update integral term
            error_i += tmp1 * periodsec  '// scale so it builds slowly (integer igain can be higher)

            '// apply a fixed integrator limit of 25% drive(could be made tunable)
            max_i = 25.0## / igain
            IF (error_i > max_i) THEN
                error_i = max_i
            ELSEIF (error_i < -max_i) THEN
                error_i = -max_i
            END IF
        ELSE
           '// not enabled, reset integrator
            error_i = 0.0##
        END IF

        '/* calculate derivative term */
        error_d = (tmp1 - prev_error)
        prev_error = tmp1

        '/* calculate derivative of commanded posn = velocity ( used with ff1 tuning param ) */
        cmd_d = (cmd_posn - prev_cmd)
        prev_cmd = cmd_posn

        '/* calculate derivative of velocity = accel (used with ff2 tuning param) */
        cmd_dd = cmd_d - prev_cmd_d
        prev_cmd_d = cmd_d

        '// calculate the output value by summing drive components
        '// because gain components are ints, not fp,   KJL - INT? looks like all fp to me?
        '// we use some scaling to improve tuning ease
        'KJL:  replaced divide with multiply for less overhead
        tmp1 =  pgain * tmp1 * 0.001##     '/ 1000.0##  '// position error component
        tmp1 += igain * error_i * 0.001##  '/ 1000.0##  '// integral error component
        tmp1 += dgain * error_d * 0.001##  '/ 1000.0##  '// differential component
        tmp1 += ff1gain * cmd_d * 0.001##  '/ 1000.0##  '// velocity feed forward component
        tmp1 += ff2gain * cmd_dd * 0.001## '/ 1000.0##  '// acceleration feed forward component

        drive = tmp1

        '// limit drive to max on time of pwm waveform
        IF (drive > 1.0##) THEN
            drive = 1.0##
        ELSEIF (drive < -1.0##) THEN
            drive = -1.0##
        END IF

        IF (enabled) THEN
            FUNCTION = drive  '//  return drive;
        ELSE
            FUNCTION = 0.0##   '// shut off drive for disabled axis
        END IF

END FUNCTION
