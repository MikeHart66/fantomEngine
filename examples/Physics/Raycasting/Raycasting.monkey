Strict

#rem
	Script:			Raycasting.monkey
	'Description:	Sample script on how to do ray casting with the use of Box2D
	Author: 		Michael Hartlef
	Version:      	1.02
#End

' Set the AutoSuspend functionality to TRUE so OnResume/OnSuspend are called
#MOJO_AUTO_SUSPEND_ENABLED=True

' Import the fantomEngine framework which imports mojo itself
Import fantomEngine

'Import the Box2D<->fantomEngine bridge class
Import fantomEngine.cftBox2D

' The g variable holds an instance to the game class
Global g:cGame

'***************************************
' The cGame class controls the app
Class cGame Extends App
    ' Create a field to store the instance of the cEngine class, which is an instance
    ' of the ftEngine class itself
	Field eng:cEngine
	
	' Two fields that store the canvas width and height
	Field cw:Float
	Field ch:Float
	
	' Create a field that stores the instance of the cB2D class
	Field box2D:cB2D

	' Create a field to store the laser object
	Field laser:ftObject = Null
	
	' Create a field to store
	Field hitPoint:ftObject = Null
	
	' Now we need a field for the mouse joint
	Field mjoint:b2MouseJoint = Null
	
	' The physics scale
	Field physicsScale:Float = 60.0
	
	' Next create a field to store the physic world object
	Field world:b2World
	
	' As the mouse joint needs to bodies, create one for the ground of the world
	Field ground:b2Body

	'------------------------------------------
	Method SpawnBall:Void()
		' Create the crate object and set its ID to a value we call work with during the update callback of each ball
		Local ball:ftObject  = eng.CreateImage("ball.png",Rnd(30,cw-10), Rnd(30,100))
		ball.SetID(222)
		'ball.SetRadius(ball.GetHeight()/2)
		
		' Set its angle randomly
		ball.SetAngle(Rnd(0,360))

		' Set its scale randomly
		ball.SetScale(Rnd(3,20)/10.0)

		' Set the collision type of the ball to "circle"
		ball.SetColType(ftEngine.ctCircle)

		' Now create the physics object for the ball
		Local body:b2Body = box2D.CreateObject(ball)
		' Set friction and restitution (bounce) of the ball
		box2D.SetFriction(ball, 0.3)
		box2D.SetRestitution(ball, 0.4)
		
		' Make the ball touchable
		ball.SetTouchMode(ftEngine.tmCircle)

	End

	'------------------------------------------
	Method SpawnCrate:Void()
		' Create the crate object and set its ID to a value we call work with during the update callback of each crate
		Local crate:ftObject  = eng.CreateImage("cratesmall.png",Rnd(30,cw-10), Rnd(30,100))
		crate.SetID(222)
		
		' Set its angle randomly
		crate.SetAngle(Rnd(0,360))

		' Set its scale randomly
		crate.SetScale(Rnd(5,15)/10.0)

		' Set the collision type of the crate to "rotated box"
		crate.SetColType(ftEngine.ctBox)

		' Now create the physics object for the crate
		Local body:b2Body = box2D.CreateObject(crate)
		' Set friction and restitution (bounce) of the crate
		box2D.SetFriction(crate, 0.3)
		box2D.SetRestitution(crate, 0.2)
		
		' Make the crate touchable
		crate.SetTouchMode(ftEngine.tmBound)

	End

	'------------------------------------------
	' This medthod sets up the physic world and buts a wall on each edge
	Method SetupPhysics:Void()
		' First create a new instance of tge ftBox2D class and assign your fantomEngine instance to it
		box2D = New cB2D(eng)
		' Now set the physics scale factor
		box2D.SetPhysicScale(physicsScale)
		' Let the box2D class create now the world for you
		world = box2D.CreateWorld()
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
        ' Finally create the bottom wall and store it inside the ground field
        ground = box2D.CreateBox(cw, 10, cw/2, ch)
	End
	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate to 60 FPS.
		SetUpdateRate(60)
		' Set the Seed value via the current Millisecs value 
		Seed = Millisecs()
		' Create an instance of the fantomEngine, which was created via the engine class
		eng = New cEngine
		' Now determine and store the current canvas width and height
		cw = eng.GetCanvasWidth()
		ch = eng.GetCanvasHeight()
		
		' Setup the physics world
		SetupPhysics()
		
		' Setup 4 crates which we can drag around
		For Local c1:Int = 1 To 4
			SpawnCrate()
		Next
		' Setup 4 balls which we can drag around
		For Local c2:Int = 1 To 4
			SpawnBall()
		Next
		
		'Setup the laser
		laser = eng.CreateLine(cw/2, ch/4, cw/2, ch/4*3-20)
		laser.SetPos(cw/2, ch/2)
		laser.SetHandle(0,0)
		
		' Setup the hitpoint and its reflection normal
		hitPoint = eng.CreateCircle(5, cw/2, ch/2)
		hitPoint.SetColor(255,0,0)
		Local reflectionNormal:= eng.CreateLine(cw/2, ch/2, cw/2+50, ch/2)
		reflectionNormal.SetPos(cw/2, ch/2)
		reflectionNormal.SetHandle(0,0)
		reflectionNormal.SetAngle(0)
		reflectionNormal.SetParent(hitPoint)
		reflectionNormal.SetColor(0,255,0)
		
		' Print some info text
		Print ("Use the cursor keys to control the laser beam.")
		Print ("You can also drag the crates around")
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
		
		' Control the laser angle
		If KeyDown(KEY_LEFT) Then laser.SetAngle(-0.5, True)
		If KeyDown(KEY_RIGHT) Then laser.SetAngle(0.5, True)
		If KeyHit(KEY_UP) Then
			hitPoint.SetPos(cw/2, ch/2) 
			laser.SetAngle(0)
		Endif
		' Determine the "end-point" of the laser
		Local tv:Float[] = laser.GetVector(laser.w, laser.angle)
		' Now do a raycast, if not successfull, resset the position of the hitpoint 
		If Not box2D.RayCast(laser.xPos, laser.yPos, tv[0], tv[1]) = True Then 
			hitPoint.SetPos(cw/2, ch/2)
		Endif 
		' Check if the canvas is touched
		If TouchDown(0) Then
			' If no mouse joint exists, do a touch check
			If mjoint= Null Then
				eng.TouchCheck(0)
			Else
				' If there is an existing mouse joint...
				' determine and store the current touch coordinates
				Local target:b2Vec2 = New b2Vec2
				target.x = eng.GetTouchX()/physicsScale
				target.y = g.eng.GetTouchY()/physicsScale
				' Set the target of the mouse joint by the coordinates
				mjoint.SetTarget(target)
			Endif
		Else
			' if the canvas was not touched and a mouse joint exists
			If mjoint<> Null Then
				' destroy the mouse joint
				world.DestroyJoint(mjoint)
				mjoint = Null
			Endif
		Endif

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
				DrawText("FPS: "+eng.GetFPS(), 20,20) 
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
Class cEngine Extends ftEngine

	'------------------------------------------
	Method OnObjectUpdate:Int(obj:ftObject)
		' This method is called when an object finishes its update
		If obj.GetID() = 222 Then	g.box2D.UpdateObj(obj)
		Return 0
	End
	
	'------------------------------------------
	Method OnObjectTouch:Int(obj:ftObject, touchId:Int)
		' This method is called when a object was touched
		' Check if no mouse joint is existing right now
		If g.mjoint = Null Then
			' Create a mouse joint 
			g.mjoint = g.box2D.CreateMouseJoint(g.ground, g.box2D.GetBody(obj), g.eng.GetTouchX(), g.eng.GetTouchY(), 100)
		End
		Return 0
	End
End

'***************************************
Class cB2D Extends ftBox2D
	'------------------------------------------
'summery:This method creates a new ftbox2D instance and connects it with the given ftEngine
	Method New(eng:ftEngine)
		Self.engine = eng
	End
	'------------------------------------------
'summery:This callback method is called when a raycast was successful.
	Method OnRayCast:Void (rayFraction:Float, rayVec:b2Vec2, hitNormal:b2Vec2, hitPoint:b2Vec2, nextPoint:b2Vec2, fixture:b2Fixture, obj:ftObject)
		' Set the position of the hitpoint
		g.hitPoint.SetPos(hitPoint.x, hitPoint.y)
		' Determine the angle from the hitpoint to the next/reflected point of the ray 
		Local ha := g.hitPoint.GetVectorAngle(nextPoint.x, nextPoint.y)
		' The the angle of the hitpoint
		g.hitPoint.SetAngle(ha)
		' Set the color of the ftObject that was hit to red
		obj.SetColor(255,0,0)
	End
End

'***************************************
Function Main:Int()
	' Create an instance of the game class and store it inside the global var 'g'
	g = New cGame
	Return 0
End
