Strict

#rem
	Script:			Joysticks.monkey
	Description:	fantomEngine sample script that shows how to use the custom gui joystick object 
	Author: 		Michael Hartlef
	Version:      	1.0
#End

' Set the AutoSuspend functionality to TRUE so OnResume/OnSuspend are called
#MOJO_AUTO_SUSPEND_ENABLED=True
#MOJO_IMAGE_FILTERING_ENABLED=TRUE

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
	
	Field guiStickL:ftGuiJoystick = Null
	Field guiStickR:ftGuiJoystick = Null
	
	Field guiMng:ftGuiMng = Null
	
	Field objLeft:ftObject
	Field objRight:ftObject
	
	Field font1:ftFont

	'------------------------------------------
	Method CreateJoystick:ftGuiJoystick(guiM:ftGuiMng, imgRing:String, imgStick:String, xPos:Float, yPos:Float, smoothFactor:Float = 0.9, maxZone:Float = 1.0)
		Local js := guiM.CreateJoyStick(imgRing, imgStick)
		js.SetPos(xPos, yPos)
		js.SetSmoothness(smoothFactor)
		js.SetMaxZone(maxZone)
		Return js
	End
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
		SetUpdateRate(0)
		
		fE = New cEngine
		fE.SetCanvasSize(640,480)
		
		font1 = fE.LoadFont("font_20")

		guiMng = fE.CreateGUI()
		guiMng.font1 = font1

		guiStickL = CreateJoystick(guiMng, "guiJoyRing.png", "guiJoyStick.png", 100, fE.GetCanvasHeight()-100, 0.5, 0.5) 
		
		guiStickR = CreateJoystick(guiMng, "guiJoyRing.png", "guiJoyStick.png", fE.GetCanvasWidth() - 100, fE.GetCanvasHeight()-100, 0.5) 
		
		objLeft = fE.CreateCircle(20,guiStickL.GetPosX(), fE.GetCanvasHeight()/2.0)
		objLeft.SetWrapScreen(True)
		objLeft.SetName("CIRCLE")
		
		objRight = fE.CreateBox(40,40,guiStickR.GetPosX(), fE.GetCanvasHeight()/2.0)
		objRight.SetWrapScreen(True)
		objRight.SetName("BOX")
		
		
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
			For Local index:Int = 0 To 3
				If TouchDown(index) Then fE.TouchCheck(index)
			Next
			fE.Update(timeDelta)
			
		Endif
		
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Check if the engine is not paused
		Local a:Bool = True
		If fE.GetPaused() = False Then
			' Clear the screen 
			Cls 200,0,0
			' Render all visible objects of the engine
			fE.Render()
			' Draw the current FramesPerSecond value to the canvas
			DrawText("FPS: "+fE.GetFPS(), Int(fE.GetLocalX(20)),Int(fE.GetLocalY(10)))
			
			DrawText(_g.guiStickL.GetJoyX(), fE.GetLocalX(20), fE.GetLocalY(fE.GetCanvasHeight()-40))
			DrawText(_g.guiStickL.GetJoyY(), fE.GetLocalX(20), fE.GetLocalY(fE.GetCanvasHeight()-30))
			DrawText(_g.guiStickR.GetJoyX(), fE.GetLocalX(fE.GetCanvasWidth()-40), fE.GetLocalY(fE.GetCanvasHeight()-40))
			DrawText(_g.guiStickR.GetJoyY(), fE.GetLocalX(fE.GetCanvasWidth()-40), fE.GetLocalY(fE.GetCanvasHeight()-30))

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
			Case _g.guiStickL
				_g.objLeft.SetPos(_g.guiStickL.GetJoyX()*timeDelta*15, _g.guiStickL.GetJoyY()*timeDelta*15, True)
			Case _g.guiStickR
				_g.objRight.SetPos(_g.guiStickR.GetJoyX()*timeDelta*15, _g.guiStickR.GetJoyY()*timeDelta*15, True)
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

