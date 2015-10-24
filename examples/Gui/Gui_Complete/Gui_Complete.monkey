Strict

#rem
	Script:			Gui_Complete.monkey
	Description:	fantomEngine sample script that shows how to use the gui objects
	Author: 		Michael Hartlef
	Version:      	1.01
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
	
	Field guiBtn:ftGuiButton = Null
	Field guiStickL:ftGuiJoystick = Null
	Field guiStickR:ftGuiJoystick = Null
	Field guiSwitch:ftGuiSwitch = Null
	Field guiSwitch2:ftGuiSwitch = Null
	Field guiMng:ftGuiMng = Null
	Field guiChkBox:ftGuiCheckbox = Null
	Field guiListview:ftGuiListview = Null
	Field guiLabel:ftGuiLabel = Null
	Field guiSlider:ftGuiSlider = Null
	Field guiSlider2:ftGuiSlider = Null
	
	Field objLeft:ftObject
	Field objRight:ftObject
	
	Field font1:ftFont

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
		Local dm := New DisplayMode
		dm = DesktopMode()
		Print("1 Width:"+dm.Width+"  Height:"+dm.Height)
		SetDeviceWindow( 1280, 800, 2 )
		dm = DesktopMode()
		Print("2 Width:"+dm.Width+"  Height:"+dm.Height)
		' Create an instance of the fantomEngine, which was created via the cEngine class
		
		Local dma := DisplayModes()
		Print (dma.Length+" display modes available")
		For Local i:= 1 To dma.Length
			Print (dma[i-1].Width+"x"+dma[i-1].Height)
		Next
		
		
		'HideMouse()
		
		fE = New cEngine
		fE.SetCanvasSize(640,480)
		
		font1 = fE.LoadFont("font_20")

		guiMng = fE.CreateGUI()
		guiMng.font1 = font1


		
		Local line1 := fE.CreateLine(0,fE.GetCanvasHeight()/2,fE.GetCanvasWidth(),fE.GetCanvasHeight()/2)

		Local line2 := fE.CreateLine(fE.GetCanvasWidth()/2,0,fE.GetCanvasWidth()/2,fE.GetCanvasHeight())

		guiStickL = guiMng.CreateJoyStick("guiJoyRing.png","guiJoyStick.png")
		guiStickL.SetPos(guiStickL.GetWidth()/2.0+20.0, fE.GetCanvasHeight()-guiStickL.GetHeight()/2.0 - 20.0)
		guiStickL.SetSmoothness(0.5)
		guiStickL.SetMaxZone(0.5)


		guiStickR = guiMng.CreateJoyStick("guiJoyRing.png","guiJoyStick.png")
		guiStickR.SetPos(fE.GetCanvasWidth()-(guiStickR.GetWidth()/2.0+20.0), fE.GetCanvasHeight()-guiStickR.GetHeight()/2.0 - 20.0)
		guiStickR.SetSmoothness(0.5)
		'guiStickR.SetMaxZone(1)
		
		guiBtn = guiMng.CreateButton("guiButton.png")
		guiBtn.SetPos(fE.GetCanvasWidth()/2, fE.GetCanvasHeight()-guiBtn.GetHeight()/2.0-20.0)
		guiBtn.SetSmoothness(0.90)
		
		guiSwitch = guiMng.CreateSwitch("guiSwitchOn.png","guiSwitchOff.png")
		guiSwitch.SetPos(fE.GetCanvasWidth()/2, fE.GetCanvasHeight()-guiSwitch.GetHeight()/2.0-140.0)
		guiSwitch.SetSmoothness(0.90)
		
		guiSwitch2 = guiMng.CreateSwitch("guiSwitchOn.png","guiSwitchOff.png", False)
		guiSwitch2.SetPos(fE.GetCanvasWidth()/2+120, fE.GetCanvasHeight()-guiSwitch2.GetHeight()/2.0-140.0)


		For x = 120 To 290 Step 40
			Local sw := guiMng.CreateSwitch("guiSwitchOn.png","guiSwitchOff.png", False)
			sw.SetPos(x, fE.GetCanvasHeight()/2-50)
			sw.SetAngle(45)
		Next 
		

		guiChkBox = guiMng.CreateCheckbox("chkBoxOn.png","chkBoxOff.png", False)
		guiChkBox.SetPos(50,80)
		
		
		guiListview = guiMng.CreateListview(fE.GetCanvasWidth()/2+100,fE.GetCanvasHeight()/2-050,150,200,LoadString("lineContent.txt"))
		guiListview.SetColor(0,100,0)

		guiLabel = guiMng.CreateLabel("TESTLABEL",True)
		guiLabel.SetPos(fE.GetCanvasWidth()/2,10)
		
		guiSlider = guiMng.CreateSlider("guiSliderBar.png","guiSliderKnob.png", -50, 100)
		guiSlider.SetPos(Int(fE.GetCanvasWidth()/2), Int(fE.GetCanvasHeight()/9.0))
		
		guiSlider2 = guiMng.CreateSlider("guiSliderBar.png","guiSliderKnob.png", -50, 100, ftGuiMng.slVertical)
		guiSlider2.SetPos(fE.GetCanvasWidth()-30, fE.GetCanvasHeight()/4.0)
		'guiSlider2.SetColGroup(9999)
		

		objLeft = fE.CreateCircle(20,guiStickL.GetPosX(), fE.GetCanvasHeight()/2.0)
		objLeft.SetWrapScreen(True)
		objRight = fE.CreateBox(40,40,guiStickR.GetPosX(), fE.GetCanvasHeight()/2.0)
		objRight.SetWrapScreen(True)
		
		
		

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
			'guiMng.Update()
			For Local index:Int = 0 To 9
				If TouchDown(index) Then fE.TouchCheck(index)
			Next
			
			
			If KeyDown(KEY_UP) Then
				fE.SetCamY(-1,True)
			Endif
			If KeyDown(KEY_DOWN) Then
				fE.SetCamY(1,True)
			Endif
			If KeyDown(KEY_RIGHT) Then
				fE.SetCamX(1,True)
			Endif
			If KeyDown(KEY_LEFT) Then
				fE.SetCamX(-1,True)
			Endif
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
			
			If guiChkBox.GetState() = True Then
				DrawText("Checked!",Int(fE.GetLocalX(guiChkBox.GetPosX())+guiChkBox.GetWidth()/2.0+10),Int(fE.GetLocalY(guiChkBox.GetPosY())))
			Else	
				DrawText("Unchecked.",fE.GetLocalX(guiChkBox.GetPosX()+guiChkBox.GetWidth()/2.0+10),fE.GetLocalY(guiChkBox.GetPosY()))
			Endif
			If guiSwitch.GetState() = True Then
				DrawText("ON",fE.GetLocalX(guiSwitch.GetPosX()),fE.GetLocalY(guiSwitch.GetPosY()+30))
			Else	
				DrawText("OFF",fE.GetLocalX(guiSwitch.GetPosX()),fE.GetLocalY(guiSwitch.GetPosY()+30))
			Endif
			If guiSwitch2.GetState() = True Then
				DrawText("ON",fE.GetLocalX(guiSwitch2.GetPosX()),fE.GetLocalY(guiSwitch2.GetPosY()+30))
			Else	
				DrawText("OFF",fE.GetLocalX(guiSwitch2.GetPosX()),fE.GetLocalY(guiSwitch2.GetPosY()+30))
			Endif
			
			DrawText(_g.guiStickR.GetJoyX(), fE.GetLocalX(20), fE.GetLocalY(fE.GetCanvasHeight()-30))
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
			Case _g.guiBtn
				_g.objLeft.SetPos(_g.guiStickL.GetPosX(), Self.GetCanvasHeight()/2.0)
				_g.objRight.SetPos(_g.guiStickR.GetPosX(), Self.GetCanvasHeight()/2.0)
				_g.guiChkBox.SetState(True)
				_g.guiSwitch.SetState(True)
				_g.guiSwitch2.SetState(True)
				_g.guiListview.SetScrollXY(0,0)
				
			Case _g.guiListview
				'_g.guiListview.SetScrollXY(0,4.0*_g.fE.GetDeltaTime()/60.0,True)
				Local index:Int = _g.guiListview.GetSelected()
				_g.guiLabel.SetText(_g.guiListview.GetItemText(index))
				
			Case _g.guiStickL
				_g.objLeft.SetPos(_g.guiStickL.GetJoyX()*timeDelta*15, _g.guiStickL.GetJoyY()*timeDelta*15, True)
				
			Case _g.guiStickR
				_g.objRight.SetPos(_g.guiStickR.GetJoyX()*timeDelta*15, _g.guiStickR.GetJoyY()*timeDelta*15, True)
			Case _g.guiSlider
				_g.guiLabel.SetText(_g.guiSlider.GetValue())
				
			Case _g.guiSlider2
				_g.guiLabel.SetText(_g.guiSlider2.GetValue())
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

