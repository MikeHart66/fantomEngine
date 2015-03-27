Strict

#rem
	Script:			LoadImage.monkey
	'Description:	Same script that shows how to load and a single image 
	Author: 		Michael Hartlef
	Version:      	1.01
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
	
	'Create a field for your object
	Field myObject:ftObject
	
	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate events to 60 FPS
		SetUpdateRate(60)
		
		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine
		
		' Now load the single image
		myObject = fE.CreateImage("cratesmall.png", 320, 240)
		
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		If KeyHit( KEY_CLOSE ) Then fE.ExitApp()
		' Determine the delta time and the update factor for the engine
		Local timeDelta:Float = Float(fE.CalcDeltaTime())/60.0

		' Update all objects of the engine
		If fE.GetPaused() = False Then
			fE.Update(timeDelta)
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Check if the engine is not paused
		If fE.GetPaused() = False Then
			' Clear the screen 
			Cls 
		
			' Render all visible objects of the engine
			fE.Render()
		Endif
		Return 0
	End
End	

'***************************************
' The cEngine class extends the ftEngine class to override the On... methods
Class cEngine Extends ftEngine
	'------------------------------------------
	Method OnObjectUpdate:Int(obj:ftObject)
		' This method is called when an object finishes its update. You can deactivate the event via ftObject.ActivateUpdateEvent.
		obj.SetAngle(1,True)
		Return 0
	End
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var 'g'
	_g = New cGame
	
	Return 0
End
