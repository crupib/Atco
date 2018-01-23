EZGUI 5.1 Beta update information:
==================================

11/10/2013

%EZ_AfterSize event added

This event occurs when the Canvas control gets the %EZ_Size event. The Canvas control recreates its image buffers after %EZ_Size, not before, so you need to be able to have an event after the control does this, so you can redraw the image buffer using the new size. This event occurs after %EZ_Size has been processed.

11/9/2013

Added new feature to EZ_HHelp command.

If HType$ equals the following:

"W"

"WEB"

EZGUI will not expect an HTML Help file, but instead will display an HTML web page or web site using the default web browser.

You can define a form for a parent and if no form is defined ("") then EZGUI will maximize the web browser to full screen. The HFile$ parameter must be a null string, since no HTML help file is being used.

The HData$ parameter is used to define either a local web page on the harddrive or a web page on the internet.

A local web page would be defined like this:

"c:\somefolder\mywebpage.html"

A web page on the internet would be defined like this:

"http://mywebsite.com"

or

"http://mywebsite.com/mywebpage.html"



10/15/2013


Updated Designer with following:

- Cancel added to Save Form dialog
- Apply changed to OK on dialogs
- OK and Cancel button positions changed on dialogs

Bug Fix - Resource leak with form tooltips on page forms

Bug Fix - EZ_Handle failed to return desktop handle for "" parameter

Designer: Added Progressbar when generating code

New Commands:

*************************************************
   EZ_SetTouch FormName$, IDNum&, TouchProp$
*************************************************

	TouchProp$ is a touch property string defined as follows:

First part must be a Type macro such as:

{T} for TOUCH support (generates new %EZ_Touch event)
{G} for GESTURE support (generates new %EZ_Gesture event)
{M} no gestures, but modify mouse actions for touch for certain controls

For Gesture ( {G} ) use the following to define the gesture features:

Z - Support Zoom
P - support Pan
1 - if P used support 1 finger Pan rather than two finger
I - if P used support Inertia for panning
R - support rotate
T - support Press and Tap
T2 - support two finger tap

Rather than define each gesture you can use the property:

A - support all gestures

If no properties define for Getsures, then no Gestures supported.

For Touch ( {T} ) use the following to define touch features:

U - Unregister Touch if currently enabled

F - support Fine Touch
P - support Palm Touch (can't be used with F property)

If TProp$ = "" then touch mode is turned off and gesture mode is not processed, but left active. This is normal mode.

If TProp$="{X}" then touch mode is turned off and gesture mode is turned off.

If you want the event forwarded to the controls parent form instead of to the control,
you can add the > property which tells EZGUI to forward the event.

********************************************************************************
EZ_GetTouch  CVal&, TPCount&, TPID()AS DWORD, TPX() AS LONG, TPY() AS LONG, TPFlag() AS DWORD 
********************************************************************************

Use during %EZ_Touch event and get data

********************************************************************************
EZ_GetGesture CVal&, GType&, GBegin&, GEnd&, GInertia&, GPar1&, GPar2&, GX&, GY&
********************************************************************************

This command is only to be called during the %EZ_Gesture event. You must pass the events CVal& parameter unchanged.

The rest of the parameters are for return values:

GType& returns the type of gesture, which will be one of the following constants:

%EZ_GZoom      =    3&
%EZ_GPan       =    4&
%EZ_GRotate    =    5&
%EZ_GTwoTap    =    6&
%EZ_GPressTap  =    7&

GBegin returns a non-zero value if this is the beginning of the gesture
GEnd&  returns a non-zero value if this is the end of the gesture
GInertia&  returns a non-zero value if this gesture has inertia

For the %EZ_GPan type gesture the parameters GPar1& and GPar2& return two values which
are the inertia vectors

For the %EZ_GTwoTap gesture the parameter GPar1& returns the distance between the two touch points

GX& and GY& are the coordinates of the touch points










