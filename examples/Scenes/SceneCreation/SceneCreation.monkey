Strict

#rem
	Script:			SceneCreation.monkey
	Description:	Sample fantomEngine script to show how to create an use scenes
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
	
	' Create fields for 2 scenes and layers
	Field layer1:ftLayer
	Field layer2:ftLayer
	Field scene1:ftScene
	Field scene2:ftScene
	
	' As we work with transitions, we need 2 constants to identify the fading of each scene 
	Const tidFade1:Int = 1
	Const tidFade2:Int = 2
	
	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate events to be determined by the devices refresh rate.
		SetUpdateRate(0)
		
		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine
		
		' Get the default scene of the engine
		scene1 = fE.GetDefaultScene()

		' Get the default layer of the engine
		layer1 = fE.GetDefaultLayer()
		
		' Now add layer1 to scene1
		scene1.AddLayer(layer1)
		
		' Create a circle whic is automatically added to the current default layer (aka layer1)
		Local circle := fE.CreateCircle(30, fE.GetCanvasWidth()/2, fE.GetCanvasHeight()/2)
		
		' Now let it move and wrap around the edges of the canvas
		circle.SetSpeed(10,45)
		circle.SetWrapScreen(True)
		
		' Load a bitmap font and create a text object that will display the scene name
		Local font:ftFont = fE.LoadFont("font.txt")
		Local scn1Txt:ftObject = fE.CreateText(font,"Scene #1",10,fE.GetCanvasHeight()-10, fE.taBottomLeft)
		
		' Now repeat this with scene2 and layer2
		scene2 = fE.CreateScene()
		layer2 = fE.CreateLayer()
		scene2.AddLayer(layer2)
		
		' Next declare layer2 as the default layer so newly created objects will be added to layer2
		fE.SetDefaultLayer(layer2)
		
		Local box := fE.CreateBox(30,30, fE.GetCanvasWidth()/2, fE.GetCanvasHeight()/2)
		box.SetSpeed(10,315)
		box.SetSpin(5)
		box.SetWrapScreen(True)
		
		Local scn2Txt:ftObject = fE.CreateText(font,"Scene #2",10,fE.GetCanvasHeight()-10, fE.taBottomLeft)
		scene2.SetActive(False)
		
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' If the CLOSE key was hit, exit the app ... needed for GLFW and Android, I think. 
		If KeyHit( KEY_CLOSE ) Then fE.ExitApp()
		
		' Determine the delta time and the update factor for the engine
		Local timeDelta:Float = Float(fE.CalcDeltaTime())/60.0
		
		' When the SPACE key is hit or the screen is touched, fade out the activate scene. In the ftEngine.OnLayerTransition event, we will de-/activate the corresponding scenes.
		If KeyHit(KEY_SPACE) Or TouchHit(0) Then
			If scene1.isActive = True
				scene1.CreateTransAlpha(0.0,500,False,tidFade1)
			Else
				scene2.CreateTransAlpha(0.0,500,False,tidFade2)
			Endif
		Endif

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
	Method OnLayerTransition:Int(transId:Int, layer:ftLayer)
		' This method is called when a layer finishes its transition
		
		' check which scene was faded out
		If transId = _g.tidFade1
			' De-/activate the scenes and set the alpha value of the now active scene to 1.0
			_g.scene1.SetActive(False)
			_g.scene2.SetActive(True)
			_g.scene2.SetAlpha(1.0)
		Endif

		If transId = _g.tidFade2
			_g.scene1.SetActive(True)
			_g.scene2.SetActive(False)
			_g.scene1.SetAlpha(1.0)
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

