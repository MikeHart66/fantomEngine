Strict

#rem
	Script:			Fontmachine.monkey
	Description:	Sample script that shows how to handle fontmachine bitmap fonts
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
	
	' Create a field for the default scene and layer of the engine
	Field defLayer:ftLayer
	Field defScene:ftScene
	
	Field font:ftFont
	
	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate to 60 FPS.
		SetUpdateRate(60)
		
		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine
		
		Local _cW:= fE.GetCanvasWidth()		
		Local _cH:= fE.GetCanvasHeight()
		
		' Get the default scene of the engine
		defScene = fE.GetDefaultScene()

		' Get the default layer of the engine
		defLayer = fE.GetDefaultLayer()
		
		' Load a fontMachine bitmap font
		'font = fE.LoadFMFont("SportsFont.txt")
		font = fE.LoadFont("SportsFont.txt")

		' Create a text object
		'Local txtObj:ftObject = fE.CreateText(font,"This is the sample~ntext!",_cW/2,_cH/2, ftEngine.taBottomRight)
		Local txtObj:ftObject = fE.CreateText(font,"FontMachine support~nin fantomEngine!!!",5,5)
		Print "Press B to toggle the border, press S to toggle the shadow drawing"
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' If the CLOSE key was hit, exit the app ... needed for GLFW and Android I think. 
		If KeyHit( KEY_CLOSE ) Then fE.ExitApp()
		
		' Determine the delta time and the update factor for the engine
		Local timeDelta:Float = Float(fE.CalcDeltaTime())/60.0

		If KeyHit( KEY_B ) Then font.drawBorder = Not font.drawBorder
		If KeyHit( KEY_S ) Then font.drawShadow = Not font.drawShadow
		

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
			Cls 255,255,255
		
			' Render all visible objects of the engine
			fE.Render()
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
	' Create an instance of the cGame class and store it inside the global var 'g'
	_g = New cGame
	
	Return 0
End

