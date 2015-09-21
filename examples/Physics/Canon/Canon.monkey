Strict

#rem
	Script:			LivingCanon.monkey
	Description:	A fantomEngine sample script that shows how to shoot a box2D object in the direction of a touch event.
	Author: 		Michael Hartlef
	Version:      	1.0
#End

' Set the AutoSuspend functionality to TRUE so OnResume/OnSuspend are called
#MOJO_AUTO_SUSPEND_ENABLED=True

' Import the fantomEngine framework which imports mojo itself
Import fantomEngine

'Import the Box2D<->fantomEngine bridge class
Import fantomEngine.cftBox2D

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
	
	' Two fields that store the canvas width and height
	Field cw:Float
	Field ch:Float
	
	' Now create some objects that represent the game objects
	Field cannon:ftObject
	Field cannonBore:ftObject
	
	' The physics scale
	Const physicsScale:Float = 60.0
	
	' Create a field that stores the instance of the ftBox2D class
	Field box2D:ftBox2D
	
	' Create some constants to identify the different objects
	Const grpCanTube:Int = 100
	Const grpShot:Int = 101

	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate to 60 FPS.
		SetUpdateRate(0)
		
		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine
		


		' Get the default scene of the engine
		defScene = fE.GetDefaultScene()

		' Get the default layer of the engine
		defLayer = fE.GetDefaultLayer()
		
		' Set the virtual canvas to 320x480 pixels and let it scale/center in letterbox mode
		fE.SetCanvasSize(480, 320, ftEngine.cmLetterbox)

		' Now determine and store the current canvas width and height
		cw = fE.GetCanvasWidth()
		ch = fE.GetCanvasHeight()
		
		Local background:=fE.CreateBox(cw, ch, cw/2.0, ch/2.0)
		background.SetColor(0,0,255)

		' Setup the physics world
		SetupPhysicsWorld()
		
		' Setup our lovely cannon now
		SetupCannon()

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
			' Update the physics world
			box2D.UpdateWorld(1/physicsScale, 8, 3)
			' Now do a touch check when the canvas was touched
			If TouchHit(0) Then 
				fE.TouchCheck(0)
				SpawnShot'()
			Endif
		' Update all objects of the engine
			fE.Update(timeDelta)
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Check if the engine is not paused
		If fE.GetPaused() = False Then
			' Clear the screen 
			Cls (0,0,0)
			' Depending if the SPACE bar is pressed, render the ftObjects or the debug drawing of the box2D instance.
			If KeyDown(KEY_SPACE) Then
				PushMatrix
				Translate(fE.autofitX, fE.autofitY)
				box2D.RenderDebugDraw() 
				PopMatrix
			Else
				' Render all visible objects of the engine
				fE.Render() 
				' Render the current FPS value in the top left corner of the canvas
				DrawText("FPS: "+fE.GetFPS(), Int( fE.GetLocalX(2)), Int(fE.GetLocalY(2)))
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

	'------------------------------------------
	' This method sets up the canon
	Method SetupCannon:Void()
		' Create the body of the canon
		cannon = fE.CreateBox(40,20, 40, fE.GetCanvasHeight()-20)
		cannon.SetColor(0,255,0)
		
		cannonBore = fE.CreateBox(10,30, cannon.GetPosX(), cannon.GetPosY()- cannon.GetHeight()/2)
		cannonBore.SetColor(255,0,0)
		cannonBore.SetHandle(0.5,1)
		
		cannonBore.SetID(grpCanTube)

		' Now create the physic object for the ball and connect it
		'box2D.CreateObject(cannonBore)
		
	End
	'------------------------------------------
	' This method spawns a shot
	Method SpawnShot:Void()
		' Create the shot
		Local shot := fE.CreateCircle(05, cannonBore.GetPosX(), cannonBore.GetPosY())
		shot.SetColor(255,255,0)
		
	
		shot.SetID(grpShot)
		shot.SetAngle(cannonBore.GetAngle())
		'shot.SetSpeed(10)

		' Now create the physic object for the ball and connect it
		Local body := box2D.CreateObject(shot)
		
		'Print(body.GetType())
		
		'Determine the position of the physics body of the object
		Local pos:Float[] = box2D.GetPosition(shot)
		' Determine the Touch coordinates 
		Local tx:Float = fE.GetTouchX()
		Local ty:Float = fE.GetTouchY()
		
		Local shotVec := New ftVec2D((tx-pos[0]), (ty-pos[1]))
		shotVec.Normalize()
		
		' Calculate the force that is applied to the object
		'Local fx:Float = ((tx-pos[0])*(60/_g.physicsScale))
		'Local fy:Float = ((ty-pos[1])*(60/_g.physicsScale))
		Local fx:Float = (shotVec.x * 10 *(60/_g.physicsScale))
		Local fy:Float = (shotVec.y * 10 * (60/_g.physicsScale))
		
		
		' Now actually apply the force to the object
		box2D.ApplyForce(shot, fx, fy, pos[0], pos[1])
	End
	'------------------------------------------
	' This method sets up the physic world and buts a wall on each edge
	Method SetupPhysicsWorld:Void()
		' First create a new instance of tge ftBox2D class and assign your fantomEngine instance to it
		box2D = New ftBox2D(fE)
		' Now set the physics scale factor
		box2D.SetPhysicScale(physicsScale)
		' Let the class create now the world for you
		box2D.CreateWorld()
		' Set the gravity to the ball falls downwards
		box2D.SetGravity(0,9.8/(60/physicsScale))
		' With pressing the space key we want to see the debug drawing of box2D. 
		' So let's initialize it.
		box2D.InitDebugDraw()
		
		' Create the left wall
        box2D.CreateBox(10, ch, 0, ch/2)
        ' Create the right wall
        box2D.CreateBox(10, ch, cw, ch/2)
        ' And now the top wall
        box2D.CreateBox(cw, 10, cw/2, 0)
        ' Finally the bottom wall
        box2D.CreateBox(cw, 10, cw/2, ch)
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
		If obj.GetID()=_g.grpCanTube
			obj.SetAngle(obj.GetVectorAngle(_g.fE.GetTouchX(), _g.fE.GetTouchY()))
			' Let the ftObject be updated by the connected physics object
		Endif
		If obj.GetID()=_g.grpShot
			_g.box2D.UpdateObj(obj)
		Endif
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

