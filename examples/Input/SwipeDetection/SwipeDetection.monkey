Strict

#rem
	Script:			SwipeDetection.monkey
	Description:	Example script on how To use ther swipe detection And its OnSwipeDone event
	Author: 		Michael Hartlef
	Version:      	1.05
#End

' Set the AutoSuspend functionality to TRUE so OnResume/OnSuspend are called
#MOJO_AUTO_SUSPEND_ENABLED=True

' Import the fantomEngine framework which imports mojo itself
Import fantomEngine

' The _g variable holds an instance to the cGame class
Global _g:cGame

'***************************************
' The cGame class controls the app
Class cGame Extends App
	' Create a field to store the instance of the cEngine class, which is an instance
	' of the ftEngine class itself
	Field fE:cEngine
	
	Field compass:ftObject
	Field needle:ftObject
	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate to 60 FPS.
		SetUpdateRate(60)
		
		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine

		'Load the images of the needle and the compass
		compass = fE.CreateImage("compass.png", fE.GetCanvasWidth()/2, fE.GetCanvasHeight()/2)
		needle = fE.CreateImage("needle.png", fE.GetCanvasWidth()/2, fE.GetCanvasHeight()/2)

		'Activate the swipe detection
		fE.ActivateSwipe(True)
		
		'Set the dead distance to 50 pixel. Swipes are only detected if they have a length greater in pixel greater this
		fE.SetSwipeDeadDist(50)
		
		'Set the swipe angle snapping to 45 degrees. This will snap the needle to 0,45,90,135,180,225,270 and 315 degrees
		fE.SetSwipeSnap(45)
		'If you just wanna get 0,90,180,270 degrees, you would need to snap it to 90 degrees
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		'Get the current delta time and determine the speed factor for the next update call
		Local d:Float = Float(fE.CalcDeltaTime())/60.0
		
		'Update the engine
		fE.Update(Float(d))
		
		'Update the swipe detection
		fE.SwipeUpdate(0)
		
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		'Clear the screen with a nice blue color
		Cls 0,0,255
		
		'Render all objects of the engine
		fE.Render()

		'Draw the current FramesPerSecond value
		DrawText("FPS:"+fE.GetFPS(),10,10)

		Return 0
	End
End	

'***************************************
' The cEngine class extends the ftEngine class to override the On... methods
Class cEngine Extends ftEngine
	'------------------------------------------
	'This method is called when a swipe was detected. You will get the angle, the distance and the speed value with is the factor of distance/time.
	Method OnSwipeDone:Int(touchIndex:Int, sAngle:Float, sDist:Float, sSpeed:Float)
		Print ("Distance:" +Int(sDist))
		'Calculate the angle difference between the swipe and the needle
		Local angleDiff:Float = sAngle - _g.needle.GetAngle()
		
		'Determine which direction the needle has to turn
		If angleDiff > 180.0 Then angleDiff = angleDiff -360.0
		If angleDiff < -180.0 Then angleDiff = angleDiff +360.0
		
		'Cancel the current transition of the needle, if there is one
		_g.needle.CancelTransAll()
		
		'Start a new rotation transition
		_g.needle.CreateTransRot(angleDiff, 500*Abs(angleDiff/45), True, 0 )

		Return 0
	End	
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var 'g'
	_g = New cGame
	Return 0
End
