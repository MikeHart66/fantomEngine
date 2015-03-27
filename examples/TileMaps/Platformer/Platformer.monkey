Strict

#rem
	Script:			Platformer.monkey
	Description:	Sample script which shows how to create a platfomer type of game using Tiled maps
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
	
	' Create an object that stores the tile map
	Field tileMap:ftObject
	
	' Now create an object for the player
	Field player:ftObject

	' A field to determine the max jumps mid-air before you need to hit the ground again
	Field jumpCount:Int = 0
	
	' Constants to define collision groups
	Const cgMap:Int = 1
	Const cgPlayer:Int = 2
	
	'------------------------------------------
	Method GetColEdge:Int(obj:ftObject, obj2:ftObject)
			' Calculate the distance fromt the center of the objects
			Local diffX := obj2.GetPosX() - obj.GetPosX()
			Local diffY := obj2.GetPosY() - obj.GetPosY()
			
			' Two fields to store the depth of the intersection 
			Local interSectX:Float = 99999.9			
			Local interSectY:Float = 99999.9 
			
			' Determine the depth of the intersection in the X direction
			If diffX > 0.0 Then 
				interSectX = Abs(obj.GetEdge(ftEngine.oedRight) - obj2.GetEdge(ftEngine.oedLeft))
			Elseif diffX < 0.0 Then
				interSectX = Abs(obj.GetEdge(ftEngine.oedLeft) - obj2.GetEdge(ftEngine.oedRight))
			Endif

			' Determine the depth of the intersection in the Y direction
			If diffY > 0.0 Then 
				interSectY = Abs(obj.GetEdge(ftEngine.oedBottom) - obj2.GetEdge(ftEngine.oedTop))
			Elseif diffY < 0.0 Then
				interSectY = Abs(obj.GetEdge(ftEngine.oedTop) - obj2.GetEdge(ftEngine.oedBottom))
			Endif

			' Check if the intersection is smaller than 8 pixels. This may vary depending on the size of your objects
			If interSectX < 8 Or interSectY < 8 Then			
				
				' Return the collision edge depending on which intersection was smaller.
				If interSectX < interSectY
					If diffX < 0.0 Then Return ftEngine.oedLeft
					If diffX >= 0.0 Then Return ftEngine.oedRight
				Elseif interSectX >= interSectY
					If diffY < 0.0 Then Return ftEngine.oedTop
					If diffY > 0.0 Then Return ftEngine.oedBottom
				Endif
			Endif			
		Return 0
	End

	'------------------------------------------
	Method CreateMapCollisionObjects:Int()
		' Determine the total count of map tiles.
		Local mapCount := tileMap.GetTileCount()
		
		' Now loop through them one by one
		For Local mc:Int = 1 To mapCount
		
			' Check if a tile has an index >= 0
			If tileMap.GetTileID(mc-1)>= 0 Then 
			
				' Create a zone box to serve as a collision area where the player object can do a collision check against it.
				Local collObj := fE.CreateZoneBox( tileMap.GetTileWidth(mc-1), tileMap.GetTileHeight(mc-1), tileMap.GetTilePosX(mc-1), tileMap.GetTilePosY(mc-1) )
				
				' Set the collision group to 1 so the player can check against this group.
				collObj.SetColGroup(cgMap)

			Endif
		Next

		Return 0
	End

	'------------------------------------------
	Method LoadMap:Int()
		' Load the tile map fromt the JSON file
		tileMap = fE.CreateTileMap("platformer.json", 16, 16 )

		' As the map doesn't move, we can deactivate the ftEngine.OnObjectUpdate event for it.
		tileMap.ActivateUpdateEvent(False)
		
		' To let our player object collide, we will setup some zone objects for collision detection
		CreateMapCollisionObjects()

		Return 0
	End

	'------------------------------------------
	Method CreatePlayer:Int()
		' Create a simple box
		player = fE.CreateBox(24,48,fE.GetCanvasWidth()/2+100,32)
		
		' Set its maximum speed and friction
		player.SetMaxSpeed(15)
		player.SetFriction(0.5)		
		
		' To be able to check against the collision group for tiles, you need to tell the player object that can can collide with it.
		player.SetColWith(cgMap,True)
		
		' Set the collision group of the player. Without that, the player won't check for collisions itself.
		player.SetColGroup(cgPlayer)
		Return 0
	End

	'------------------------------------------
	Method OnCreate:Int()
		' Set the target update rate to 60 FPS
		SetUpdateRate(0)

		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine
		
		' Get the default scene of the engine
		defScene = fE.GetDefaultScene()

		' Get the default layer of the engine
		defLayer = fE.GetDefaultLayer()
		
		'defLayer.SetLayerScissor(0,200,-20,-200)
		
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
			' Update all objects of the engine
			fE.Update(timeDelta)
			
			' Do a general collision check
			fE.CollisionCheck()
			
			' Add some speed to the player depending on which cursor key was pressed
			
			' First the right and left keys
			If KeyDown(KEY_LEFT) Then player.SetSpeedX(-5)
			If KeyDown(KEY_RIGHT) Then player.SetSpeedX(5)
			If KeyDown(KEY_ESCAPE) Then fE.ExitApp()
			
			' Now the up key, to determine a jump for the player
			If KeyHit(KEY_UP) Then 
				' Add 1 to jumpCount
				jumpCount += 1
				' Check if jumpCount is <= 2. Means mid-air you can do another jump.
				If jumpCount <= 2 Then
					player.SetSpeedY(-15)
				Endif
			Endif
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Check if the engine is not paused
		If fE.GetPaused() = False Then
			' Clear the screen with a nice blue color (sky)
			Cls(100,100,255)
		
			' Render all visible objects of the engine
			fE.Render()
			
			' Determine and draw the current FPS value
			DrawText("FPS: "+fE.GetFPS(),220,10)
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
	Method OnObjectCollision:Int(obj:ftObject, obj2:ftObject)
		' This method is called when an object collided with another object
		
		' Check if object 1 is the player
		If obj = _g.player Then
		
			' Some variables the absolute distance from the center of the objects
			Local absDiffX:Float
			Local absDiffY:Float
			
			' Now get the edge of the collision
			Local lcolEdge:Int = _g.GetColEdge(obj, obj2)	

			' Depending on the edge of the collision, move the player object in the opposite direction
			Select lcolEdge
				Case ftEngine.oedLeft   '3
					absDiffX = Abs(obj.GetEdge(ftEngine.oedLeft) - obj2.GetEdge(ftEngine.oedRight))
					obj.SetPosX(absDiffX+0.1,True)
					obj.SetSpeedX(0)
				
				Case ftEngine.oedRight   '4
					absDiffX = Abs(obj.GetEdge(ftEngine.oedRight) - obj2.GetEdge(ftEngine.oedLeft))
					obj.SetPosX(-absDiffX-0.1,True)
					obj.SetSpeedX(0)
								
				Case ftEngine.oedTop     '2
					absDiffY = Abs(obj.GetEdge(ftEngine.oedTop) - obj2.GetEdge(ftEngine.oedBottom))
					obj.SetPosY(absDiffY+0.1,True)
					obj.SetSpeedY(0)
			
				Case ftEngine.oedBottom    '1
					absDiffY = Abs(obj.GetEdge(ftEngine.oedBottom) - obj2.GetEdge(ftEngine.oedTop))
					obj.SetPosY(-absDiffY-0.1,True)
					obj.SetSpeedY(0)
					_g.jumpCount = 0

			End Select
		Endif

		Return 0
	End
	'------------------------------------------
	Method OnObjectUpdate:Int(obj:ftObject)
		' This method is called when an object finishes its update. You can deactivate the event via ftObject.ActivateUpdateEvent.
		
		' If the object is the player, then add some down force to it.
		If obj = _g.player Then obj.AddSpeed(0.25, 180)
		Return 0
	End
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var 'g'
	_g = New cGame
	
	Return 0
End

