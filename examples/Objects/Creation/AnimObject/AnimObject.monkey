Strict

#rem
	Script:			AnimObject.monkey
	Description:	Sample script that shows how to load/create animated objects
	Author: 		Michael Hartlef
	Version:      	1.04
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
	
	Field player:ftObject
	
	Field playerCopy:ftObject
	
	Field cW:Float
	Field cH:Float
	
	
	
	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate events to be determined by the devices refresh rate.
		SetUpdateRate(0)
		
		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine
		
		cW = fE.GetCanvasWidth()
		cH = fE.GetCanvasHeight()
		
		' Get the default scene of the engine
		defScene = fE.GetDefaultScene()

		' Get the default layer of the engine
		defLayer = fE.GetDefaultLayer()
		
		
		' Load the packed texture atlas via ftSpriteAtlas class
		Local tpatlas:ftSpriteAtlas = New ftSpriteAtlas
		tpatlas.Load("td_spritesheet.png", "td_spritesheet.txt")
		
		' Create a simple animated character by loading several images and creating the animation seperately
		player = fE.CreateImage("char_01.png", cW/2.0, cH/2.0)
		player.SetName("Player")
		player.AddImage("char_02.png")
		player.AddImage("char_03.png")
		player.AddImage("char_04.png")
		player.AddImage("char_05.png")


		' Create the WALK animation. Below you see different ways of composing the animation
		player.CreateAnim("WALK", player.GetImageIndex("char_01.png"))
		player.AddAnim("WALK", "char_02.png")
		player.AddAnim("WALK", 1)
		player.AddAnim("WALK", player.GetImageIndex("char_03.png"))


		'Now create a copy of the current player
		playerCopy = fE.CopyObject(player)
		playerCopy.SetName("PlayerCopy")
		playerCopy.SetPos(cW/2.0+100, cH/2.0+100)
		playerCopy.SetAnimPaused(False)
		playerCopy.SetAnimTime(5)
		'playerCopy.SetAnimRepeatCount(0)
		
		
		' Create the IDLE animation of the player
		player.CreateAnim("IDLE", "char_01.png")
		player.AddAnim("IDLE", 4, 1, 1)
		player.AddAnim("IDLE", 1)
		player.AddAnim("IDLE", "char_05.png", 1, 1)
		player.AddAnim("IDLE", 5)
		player.AddAnim("IDLE",  player.GetImageIndex("char_05.png"))
		
		player.SetAnimFrame(4)
		
		'Print ("ImageCount="+player.GetImageCount())
		'For Local ix:Int = 1 To player.GetImageCount()
		'	Print ("path image #"+ix+" = "+player.GetImagePath(ix))
		'Next

		player.SetAnimPaused(True)
		
		' Now create an animated Object from a spritesheet
		Local animObj:= fE.CreateImage(tpatlas.GetImage("gold"), cW/2.0-100, cH/2.0)
		animObj.SetName("animObject")
		animObj.AddImage(tpatlas.GetImage("silver"))
		animObj.AddImage(tpatlas.GetImage("Mine"))
		' Attention, currently the animation can only be created via the image indexes when they are taken from an atlas.
		animObj.CreateAnim("BLINK", 1)
		animObj.AddAnim("BLINK", 2)
		animObj.AddAnim("BLINK", 3)


		Print ("Press the W key to set the WALK animation.")
		Print ("Press the I key to set the IDLE animation (default).")
		Print ("Press the P key to pause the animation or resume it.")
		
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' If the CLOSE key was hit, exit the app ... needed for GLFW and Android I think. 
		If KeyHit( KEY_CLOSE ) Then fE.ExitApp()
		
		' Determine the delta time and the update factor for the engine
		Local timeDelta:Float = Float(fE.CalcDeltaTime())/60.0


		If KeyHit( KEY_W ) Then 
			player.SetActiveAnim("WALK")   'WALK
			player.SetAnimPaused(False)
			player.SetAnimTime(2)
		Endif
		If KeyHit( KEY_I ) Then 
			player.SetActiveAnim("IDLE")   'IDLE
			player.SetAnimPaused(False)
			player.SetAnimTime()
		Endif
		If KeyHit( KEY_P ) Then 
			If player.GetAnimPaused()=True Then
				player.SetAnimPaused(False)
			Else
				player.SetAnimPaused(True)
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
			DrawText("Current animation name: " + player.GetAnimName(), 20, 20)
			DrawText("Current animation frame count: " + player.GetAnimCount() + " frames", 20, 40)
			DrawText("Current animation frame number: #" + Int(player.GetAnimFrame()), 20, 60)
			DrawText("Current animation time length: " + player.GetAnimTime(), 20, 80)
			If player.GetAnimPaused()=True
				DrawText("Animation paused!",20,fE.GetCanvasHeight()-40)
			Endif
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
		'This method is called when an animation of an object (obj) has finished one loop.
		Print ("Anim loop " + obj.GetName() + " finished")
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

