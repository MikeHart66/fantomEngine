Strict

#rem
	Script:			JuggleSoccerBall.monkey
	Description:	Sample fantomEngine script that shows how to setup a little game
	Author: 		Michael Hartlef
	Version:      	1.04
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
	
	' The ball object
	Field ball:ftObject = Null
	
	' The physics scale
	Field physicsScale:Float = 60.0
	
	' Create a field that stores the instance of the ftBox2D class
	Field box2D:ftBox2D

	'------------------------------------------
	' This medthod sets up the physic world and buts a wall on each edge
	Method SetupPhysicsWorld:Void()
		' First create a new instance of tge ftBox2D class and assign your fantomEngine instance to it
		box2D = New ftBox2D(eng)
		' Now set the physics scale factor
		box2D.SetPhysicScale(physicsScale)
		' Let the class create now the world for you
		box2D.CreateWorld()
		' Set the gravity to the ball falls downwards
		box2D.SetGravity(0,4.0/(60/physicsScale))
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
	'------------------------------------------
	' The method will setup the ball object we want to juggle in the air.
	Method SetupBall:Void()
		' First create the ftObject that represents the ball
		ball  = eng.CreateImage("ball.png",Rnd(40,cw-40), 240 )
		' Set the angle randomly
		ball.SetAngle(Rnd(0,360))
		' Set the radius of the ball to a half of its height
		ball.SetRadius(ball.GetHeight()/2)
		' Now create the physic object for the ball and connect it
		box2D.CreateObject(ball)
		' Set the bounciness to 0.3
		box2D.SetRestitution(ball, 0.3)
		' To be touchable, you need to set its touch mode
		ball.SetTouchMode(ftEngine.tmCircle)
		' To actually be able to touch a little under the ball, you need to raise its radius a little
		ball.SetRadius(14,True)
	End
	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate events to be determined by the devices refresh rate.
		SetUpdateRate(0)
		' Create an instance of the fantomEngine, which was created via the engine class
		eng = New engine
		' Set the virtual canvas to 320x480 pixels and let it scale/center in letterbox mode
		eng.SetCanvasSize(320, 480, ftEngine.cmLetterbox)
		' Now determine and store the current canvas width and height
		cw = eng.GetCanvasWidth()
		ch = eng.GetCanvasHeight()
		' Load the soccerField image and place it in the center of the canvas
		Local soccerField := eng.CreateImage("field.png", cw/2, ch/2) 
		' Setup the physics world
		SetupPhysicsWorld()
		' Setup the ball and its physics object
		SetupBall()
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' Determine the delta time and the update factor for the engine
		Local d:Float = Float(eng.CalcDeltaTime())/60.0
		
		' Check if the app is not suspended
		If eng.GetPaused() = False Then
			' Update the physics world
			box2D.UpdateWorld(1/physicsScale, 8, 3)
			' Now do a touch check when the canvas was touched
			If TouchHit(0) Then 
				eng.TouchCheck(0)
			Endif
		Endif
		' Update all objects of the engine
		eng.Update(d)

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
				box2D.RenderDebugDraw() 
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
' The engine class extends the ftEngine class to override the On... methods
Class engine Extends ftEngine
	'------------------------------------------
	Method OnObjectUpdate:Int(obj:ftObject)
		' This method is called when an object finishes its update
		If obj = g.ball Then	
			' Let the ftObject be updated by the connected physics object
			g.box2D.UpdateObj(obj)
			'Local bd:b2Body = g.box2D.GetBody(obj)
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnObjectTouch:Int(obj:ftObject, touchId:Int)
		' This method is called when a object was touched
		'Determine the position of the physics body of the object
		Local pos:Float[] = g.box2D.GetPosition(obj)
		' Determine the Touch coordinates 
		Local tx:Float = g.eng.GetTouchX()
		Local ty:Float = g.eng.GetTouchY()
		' Calculate the force that is applied to the object
		Local fx:Float = ((pos[0]-tx)*10*(60/g.physicsScale))
		Local fy:Float = ((pos[1]-ty)*15*(60/g.physicsScale))
		' Now actually apply the force to the object
		g.box2D.ApplyForce(obj, fx, fy, pos[0], pos[1])
		Return 0
	End
End

'***************************************
Function Main:Int()
	' Create an instance of the game class and store it inside the global var 'g'
	g = New game
	Return 0
End

