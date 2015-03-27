Strict

#rem
	Script:			ObjectTransition.monkey
	Description:	Sample script that shows how to use transitions to transform objects
	Author: 		Michael Hartlef
	Version:      	1.04
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
	
	' Create a field for an object that we can transition
	Field myObj:ftObject
	
	' Create a field to store the transition
	Field trans:ftTrans
	
	' Create a constant for the transition ID. 
	' This will be used to identify the transition in the ftEngine.OnObjectTransition handler method.
	Const transDone:Int = 1
	
	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate events to be determined by the devices refresh rate.
		SetUpdateRate(0)
		
		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine

		' Create a box which represents the path the object will transition on
		Local tmpBox := fE.CreateBox(fE.GetCanvasWidth()-40.0,40,fE.GetCanvasWidth()/2,fE.GetCanvasHeight()/2.0)
		
		' Create the object we want to transition
		myObj = fE.CreateCircle(18, 40, fE.GetCanvasHeight()/2.0)
		' Set its color to Red
		myObj.SetColor(255,0,0)
		' Set the objects Tag value which indicates in which direction it is running
		myObj.SetTag(1)
		' Now start a transition to the other side of the canvas and store it
		trans = myObj.CreateTransPos((fE.GetCanvasWidth()-80) * myObj.GetTag(), 0, 4000 ,True, transDone)
		' Set the equation type of the transition
		trans.SetType("Bounce")
		' Set the ease type pf the transition
		trans.SetEase("EaseIn")
		' Print a little info message
		Print ("Press the <P> key to pause/resume the transition")
		
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' Determine the delta time and the update factor for the engine
		Local d:Float = Float(fE.CalcDeltaTime())/60.0

		' Update all objects of the engine
		If fE.GetPaused() = False Then
			' Check if the P key was hit
			If KeyHit(KEY_P) Then
				' If the transition is paused, resume it. Otherwise pause it.
				If trans.GetPaused()=True Then
					trans.SetPaused(False)
				Else
					trans.SetPaused(True)
				Endif
			Endif
			fE.Update(d)
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Check if the app is not suspended
		If fE.GetPaused() = False Then
			' Clear the screen 
			Cls 
		
			' Render all visible objects of the engine
			fE.Render()
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnResume:Int()
		' Set the pause flag of the engine to FALSE so objects, timers and transitions are updated again
		fE.SetPaused(false)
		
		Return 0
	End
	'------------------------------------------
	Method OnSuspend:Int()
		' Set the pause flag of the engine to TRUE so objects, timers and transitions are paused (not updated)
		fE.SetPaused(True)
		
		Return 0
	End
End	

'***************************************
' The cEngine class extends the ftEngine class to override the On... methods
Class cEngine Extends ftEngine
	'------------------------------------------
	Method OnObjectTransition:Int(transId:Int, obj:ftObject)
		' This method is called when an object finishes its transition
		If transId = _g.transDone Then
			' Negate the Tag value of the object
			obj.SetTag(obj.GetTag()*-1)
			' Start a new transtion for this object
			_g.trans = obj.CreateTransPos((_g.fE.GetCanvasWidth()-80) * obj.GetTag(), 0, 4000 ,True, _g.transDone)
			' Set the equation type of the transition
			_g.trans.SetType("Back")
			' Set the ease type pf the transition
			_g.trans.SetEase("EaseInOut")
		Endif
		Return 0
	End
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var 'g'
	_g = New cGame
	
	Return 0
End
