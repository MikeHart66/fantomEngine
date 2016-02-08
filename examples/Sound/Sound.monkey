Strict

#rem
	Script:			Sound.monkey
	Description:	Sample script to show how to use sounds and mousic in fantomEngine
	Author: 		Michael Hartlef
	Version:      	1.0
#End

' Set the AutoSuspend functionality to TRUE so OnResume/OnSuspend are called
#MOJO_AUTO_SUSPEND_ENABLED=True

'Set to false to disable webaudio support for mojo audio, and to use older multimedia audio system instead.
#HTML5_WEBAUDIO_ENABLED=True

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
	
	' Create a field for the default scene and layer of the engine
	Field defLayer:ftLayer
	Field defScene:ftScene
	' Create two fields to store the sound and music instance
	Field mySound:ftSound
	Field myMusic:ftSound
	'------------------------------------------
	Method OnClose:Int()
		fE.ExitApp()
		Return 0
	End
	'------------------------------------------
	Method OnBack:Int()
		Return 0
	End
	'------------------------------------------
	Method OnCreate:Int()
		' Create an instance of the fantomX, which was created via the cEngine class
		fE = New cEngine
		
		' Get the default scene of the engine
		defScene = fE.GetDefaultScene()

		' Get the default layer of the engine
		defLayer = fE.GetDefaultLayer()
		
		' Create a simple box
		Local box := fE.CreateBox(30,5,fE.GetCanvasWidth()-40,fE.GetCanvasHeight()-40)
		
		' Set color of the box to a nice yellow
		box.SetColor(255,255,0)
		
		' Let the box spin
		box.SetSpin(5)
		
		' Load a sound file
		mySound = fE.LoadSound("shoot.wav")
		
		' Load a music file looping right from the start
		myMusic = fE.LoadMusic("happy.mp3", True)
		
		If myMusic <> Null Then myMusic.Play()
		
		' Set the highest sound channel to be used
		fE.SetMaxSoundChannel(4)

		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' If the CLOSE key was hit, exit the app ... needed for GLFW and Android I think. 
		If KeyHit( KEY_CLOSE ) Then fE.ExitApp()
		
		' Determine the delta time and the update factor for the engine
		Local timeDelta:Float = Float(fE.CalcDeltaTime())/60.0

		' Check if the engine is not paused
		If fE.GetPaused() = False Then
			' Update all objects of the engine
			fE.Update(timeDelta)
			' Check the S key to play a sound
			If KeyHit(KEY_S) Then mySound.Play()
			' Check the P key to (un)pause the music file
			If KeyHit(KEY_P)
				If myMusic.GetPaused() = True
					myMusic.SetPaused(False)
				Else
					myMusic.SetPaused(True)
				Endif
			Endif
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Check if the engine is not paused
		If fE.GetPaused() = False Then
			' Clear the screen 
			Cls( 0,100,0)
		
			' Render all visible objects of the engine
			fE.Render()

			' Now draw the current FPS value to the screen
			SetColor(255, 255, 0)
			DrawText( "FPS= "+fE.GetFPS(),fE.GetLocalX(10), fE.GetLocalY(10))
			' Draw the instructions to the screen
			DrawText( "Press the -S- key to hear a sound", fE.GetLocalX(10), fE.GetLocalY(30))
			DrawText( "Press the -P- key to (un)pause the music file", fE.GetLocalX(10), fE.GetLocalY(45))
		Else
			DrawText("**** PAUSED ****",fE.GetLocalX(fE.GetCanvasWidth()/2.0),fE.GetLocalY(fE.GetCanvasHeight()/2.0),0.5, 0.5)
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnLoading:Int()
		' If loading of assets in OnCreate takes longer, render a simple loading screen
		fE.RenderLoadingBar()
		
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
	' No event was missued in this example :-)
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var '_g'
	_g = New cGame
	
	Return 0
End

