Strict

#rem
	Script:			Timer.monkey
	Description:	Sample script to show how to use timer
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

	' Define two constants for timer IDs	
	Const engineTimer:Int = 1
	Const objectTimer:Int = 2
	
	
	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate to 60 FPS.
		SetUpdateRate(60)
		
		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine
	
		' Create a timer without a connection to an object which creates new circles at every second
		fE.CreateTimer(engineTimer, 500, -1)
		

		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' If the CLOSE key was hit, exit the app ... needed for GLFW and Android I think. 
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
			Cls 255,0,0
		
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
	Method OnObjectTimer:Int(timerId:Int, obj:ftObject)
		' This method is called when an objects' timer was being fired.
		If timerId = _g.objectTimer
			obj.Remove()
		Endif
		Return 0
	End	

    '------------------------------------------
	Method OnTimer:Int(timerId:Int)
		' This method is called when an engine timer was being fired.
		If timerId = _g.engineTimer
			' Create a simple circle
			Local circle := self.CreateCircle(20,Rnd(self.GetCanvasWidth()),Rnd(self.GetCanvasHeight()))

			' Two ways to create an object bound timer
			' circle.CreateTimer(_g.objectTimer, 1500)
			self.CreateObjTimer(circle, _g.objectTimer, 1500)
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