Strict

#rem
	Script:			ScalingLayers.monkey
	Description:	Sample script that shows how to scale and position layers
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
	Field layer2:ftLayer
	Field defScene:ftScene
	
	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate to 60 FPS.
		SetUpdateRate(0)
		
		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine
		
		fE.SetCanvasSize(800,500)
		
		' Get the default scene of the engine
		defScene = fE.GetDefaultScene()

		' Get the default layer of the engine
		defLayer = fE.GetDefaultLayer()
		
		' Create a simple box
		Local box := fE.CreateBox(fE.GetCanvasWidth(),fE.GetCanvasHeight(),fE.GetCanvasWidth()/2,fE.GetCanvasHeight()/2)
		'Set its color to red
		box.SetColor(255,0,0)
		' Create a smaller spinning box on the default layer
		Local boxB := fE.CreateBox(fE.GetCanvasWidth()/8,fE.GetCanvasHeight()/2,fE.GetCanvasWidth()/2,fE.GetCanvasHeight()/2)
		boxB.SetColor(0,255,255)
		boxB.SetSpin(2)
		
		' Now create a new layer on top of the default one.
		layer2 = fE.CreateLayer()
		layer2.SetID(888)
		layer2.SetLayerScissor(10,0,fE.GetCanvasWidth()-20,fE.GetCanvasHeight()/2)
		
		' Set the engines default layer to the new one so every new object is
		' automatically assigned to layer2
		fE.SetDefaultLayer(layer2)
		
		' Now create a blue box which srves as the background for layer2
		Local box3 := fE.CreateBox(fE.GetCanvasWidth(),fE.GetCanvasHeight(),fE.GetCanvasWidth()/2,fE.GetCanvasHeight()/2)
		box3.SetColor(0,0,255)
		' Create another yellow and spinning box 
		Local box2 := fE.CreateBox(fE.GetCanvasWidth()/2,fE.GetCanvasHeight()/2,fE.GetCanvasWidth()/2,fE.GetCanvasHeight()/2)
		box2.SetColor(255,255,0)
		box2.SetSpin(-2)
		' To mark the edges and the center of layer2, create 5 more boxes
		Local boxEdge1:=fE.CreateBox(20,20,10,10)
		Local boxEdge2:=fE.CreateBox(20,20,fE.GetCanvasWidth()-10,10)
		Local boxEdge3:=fE.CreateBox(20,20,fE.GetCanvasWidth()-10,fE.GetCanvasHeight()-10)
		Local boxEdge4:=fE.CreateBox(20,20,10,fE.GetCanvasHeight()-10)
		boxEdge3.SetID(999)
		'boxEdge3.SetScale(2)
		Local boxEdge5:=fE.CreateBox(20,20,fE.GetCanvasWidth()/2,fE.GetCanvasHeight()/2)
		
		' Scale layer2 to half of its size
		layer2.SetScale(0.5)
		
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

			' Set the position of layer2 via the UP/DOWN/LEFT/RIGHT/ENTER keys
			If KeyDown(KEY_UP) Then layer2.SetPosY(-1, True)
			If KeyDown(KEY_DOWN) Then layer2.SetPosY( 1, True)
			If KeyDown(KEY_LEFT) Then layer2.SetPosX(-1, True)
			If KeyDown(KEY_RIGHT) Then layer2.SetPosX( 1, True)
			If KeyDown(KEY_ENTER) Then layer2.SetPos( 0,0)
			
			' Set the scale factor of layer2 via the QWE keys
			If KeyDown(KEY_Q) Then layer2.SetScale( -0.02, True)
			If KeyDown(KEY_W) Then layer2.SetScale( 1.0)
			If KeyDown(KEY_E) Then layer2.SetScale(  0.02, True)
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Check if the engine is not paused
		If fE.GetPaused() = False Then
			' Clear the screen 
			Cls 0,0,0
		
			' Render all visible objects of the engine
			fE.Render()
			
			DrawText("FPS= "+fE.GetFPS(),fE.GetLocalX(40), fE.GetLocalY(10))
			DrawText("TouchX= "+fE.GetTouchX(), fE.GetLocalX(40), fE.GetLocalY(25))
			DrawText("TouchY= "+fE.GetTouchY(), fE.GetLocalX(40), fE.GetLocalY(40))
			DrawText("LayerScale= "+layer2.GetScale(), fE.GetLocalX(fE.GetCanvasWidth()-150), fE.GetLocalY(10))
			DrawText("Layer2X= "+layer2.GetPosX(), fE.GetLocalX(fE.GetCanvasWidth()-150), fE.GetLocalY(25))
			DrawText("Layer2Y= "+layer2.GetPosY(), fE.GetLocalX(fE.GetCanvasWidth()-150), fE.GetLocalY(40))
			DrawText("feScaleX= "+fE.scaleX, fE.GetLocalX(fE.GetCanvasWidth()-150), fE.GetLocalY(55))
			DrawText("feScaleY= "+fE.scaleY, fE.GetLocalX(fE.GetCanvasWidth()-150), fE.GetLocalY(70))
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
	Method OnLayerTransition:Int(transId:Int, layer:ftLayer)
		' This method is called when a layer finishes its transition
		Return 0
	End
	'------------------------------------------
	Method OnLayerUpdate:Int(layer:ftLayer)
		' This method is called when a layer finishes its update
		Return 0
	End	
	'------------------------------------------
	Method OnObjectAnim:Int(obj:ftObject)
		'This Method is called when an animation of an object (obj) has finished one loop.
		Return 0
	End
	'------------------------------------------
	Method OnObjectCollision:Int(obj:ftObject, obj2:ftObject)
		' This method is called when an object collided with another object
		Return 0
	End
	'------------------------------------------
	Method OnObjectDelete:Int(obj:ftObject)
		' This method is called when an object is removed. You need to activate the event via ftObject.ActivateDeleteEvent.
		Return 0
	End
	'------------------------------------------
	Method OnObjectRender:Int(obj:ftObject)
		' This method is called when an object was being rendered. You need to activate the event via ftObject.ActivateRenderEvent.
		Return 0
	End
	'------------------------------------------
	Method OnObjectSort:Int(obj1:ftObject, obj2:ftObject)
		' This method is called when objects are compared during a sort of its layer list
		Return 0
	End	
	'------------------------------------------
	Method OnObjectTimer:Int(timerId:Int, obj:ftObject)
		' This method is called when an objects' timer was being fired.
		Return 0
	End	
	'------------------------------------------
	Method OnObjectTouch:Int(obj:ftObject, touchId:Int)
		' This method is called when an object was touched
		Return 0
	End
	'------------------------------------------
	Method OnObjectTransition:Int(transId:Int, obj:ftObject)
		' This method is called when an object finishes its transition and the transition has an ID > 0.
		Return 0
	End
	'------------------------------------------
	Method OnObjectUpdate:Int(obj:ftObject)
		' This method is called when an object finishes its update. You can deactivate the event via ftObject.ActivateUpdateEvent.
		Return 0
	End
	'------------------------------------------
	Method OnMarkerBounce:Int(marker:ftMarker, obj:ftObject)
		' This method is called, when a path marker reaches the end of the path and is about to bounce backwards.
		Return 0
	End
	'------------------------------------------
	Method OnMarkerCircle:Int(marker:ftMarker, obj:ftObject)
		' This method is called, when a path marker reaches the end of the path and is about to do another circle.
		Return 0
	End
	'------------------------------------------
	Method OnMarkerStop:Int(marker:ftMarker, obj:ftObject)
		' This method is called, when a path marker reaches the end of the path and stops there.
		Return 0
	End
	'------------------------------------------
	Method OnMarkerWarp:Int(marker:ftMarker, obj:ftObject)
		' This method is called, when a path marker reaches the end of the path and is about to warp to the start to go on.
		Return 0
	End
	'------------------------------------------
	Method OnMarkerWP:Int(marker:ftMarker, obj:ftObject)
		' This method is called, when a path marker reaches a waypoint of its path.
		Return 0
	End
	'------------------------------------------
	Method OnSwipeDone:Int(touchIndex:Int, sAngle:Float, sDist:Float, sSpeed:Float)
		' This method is called when a swipe gesture was detected
		Return 0
	End
    '------------------------------------------
	Method OnTimer:Int(timerId:Int)
		' This method is called when an engine timer was being fired.
		Return 0
	End	
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var '_g'
	_g = New cGame
	
	Return 0
End

