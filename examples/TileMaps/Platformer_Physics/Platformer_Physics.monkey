Strict

#rem
	Script:			Platformer.monkey
	Description:	Sample script which shows how to create a platfomer type of game using Tiled maps and box2D physics
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
	
	' Two fields that store the canvas width and height
	Field cw:Float
	Field ch:Float

	' Create a field for the default scene and layer of the engine
	Field defLayer:ftLayer
	Field defScene:ftScene
	
	' Create an object that stores the tile map
	Field tileMap:ftObject
	
	' Now create an object for the player
	Field player:ftObject
	
	' Cerate box2D object for the player
	Field b2dPlayer:b2Body

	' A field to determine the max jumps mid-air before you need to hit the ground again
	Field jumpCount:Int = 0
	
	' The physics scale
	Const physicsScale:Float = 60.0
	
	' Create a field that stores the instance of the ftBox2D class
	Field box2D:ftBox2D

	'------------------------------------------
	Method CreateMapCollisionObjects:Int()
		' Determine the total count of map tiles.
		Local mapCount := tileMap.GetTileCount()
		
		' Now loop through them one by one
		For Local mc:Int = 1 To mapCount
		
			' Check if a tile has an index >= 0
			If tileMap.GetTileID(mc-1)>= 0 Then 
			
				' Create a dummy pivot object to connect a box2D object
				Local pivObj := fE.CreatePivot( tileMap.GetTilePosX(mc-1), tileMap.GetTilePosY(mc-1) )
		   
			   ' Make the pivot object a child of the tilemap, so when it is handled, the pivot will too
			   pivObj.SetParent(tileMap)
			   
			   ' Make the pivot object inactive
			   pivObj.SetActive(False)
			   
			   ' Active the ftEngine.OnObjectDelete event so we can remove the corresponding box2D object there
			   pivObj.ActivateDeleteEvent(True)
			   
			   ' Per tile, create a Box2D static box 
			   Local b2dObj := box2D.CreateBox(tileMap.GetTileWidth(mc - 1), tileMap.GetTileHeight(mc - 1), tileMap.GetTilePosX(mc - 1), tileMap.GetTilePosY(mc - 1))
			   
			   ' Make the box2D object a static one, so it isn't effected by gravity
			   b2dObj.SetType(box2D.btStatic)
			   
			   ' Connect the pivot object with the box2D object
			   box2D.ConnectBody(pivObj, b2dObj )
			Endif
		Next

		Return 0
	End

	'------------------------------------------
	Method CreatePlayer:Int()
		' Create a simple box
		player = fE.CreateBox(20,40,fE.GetCanvasWidth()/2,32)
		
		' Set a name of the player object 
		player.SetName("The Player")
		
		' Create a box2D object from the player object
		b2dPlayer = box2D.CreateObject(player)
		
		' Connect the ftObject with the box2D object
		box2D.ConnectBody(player, b2dPlayer )

		' Set some box2d properties 
		box2D.SetFriction(player, 0.2)
		box2D.SetRestitution(player, 0.1)
		box2D.SetSleepingAllowed(player, False)
		box2D.SetBullet(player, True )
   
		Return 0
	End

	'------------------------------------------
	Method LoadMap:Int()
		' Load the tile map fromt the JSON file
		tileMap = fE.CreateTileMap("platformer.json", 16, 16 )

		' As the map doesn't move, we can deactivate the ftEngine.OnObjectUpdate event for it.
		tileMap.ActivateUpdateEvent(False)
		
		' Create the collision objects according to the tilemap
		CreateMapCollisionObjects()

		Return 0
	End


	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate to 60 FPS.
		SetUpdateRate(60)

		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine
		
		' Get the default scene of the engine
		defScene = fE.GetDefaultScene()

		' Get the default layer of the engine
		defLayer = fE.GetDefaultLayer()
		
		' Now determine and store the current canvas width and height
		cw = fE.GetCanvasWidth()
		ch = fE.GetCanvasHeight()

		' Setup the physics world
		SetupPhysicsWorld()

		' Load the map that was created in Tiled
		LoadMap()

		' Now create a simple player that you can control with the cursor keys
		CreatePlayer()

		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' If the CLOSE key was hit, exit the app ... needed for GLFW and Android I think. 
		If KeyHit( KEY_CLOSE ) Then fE.ExitApp()
		
		' Determine the delta time and the update factor for the engine
		Local timeDelta:Float = Float(fE.CalcDeltaTime())/60.0

		' Check if the engine is not paused
		If fE.GetPaused() = False Then
			' Update the physics world
			box2D.UpdateWorld(1/physicsScale, 8, 3)
			
			' Avoid the player to rotate 
			box2D.SetAngle(player, 0, True)

			' Update all objects of the engine
			fE.Update(timeDelta)
			
			' Add some speed to the player depending on which cursor key was pressed
			
			'Determine the current speed vectors
			Local v:Float[] = box2D.GetLinearVelocity(player)
			
			' check for the RIGHT and LEFT keys. Set the horizontal velocity accordingly
			If KeyDown(KEY_LEFT)  Then box2D.SetLinearVelocity(player, -2, v[1])
			If KeyDown(KEY_RIGHT) Then box2D.SetLinearVelocity(player,  2, v[1])
			
			' Now the UP key, to determine a jump for the player
			If KeyHit(KEY_UP) Then 
				' Add 1 to jumpCount
				jumpCount += 1
				' Check if jumpCount is <= 2. Means mid-air you can do another jump.
				If jumpCount <= 2 Then
					box2D.SetLinearVelocity(player,  v[0], -5)
				Endif
			Endif
			
			' End the app if the player pressed the ESCAPE key
			If KeyDown(KEY_ESCAPE) Then fE.ExitApp()
			
			' Press the R key to load a second level
			If KeyHit(KEY_R) Then 
				' remove the old tilemap
				tileMap.Remove()
				' Load the tile map fromt the JSON file
				tileMap = fE.CreateTileMap("platformer2.json", 16, 16 )
				' Create the collision objects according to the tilemap
				CreateMapCollisionObjects()			
			Endif
			
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Check if the engine is not paused
		If fE.GetPaused() = False Then
			If KeyDown(KEY_SPACE) Then
				PushMatrix
				Translate(fE.autofitX, fE.autofitY)
				box2D.RenderDebugDraw() 
				PopMatrix
			Else
				' Clear the screen with a nice blue color (sky)
				Cls(100,100,255)
			
				' Render all visible objects of the engine
				fE.Render()
				
				' Determine and draw the current FPS value
				'DrawText("FPS: "+fE.GetFPS(),220,10)
			Endif
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
	'------------------------------------------
	' This method sets up the physic world and buts a wall on each edge
	Method SetupPhysicsWorld:Void()
		' First create a new instance of tge ftBox2D class and assign your fantomEngine instance to it
		'box2D = New ftBox2D(fE)
		box2D = New cB2D(fE)
		
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
	Method OnObjectDelete:Int(obj:ftObject)
		'This method is called when an object is removed.
		'You need to activate this callback via the ftObject.ActivateDeleteEvent method. The given parameter holds the instance of the object.
		_g.box2D.DestroyBody(obj)
		Return 0
	End
	'------------------------------------------
	Method OnObjectUpdate:Int(obj:ftObject)
		' This method is called when an object finishes its update. You can deactivate the event via ftObject.ActivateUpdateEvent.
		
		' If the object is the player, then let the ftObject be updated by the connected physics object
		If obj = _g.player
			_g.box2D.UpdateObj(obj)
		Endif
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
'summery:This callback method is called when a collision contact has begun.
	Method OnBeginContact:Void (contact:b2Contact)
	
		Local fixtureA:b2Fixture = contact.GetFixtureA()
		Local fixtureB:b2Fixture = contact.GetFixtureB()
		Local bodyA:b2Body = contact.GetFixtureA().GetBody()
		Local bodyB:b2Body = contact.GetFixtureB().GetBody()
		Local ftObjectA:ftObject = ftObject(bodyA.GetUserData())
		Local ftObjectB:ftObject = ftObject(bodyB.GetUserData())
		'If ftObjectA<> Null 
		'	Print("A="+ftObjectA.GetName())		
		'Endif
		'If ftObjectB<> Null
		'	Print("B="+ftObjectB.GetName())		
		'Endif
		' Reset the jump count
		_g.jumpCount = 0
	End
	'------------------------------------------
'summery:This callback method is called when a collision contact has ended.
	Method OnEndContact:Void (contact:b2Contact)
'Print("2")	
	End
	'------------------------------------------
'summery:This callback method is called after the collision has been solved.
	Method OnPostSolve:Void (contact:b2Contact, impulse:b2ContactImpulse)
'Print("3")
	End
	'------------------------------------------
'summery:This callback method is called before the collision has been solved.
	Method OnPreSolve:Void (contact:b2Contact, manifold:b2Manifold)
		'Local fixtureA:b2Fixture = contact.GetFixtureA()
		'Local fixtureB:b2Fixture = contact.GetFixtureB()
		'Local bodyA:b2Body = contact.GetFixtureA().GetBody()
		'Local bodyB:b2Body = contact.GetFixtureB().GetBody()
'Print("4")
	End
	
	'------------------------------------------
'summery:This callback method is called when a raycast was successful.
	Method OnRayCast:Void (rayFraction:Float, rayVec:b2Vec2, hitNormal:b2Vec2, hitPoint:b2Vec2, nextPoint:b2Vec2, fixture:b2Fixture, obj:ftObject)
	End
	

End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var 'g'
	_g = New cGame
	
	Return 0
End

