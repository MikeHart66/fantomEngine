Strict

#rem
	Script:			MouseJoint.monkey
	'Description:	Sample script on how to integrate Box2D with fantomEngine 
	Author: 		Michael Hartlef
	Version:      	1.08
#End

' Set the AutoSuspend functionality to TRUE so OnResume/OnSuspend are called
#MOJO_AUTO_SUSPEND_ENABLED=True

' Import the fantomEngine framework which imports mojo itself
Import fantomEngine

'Import the Box2D<->fantomEngine bridge class
Import fantomEngine.cftBox2D

' The g variable holds an instance to the game class
Global g:game

'***************************************
' The game class controls the app
Class game Extends App
    ' Create a field to store the instance of the engine class, which is an instance
    ' of the ftEngine class itself
	Field eng:engine
	
	' Two fields that store the canvas width and height
	Field cw:Float
	Field ch:Float
	
	' Create a field that stores the instance of the ftBox2D class
	Field box2D:ftBox2D
	
	' The physics scale
	Field physicsScale:Float = 30.0
	
	' A constant to be set as an ID for each crate
	Const crateID:Int = 222
	
	'------------------------------------------
	Method SpawnCrates:Void(amount:Int)
		' a local var to store temporary a created object
		Local crate:ftObject
		For Local i:Int = 1 To amount
			crate  = eng.CreateImage("cratesmall.png",Rnd(30,cw-30), Rnd(30,100))
			' Set its angle randomly
			crate.SetAngle(Rnd(0,360))
			' Scale the crate randomly
			crate.SetScale(Rnd(0.7)+0.3)
			' Set the ID so we can check on that during OnObjectUpdate
			crate.SetID(crateID)
			' Set the collision type of the crate to "rotated box"
			crate.SetColType(ftEngine.ctBox)
			' Now create the physics object for the crate
			box2D.CreateObject(crate)
			' Set friction and restitution (bounce) of the crate
			'box2D.SetDensity(crate, 1.3)
			'box2D.SetFriction(crate, 0.3)
			'box2D.SetRestitution(crate, 0.2)

		Next
	End

	'------------------------------------------
	' This medthod sets up the physic world and buts a wall on each edge
	Method SetupPhysics:Void()
		' First create a new instance of tge ftBox2D class and assign your fantomEngine instance to it
		box2D = New ftBox2D(eng)
		' Now set the physics scale factor
		box2D.SetPhysicScale(physicsScale)
		' Let the box2D class create now the world for you
		box2D.CreateWorld()
		' Set the gravity of the world
		box2D.SetGravity(0,10)
		' With pressing the space key we want to see the debug drawing of box2D. 
		' So let's initialize it.
		box2D.InitDebugDraw()
		
		' Create the left wall
        box2D.CreateBox(10, ch, 0, ch/2)
        ' Create the right wall
        box2D.CreateBox(10, ch, cw, ch/2)
        ' And now the top wall
        box2D.CreateBox(cw, 10, cw/2, 0)
        ' Finally create the bottom wall
        box2D.CreateBox(cw, 10, cw/2, ch)
	End
	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate to 60 FPS.
		SetUpdateRate(60)
		' Set the Seed value via the current Millisecs value 
		Seed = Millisecs()
		' Create an instance of the fantomEngine, which was created via the engine class
		eng = New engine
		' Now determine and store the current canvas width and height
		cw = eng.GetCanvasWidth()
		ch = eng.GetCanvasHeight()
		
		' Setup the physics world
		SetupPhysics()
		
		' Spawn some crates
		SpawnCrates(50)
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' Determine the delta time and the update factor for the engine
		Local d:Float = Float(eng.CalcDeltaTime())/60.0
		' Check if the app is not suspended
		If eng.GetPaused() = False Then
			' Update the physics world
	        box2D.UpdateWorld((d*4.0)/physicsScale)
		Endif
		' Update all objects of the engine
		eng.Update(d)
		' If the ESCAPE key was pressed, exit the app
		If KeyHit(KEY_ESCAPE) Then eng.ExitApp
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Check if the app is not suspended
		If eng.GetPaused() = False Then
			' Clear the screen 
			Cls 
			' Depending if the SPACE bar is pressed, render the ftObjects or the debug drawing of the box2D instance.
			If KeyDown(KEY_SPACE) Then
				PushMatrix
				Translate(eng.autofitX, eng.autofitY)
				box2D.RenderDebugDraw() 
				PopMatrix
			Else
				' Render all visible objects of the engine
				eng.Render() 
			Endif
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnResume:Int()
		' Set the pause flag of the engine to FALSE so objects, timers and transitions are updated again
		eng.SetPaused(false)
		Return 0
	End
	'------------------------------------------
	Method OnSuspend:Int()
		' Set the pause flag of the engine to TRUE so objects, timers and transitions are paused (not updated)
		eng.SetPaused(True)
		Return 0
	End
End	


'***************************************
Class engine Extends ftEngine

	'------------------------------------------
	Method OnObjectUpdate:Int(obj:ftObject)
		' This method is called when an object finishes its update
		If obj.GetID() = g.crateID Then	
			' Let the ftObject be updated by the connected physics object
			g.box2D.UpdateObj(obj)
		Endif
		Return 0
	End
	
End

'***************************************
Function Main:Int()
	' Create an instance of the game class and store it inside the global var 'g'
	g = New game
	Return 0
End
