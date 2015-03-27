Strict

#rem
	Script:			ExtendedObject.monkey
	Description:	Sample script that shows how To extend the Object class 
	Author: 		Michael Hartlef
	Version:      	1.02
#End

' Set the AutoSuspend functionality to TRUE so OnResume/OnSuspend are called
#MOJO_AUTO_SUSPEND_ENABLED=True

' Import the fantomEngine framework which imports mojo itself
Import fantomEngine

' The g variable holds an instance to the game class
Global g:game


'***************************************
' This is the extended ftObject class 
Class myObject Extends ftObject
	Field mySpinSpeed:Float = -5.0
	Field xfactor:Float = 10.0
	'------------------------------------------
	Method New()
		' In its constructor, set the spin property to turn left
		Self.SetSpin(mySpinSpeed)
		
		' Deactivate the OnObjectUpdate event call as 
		' we handle things inside the classes own Update method
		Self.ActivateUpdateEvent(False)
	End
	'------------------------------------------
	Method Update:Void(speed:Float = 1.0)
		' Call the Update method of the base class 	
		Super.Update(speed)
		
		' Raise the objects scale factors
		Self.SetScale(0.01,True)
	End
End

'***************************************
' The game class controls the app
Class game Extends App
    ' Create a field to store the instance of the engine class, which is an instance
    ' of the ftEngine class itself
	Field eng:engine

	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate events to be determined by the devices refresh rate.
		SetUpdateRate(0)
		
		' Create an instance of the fantomEngine, which was created via the engine class
		eng = New engine
		
		' Create a new box object on the right side with the base ftObject class
		Local obj := eng.CreateBox(20,120,eng.GetCanvasWidth()/4*3, eng.GetCanvasHeight()/2)
		
		' Let the object spin by a factor of 10 at each Update call
		obj.SetSpin(10)
		
		' Set its speed property to 2
		obj.SetSpeed(2)
		
		' Now create another box object on the left side, but this 
		' time create the object within the method call an use the myObject class
		Local obj2 := eng.CreateBox(20,120,eng.GetCanvasWidth()/4, eng.GetCanvasHeight()/2, New myObject)
		
		' Set its speed to -2
		obj2.SetSpeed(-2)
		
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' Determine the delta time and the update factor for the engine
		Local d:Float = Float(eng.CalcDeltaTime())/60.0
		
		' Update all objects of the engine
		eng.Update(d)

		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Check if the app is not suspended
		If eng.GetPaused() = False Then
			' Clear the screen 
			Cls 
		
			' Render all visible objects of the engine
			eng.Render()
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnResume:Int()
		' Set the pause flag of the engine to FALSE so objects, timers and transitions are updated again
		eng.SetPaused(false)
		Return 0
	End
	'------------------------------------------
	Method OnSuspend:Int()
		' Set the pause flag of the engine to TRUE so objects, timers and transitions are paused (not updated)
		eng.SetPaused(True)
		Return 0
	End
End	

'***************************************
' The engine class extends the ftEngine class to override the On... methods
Class engine Extends ftEngine
	'------------------------------------------
	Method OnObjectUpdate:Int(obj:ftObject)
		' This method is called when an object finishes its update
		obj.SetPos(1,0,True)
		Return 0
	End
End

'***************************************
Function Main:Int()
	' Create an instance of the game class and store it inside the global var 'g'
	g = New game
	
	Return 0
End
