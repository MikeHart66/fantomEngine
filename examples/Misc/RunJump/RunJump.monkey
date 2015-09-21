Strict

#rem
	Script:			RunJump.monkey
	Description:	This fantomEngine sample script shows basics of run & jump game 
					Player stays in place, while clouds and enemy move
	Author: 		Douglas Williams
	Version:      	1.02
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
	' Create a field to store the instance of the cEngine class, which is an instance of the ftEngine class itself
	Field fE:cEngine
	
	'Score canvas width/height
	Field cw:Float = 0.0
	Field ch:Float = 0.0
	
	'Store objects
	Field player:ftObject			'For storing PLAYER
	Field zoneBox:ftObject			'For storing PLAYER ZONE BOX
	Field enemy:ftObject			'For storing ENEMY
	
	'Store Player Attributes
	Field playerY:Float = 0.0		'For storing Player Y position
	Field health:ftObject			'For storing Player Health Bar
	
	'Store image sprite/atlas
	Field atlas:Image
	
	'Store Collision Groups
	Const grpPlayer:Int = 1
	Const grpEnemy:Int = 2
	
	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate to 60 FPS.
		SetUpdateRate(60)
		
		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine
		
		'Set canvas Width/Height field variables
		cw = fE.canvasWidth
		ch = fE.canvasHeight
		
		'Load image atlas
		'--- Uncomment and replace "xxxx.xxx" with sprite/atlas sheet file name stored in RunJump.data folder ---
		'atlas = LoadImage("xxxx.xxx")
		'-------------------------------------------------------------------------------------------------------
		
		'Print directions in debug window
		Print("~t Press up arrow to jump over obstacles. ~n")
		
		'Print canvas X & Y in debug window
		Print("Canvas Width (X)  = "+cw)
		Print("Canvas Height (Y) = "+ch)

		'Create sun
		Local sun := fE.CreateCircle(100, cw, 0)			'(radius, width, height)
		sun.SetColor(255,255,0)			'Yellow		'RGB Colors: <a href="http://www.rapidtables.com/web/color/RGB_Color.htm" target="_blank">http://www.rapidtables.com/web/color/RGB_Color.htm</a>
		
		'Create clouds
		Local cloud1 := fE.CreateCircle(40, cw/2, ch/4)		'Center
		Local cloud2 := fE.CreateCircle(30, cw/2-40, ch/4)	'Left
		Local cloud3 := fE.CreateCircle(30, cw/2+40, ch/4)	'Right
		cloud1.SetID(3)
		cloud1.SetAlpha(0.5)
		cloud1.SetSpeed(-1.0, 90)			'Only have to set speed of parent "cloud1" others will follow
		cloud2.SetAlpha(0.6)
		cloud2.SetParent(cloud1)			'Follow parent "cloud1"
		cloud3.SetAlpha(0.4)
		cloud3.SetParent(cloud1)			'Follow parent "cloud1"
		
		'Create ground
		Local ground := fE.CreateBox(cw, ch/2, cw/2, ch) 	'(width, height, x, y)
		ground.SetColor(139,69,19)							'Saddle brown
		
		'Create health bar
		Local bar := fE.CreateBox(cw/2, 20, 0, 10)
		bar.SetColor(169,169,169)						'dark grey
		
		health = fE.CreateBox(cw/2, 16, 0, 10)
		health.SetColor(124,252,0)						'lawn green
		health.SetID(0)
						
		'Create player
		'-------------------------- For an aminated sprite use -------------------------------------------------------
		'player = fE.CreateAnimImage(atlas, frameStartX, frameStartY, frameWidth, frameHeight, frameCount, xpos, ypos)
		'player.SetAnimTime(2.0)
		
		'--------------------------- For a static sprite use ---------------------------------------------------------
		'player = fE.CreateImage(atlas, x, y, width, height, xpos, ypos)
		
		'---------------------------- Basic player as a box ----------------------------------------------------------
		player = fE.CreateBox(44, 54, cw/4+6, (ch-ch/4)-30) 	
		player.SetColor(0,128,128)	'Teal
		'-------------------------------------------------------------------------------------------------------------
		player.SetID(1)
		playerY = player.GetPosY()
		
		'Create player zone box
		zoneBox = fE.CreateZoneBox(40, 50, cw/4+6, (ch-ch/4)-30)		'Invisible box

		'--- Comment above and Uncomment below for a visible zone box ---
		'zoneBox = fE.CreateBox(40, 50, cw/4+6, (ch-ch/4)-30)
		'zoneBox.SetColor(178,34,34)							'Red
		'zoneBox.SetAlpha(0.5)
		'----------------------------------------------------------------
		
		zoneBox.SetColGroup(grpPlayer)						'Set collision group
		zoneBox.SetColType(ftEngine.ctBox)					'ctCirlce, ctBox, ctBound
		zoneBox.SetParent(player)						'Set parent so zone box will follow player movement
				
		'Create enemy 
		enemy = fE.CreateCircle(10, cw, (ch-ch/4)-10)		'(radius, width, height)
		enemy.SetColor(220,20,60)							'Crimson
		enemy.SetID(2)
		enemy.SetSpeed(-8, 90)
		enemy.SetColGroup(grpEnemy)							'Set collision group
		enemy.SetColWith(grpPlayer, True)					'Set collision with player

		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		If KeyHit( KEY_CLOSE ) fE.ExitApp()
		' Determine the delta time and the update factor for the engine
		Local d:Float = Float(fE.CalcDeltaTime())/60.0

		' Update all objects of the engine
		If fE.GetPaused() = False Then
			fE.Update(d)
		 	
		 	'- Check for collisions of objects -
        	fE.CollisionCheck()
		Endif
			
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Check if the engine is not paused
		If fE.GetPaused() = False Then
			' Clear the screen 
			Cls(135,206,235) 	'Sky blue background
		
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
	Method OnObjectCollision:Int(obj:ftObject, obj2:ftObject)
		' This method is called when an object collided with another object
		
		_g.health.SetWidth(_g.health.GetWidth() - 40)	'Reduce health
		_g.enemy.SetColWith(_g.grpPlayer, False)		'Disable enemy collisions with player
		_g.enemy.CreateTimer(0, 600, 0)			'After 600 msecs peform "OnOjectTimer" code to re-enable collisions
		
		Return 0
	End
	'------------------------------------------
	Method OnObjectTimer:Int(timerId:Int, obj:ftObject)
		' This method is called when an objects' timer was being fired
				
		_g.enemy.SetColWith(_g.grpPlayer, True)			'Enable enemy collisions with player
		
		Return 0
	End	
	'------------------------------------------
	Method OnObjectUpdate:Int(obj:ftObject)
		' This method is called when an object finishes its update

		'If health
		If obj.GetID() = 0
			If obj.GetWidth() <= 0				'When health is less than or equal to zero
				Print("~n     GAME OVER!!")		'Print in debug window
				_g.fE.SetPause(True)			'Pause game
			Endif		
		Endif
		
		'If player
		If obj.GetID() = 1
			'Jump
			If KeyDown(KEY_UP) 
				If obj.GetPosY() >= _g.playerY		'If player at or above ground
					obj.SetSpeedY(-10)				'Move player up
				Endif
			Endif
			
			'Fall
			If obj.GetPosY() <= (_g.playerY - 60)	'If player jump height is reached
				obj.SetSpeedY(10)					'Move player down
			Endif
			
			'Stop
			If obj.GetPosY() > _g.playerY			'If player below ground
				obj.SetPosY(_g.playerY)				'Stop movement at ground
			Endif
		Endif	
		
		'If enemy
		If obj.GetID() = 2
			If obj.GetPosX() <= 0								'If enemy is off screen
				obj.SetColor(Rnd(220, 255) ,Rnd(20, 255) ,Rnd(60, 255))			'Set random enemy color
				obj.SetPosX(_g.cw)							'Reset enemy start position
				obj.SetSpeed(Rnd (-8, -14), 90)						'Set random enemy speed
			Endif
		Endif
		
		'If cloud
		If obj.GetID() = 3
			If obj.GetPosX() <= -100					'If cloud is off screen
				obj.SetPosX(_g.cw + 100)				'Reset cloud start position
				obj.SetSpeed(Rnd (-0.8, -3.6), 90)		'Set random cloud speed
			Endif
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
