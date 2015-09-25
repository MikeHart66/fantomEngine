Strict

#rem
	Script:			Checkbox.monkey
	Description:	fantomEngine sample script that shows how to use the custom gui checkbox object
	Author: 		Michael Hartlef
	Version:      	1.0
#End

' Set the AutoSuspend functionality to TRUE so OnResume/OnSuspend are called
#MOJO_AUTO_SUSPEND_ENABLED=True
#MOJO_IMAGE_FILTERING_ENABLED=FALSE

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
	
	Field guiMng:ftGuiMng = Null
	Field guiChkBox:ftGuiCheckbox = Null
	
	Field chkbState:String ="CHECKED!"

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
	
		Local x:Float
		Local y:Float
		
		' Set the update rate to the maximum FPS of the device
		SetUpdateRate(60)


		
		fE = New cEngine
		fE.SetCanvasSize(640,480)
		
		guiMng = fE.CreateGUI()
		
		guiChkBox = guiMng.CreateCheckbox("chkBoxOn.png","chkBoxOff.png", False)
		guiChkBox.SetPos(50,80)
		guiChkBox.SetState(True)
		
		

		' Get the default scene of the engine
		defScene = fE.GetDefaultScene()

		' Get the default layer of the engine
		defLayer = fE.GetDefaultLayer()
		'defLayer.SetAlpha(0.8)

		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' If the CLOSE key was hit, exit the app ... needed for GLFW and Android I think. 
		If KeyHit( KEY_ESCAPE ) Then fE.ExitApp()
		
		' Determine the delta time and the update factor for the engine
		Local timeDelta:Float = Float(fE.CalcDeltaTime())/60.0

		' Update all objects of the engine
		If fE.GetPaused() = False Then
			fE.Update(timeDelta)
			' Do a touch check for the first 4 fingers
			For Local index:Int = 0 To 3
				If TouchDown(index) Then fE.TouchCheck(index)
			Next
		Endif
		
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Check if the engine is not paused
		If fE.GetPaused() = False Then
			' Clear the screen 
			Cls 200,0,0
			' Render all visible objects of the engine
			fE.Render()
			
			SetAlpha(1.0)
			' Draw the current FramesPerSecond value to the canvas
			DrawText("FPS: "+fE.GetFPS(), Int(fE.GetLocalX(20)),Int(fE.GetLocalY(10)))
			
			DrawText(chkbState,Int(fE.GetLocalX(guiChkBox.GetPosX())+guiChkBox.GetWidth()/2.0+10),Int(fE.GetLocalY(guiChkBox.GetPosY())))
			fE.RestoreAlpha()
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
	'------------------------------------------
	Method OnObjectTouch:Int(obj:ftObject, touchId:Int)
		' This method is called when an object was touched
		Local timeDelta:Float = Float(Self.GetDeltaTime())/60.0
		Select obj 
			Case _g.guiChkBox
				If _g.guiChkBox.GetState()=True
					_g.chkbState = "Checked!"
				Else
					_g.chkbState = "UnChecked!"
				Endif
		End
		Return True
	End
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var 'g'
	_g = New cGame
	
	Return 0
End

