Strict

#rem
	Script:			VirtualResolution.monkey
	Description:	A sample script to show how to deal with a virtual canvas size/resolution
	Author: 		Michael Hartlef
	Version:      	1.01
#End

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
	
	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate to 60 FPS.
		SetUpdateRate(60)
		
		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine
		
		' Now set the virtual fixed resolution. We use LetterBox scaling.
		fE.SetCanvasSize(960, 640, ftEngine.cmLetterbox)
		
		' Lastly create a yellow box of the size of the virtual canvas and center it so it will cover the whole virtual canvas
		Local box := fE.CreateBox(960, 640, fE.GetCanvasWidth()/2.0, fE.GetCanvasHeight()/2.0)
		box.SetColor(255,255,0)


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
		' Create 2 variables that store local coordinates
		Local lX:Int
		Local lY:Int
		
		' For the upcomming drawing call we need to calculate the real (local) coordinates from our world (virtual) coordinates
		lX = fE.GetLocalX(20)
		lY = fE.GetLocalY(20)
			
		' Check if the engine is not paused
		If fE.GetPaused() = False Then
			' Clear the screen to a bright RED
			Cls 255,0,0
		
			' Render all visible objects of the engine
			fE.Render()
			
			' Now draw the current FPS value in the top left corner of the canvas
			DrawText( "FPS= "+fE.GetFPS(), lX, lY)
		Else
			' Clear the screen to a bright BLUE
			Cls 0,0,255
		
		
			' Now draw the a PAUSE message the top left corner of the canvas
			DrawText( "**** Game is paused ****", lX, lY)
			
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnResume:Int()
		' Set the pause flag of the engine to FALSE so objects, timers and transitions are updated again
		fE.SetPaused(False)
		
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
	' nothing happens here
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var 'g'
	_g = New cGame
	
	Return 0
End

