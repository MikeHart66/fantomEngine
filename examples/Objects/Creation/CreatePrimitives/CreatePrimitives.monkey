Strict

#rem
	Script:			CreatePrimitives.monkey
	Description:	This fantomEngine sample script shows how to create the following:
					box, circle, polygon, oval, point, stickman (with visable bound box), line
	Author: 		Douglas Williams
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
	
	'Store canvas width/height
	Field cw:Float = 0.0
	Field ch:Float = 0.0
	
	'Store stickMan 
	Field stickMan:ftObject		'For storing STICKMAN
	Field stickManY:Float = 0.0	'For storing STICKMAN Y position

	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate events to be determined by the devices refresh rate.
		SetUpdateRate(0)
		
		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine
		
		'Set canvas Width/Height field variables
		cw = fE.canvasWidth
		ch = fE.canvasHeight
		
		'Print directions in debug window
		Print("Press LEFT and RIGHT to move and UP to jump.~n")
		
		'Print canvas X & Y in debug window
		Print("Canvas Width (X)  = "+cw)
		Print("Canvas Height (Y) = "+ch)
		
		'Print info in debug window
		Print("~nOBJECTS ARE DRAWN IN THE FOLLOWING ORDER:")
		Print(" Box      = Canvas Width x Height at middle of canvas")
		Print(" Circle   = 1/2 Canvas Height at middle of canvas")
		Print(" Polygon  = X/Y vertices pairs = 100,232/300,100/480,232/320,300/160,300")
		Print(" Oval     = Width:100, Height:50, at middle of canvas")
		Print(" Point    = At middle of canvas")
		Print(" Stickman = Top Left Corner starts at middle of canvas, Width:8, Height:29")
		Print(" Line     = Below Stickman")

		'Create Box
		Local box := fE.CreateBox(cw, ch, cw/2, ch/2)	'(width, height, x, y)
		box.SetColor(192,192,192)			'Silver
		
		'Create Circle
		Local circle := fE.CreateCircle(ch/2, cw/2, ch/2)	'(radius, x, y)
		circle.SetColor(70,130,180)				'Steel blue

		'Create Oval
		Local oval := fE.CreateOval(100, 50, cw/2, ch/2)	'(width, height, x, y)
		oval.SetColor(218,165,32)				'Golden rod
		
		'Create Polygon 		**** A minimum of 3 x/y pairs are required ****
		'Local poly := fE.CreatePoly( [100.0,232.0, 300.0,100.0, 480.0,232.0, 480.0,248.0, 320.0,300.0, 160.0,300.0], ch/2, cw/2 )
		'Local poly := fE.CreatePoly( [-50.0,0.0, 50.0,0.0, 0.0,50.0 ], cw/2, ch/2 )
		Local poly := fE.CreatePoly( [-50.0,-50.0, 0.0,-75.0, 50.0,-50.0, 50.0,50.0, -50.0,50.0 ], cw/2+100, ch/2+100 )
		poly.SetColor(255,255,224)	'Light yellow
		poly.SetAlpha(0.8)
		poly.SetSpin(3)
	
		'Create point
		Local point := fE.CreatePoint(cw/2, ch/2)	'(x, y)
		point.SetColor(0,0,0)				'Black

		'Create stickman (Top left corner is at x/y with size of width:8 / height:29)
		stickMan = fE.CreateStickMan(cw/2, ch/2)					'(x, y) = Upper left of stickman
		stickMan.SetColor(0,0,0)							'Black
		stickMan.SetID(1)
		stickManY = stickMan.GetPosY()
		stickMan.SetWrapScreenX(True)
		'stickMan.SetSpin(3)
		
		Local boundBox := fE.CreateBox(8, 29, cw/2, ch/2)
		boundBox.SetColor(255,255,255)						'White
		boundBox.SetAlpha(0.3)							'Set alpha to 30%
		boundBox.SetHandle(0.0, 0.0)						'Set handle to top left corner
		boundBox.SetParent(stickMan)
	
		'Create Line (line is left (x/y) to right (x2, y2))
		Local line := fE.CreateLine(0,ch/2+30, cw,ch/2+30)	'(x, y, x2, y2)
		line.SetColor(139,69,19)				'Saddle brown
		
		
		'Create X using 2 lines
		Local leftX := fE.CreateLine(0,0, cw,ch)
		leftX.SetColor(255,255,255)			'White
		leftX.SetAlpha(0.2)				'Set alpha to 20%
		'leftX.SetSpin(-3)
		'leftX.SetHandle(0.0, 0.0)
		
		Local rightX := fE.CreateLine(0,ch, cw,0)
		rightX.SetColor(255,255,255)			'White
		rightX.SetAlpha(0.2)				'Set alpha to 20%
		'rightX.SetSpeed(2)

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
	Method OnObjectUpdate:Int(obj:ftObject)
		' This method is called when an object finishes its update
		
		'If stickMan
		If obj.GetID() = 1

			'Jump
			If KeyDown(KEY_UP) 
				If obj.GetPosY() >= _g.stickManY	'If stickman at or above ground
					obj.SetSpeedY(-10)		'Move stickman up
				Endif
			Endif
			
			'Fall
			If obj.GetPosY() <= (_g.stickManY - 60)		'If stickman jump height is reached
				obj.SetSpeedY(10)			'Move stickman down
			Endif
			
			'Stop
			If obj.GetPosY() > _g.stickManY			'If stickman below ground
				obj.SetPosY(_g.stickManY)		'Stop movement at ground
			Endif
			
			'Move right
			If KeyDown(KEY_RIGHT)
				obj.SetPosX(1, True)
			Endif
			
			'Move left
			If KeyDown(KEY_LEFT)
				obj.SetPosX(-1, True)
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