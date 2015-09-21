Strict

#rem
	Script:			ScrollingLayers.monkey
	Description:	This fantomEngine sample script shows how to use multiple scrolling layers
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
	' Create a field to store the instance of the cEngine class, which is an instance
	' of the ftEngine class itself
	Field fE:cEngine
	
	'Score canvas width/height
	Field cw:Float = 0.0
	Field ch:Float = 0.0
	
	'Store layers
	Field layerBackground:ftLayer
	Field layerSun:ftLayer
	Field layerMoon:ftLayer
	Field layerClouds:ftLayer
	Field layerMountains:ftLayer
	Field layerTrees:ftLayer

	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate to 60 FPS.
		SetUpdateRate(60)
		
		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine
		
		'Set canvas Width/Height field variables
		cw = fE.canvasWidth
		ch = fE.canvasHeight

		'Print directions in debug window
		Print("Press Left & Right arrows to move through day/night scene.~n")
				
		'Print canvas X & Y in debug window
		Print("Canvas Width (X)  = "+cw)
		Print("Canvas Height (Y) = "+ch)
			
		'Create layers 							** NOTE: Layers are like a sheet of paper you draw on that are laid on top of each other **
		layerBackground = fE.CreateLayer()
		layerSun = fE.CreateLayer()
		layerMoon = fE.CreateLayer()
		layerClouds = fE.CreateLayer()
		layerMountains = fE.CreateLayer()
		layerTrees = fE.CreateLayer()	
				
		'Create background
		fE.SetDefaultLayer(layerBackground)					
		layerBackground.SetID(1)
		
		Local backgroundDay := fE.CreateBox(cw, ch, cw/2, ch/2) 	'(width, height, x, y)
		backgroundDay.SetColor(0,191,255) 							'deep sky blue	'(Red, Green, Blue) 	
																	'RGB Colors:	<a href="http://www.rapidtables.com/web/color/RGB_Color.htm" target="_blank">http://www.rapidtables.com/web/color/RGB_Color.htm</a>
		
			'day/night transition 
		Local backgroundTransition := fE.CreateBox(cw/4, ch, cw, ch/2)
		backgroundTransition.SetColor(70,130,180)						'steel blue
		backgroundTransition.SetAlpha(0.2)
		
			'night background
		Local backgroundNight := fE.CreateBox(cw, ch, cw+cw/2, ch/2)
		backgroundNight.SetColor(25,25,112)								'midnight blue

		'Create sun
		fE.SetDefaultLayer(layerSun)
		layerSun.SetID(2)
		layerSun.SetAlpha(0.9)
		
		Local sun := fE.CreateCircle(80, cw/2, ch/4)		'(radius, x, y)
		sun.SetColor(255,255,0)								'yellow
		
		'Create moon
		fE.SetDefaultLayer(layerMoon)
		layerMoon.SetID(3)
		layerMoon.SetAlpha(0.8)
		
		Local moon := fE.CreateCircle(60, cw/2, ch*2)
		moon.SetColor(224,255,255)							'light cyan
		
		'Create clouds
		fE.SetDefaultLayer(layerClouds)
		layerClouds.SetID(4)
		layerClouds.SetAlpha(0.5)

		Local cloud1 := fE.CreateCircle(40, cw/2, ch/3)
		Local cloud2 := fE.CreateCircle(30, cw/2-40, ch/3)
		Local cloud3 := fE.CreateCircle(30, cw/2+40, ch/3)
		Local cloud4 := fE.CreateCircle(40, (cw/2)*2, ch/3-20)		
		Local cloud5 := fE.CreateCircle(30, (cw/2)*2-40, ch/3-20)
		Local cloud6 := fE.CreateCircle(30, (cw/2)*2+40, ch/3-20)
		Local cloud7 := fE.CreateCircle(40, cw*2, ch/3-20)		
		Local cloud8 := fE.CreateCircle(30, cw*2-40, ch/3-20)
		Local cloud9 := fE.CreateCircle(30, cw*2+40, ch/3-20)
		Local cloud10 := fE.CreateCircle(40, cw*3, ch/2)		
		Local cloud11 := fE.CreateCircle(30, cw*3-40, ch/2)
		Local cloud12 := fE.CreateCircle(30, cw*3+40, ch/2)
				
		cloud1.SetColor(224,255,255)		'light cyan
		cloud2.SetColor(248,248,255)		'ghost white
		cloud3.SetColor(248,248,255)
		cloud4.SetColor(224,255,255)
		cloud5.SetColor(248,248,255)
		cloud6.SetColor(248,248,255)
		cloud7.SetColor(224,255,255)
		cloud8.SetColor(248,248,255)
		cloud9.SetColor(248,248,255)
		cloud10.SetColor(224,255,255)
		cloud11.SetColor(248,248,255)
		cloud12.SetColor(248,248,255)
						
		'Create mountains
		fE.SetDefaultLayer(layerMountains)
		layerMountains.SetID(5)
		
		Local mount1 := fE.CreateBox(cw/4, ch/2, cw/2, ch)
		Local mount2 := fE.CreateBox(cw/3, ch/3, cw/2, ch)
		Local mount3 := fE.CreateBox(cw/2, ch/4, cw/2, ch)
		Local mount4 := fE.CreateBox(cw/4, ch/2, cw+cw/2, ch)
		Local mount5 := fE.CreateBox(cw/3, ch/3, cw+cw/2, ch)
		Local mount6 := fE.CreateBox(cw/2, ch/4, cw+cw/2, ch)	
		Local mountBase := fE.CreateBox(cw*3, ch/16, cw, ch)	
		
		mount1.SetColor(205,133,63)			'peru
		mount2.SetColor(160,82,45)			'sienna
		mount3.SetColor(205,133,63)
		mount4.SetColor(160,82,45)
		mount5.SetColor(205,133,63)
		mount6.SetColor(160,82,45)
		mountBase.SetColor(139,69,19)		'saddle brown
		
		'Create trees
		fE.SetDefaultLayer(layerTrees)
		layerTrees.SetID(6)
		
		Local trunk1 := fE.CreateBox(cw/80, ch/10, cw/2, ch)
		Local trunk2 := fE.CreateBox(cw/80+2, ch/10+10, cw/2-50, ch)
		Local trunk3 := fE.CreateBox(cw/80, ch/10, cw, ch)
		Local trunk4 := fE.CreateBox(cw/80+2, ch/10+10, cw+cw/2, ch)
		Local trunk5 := fE.CreateBox(cw/80, ch/10, cw+cw/2+50, ch)
		Local trunk6 := fE.CreateBox(cw/80+2, ch/10+10, cw*2, ch)
		Local trunk7 := fE.CreateBox(cw/80, ch/10, cw*3, ch)
		Local trunk8 := fE.CreateBox(cw/80+2, ch/10+10, cw*3-50, ch)
		Local trunk9 := fE.CreateBox(cw/80, ch/10, cw*4, ch)
		Local trunk10 := fE.CreateBox(cw/80+2, ch/10+10, cw*4+50, ch)
		
		Local leaves1 := fE.CreateCircle(15, cw/2, ch-35)
		Local leaves2 := fE.CreateCircle(18, cw/2-50, ch-45)
		Local leaves3 := fE.CreateCircle(15, cw, ch-35)
		Local leaves4 := fE.CreateCircle(18, cw+cw/2, ch-45)
		Local leaves5 := fE.CreateCircle(15, cw+cw/2+50, ch-35)	
		Local leaves6 := fE.CreateCircle(18, cw*2, ch-45)	
		Local leaves7 := fE.CreateCircle(15, cw*3, ch-35)
		Local leaves8 := fE.CreateCircle(18, cw*3-50, ch-45)
		Local leaves9 := fE.CreateCircle(15, cw*4, ch-35)
		Local leaves10 := fE.CreateCircle(18, cw*4+50, ch-45)
		
		trunk1.SetColor(222,184,135)		'burly wood
		trunk2.SetColor(210,180,140)		'tan
		trunk3.SetColor(222,184,135)
		trunk4.SetColor(210,180,140)
		trunk5.SetColor(222,184,135)
		trunk6.SetColor(210,180,140)
		trunk7.SetColor(222,184,135)
		trunk8.SetColor(210,180,140)
		trunk9.SetColor(222,184,135)
		trunk10.SetColor(210,180,140)
				
		leaves1.SetColor(34,139,34)			'forest green
		leaves2.SetColor(0,128,0)			'green
		leaves3.SetColor(34,139,34)
		leaves4.SetColor(0,128,0)
		leaves5.SetColor(34,139,34)
		leaves6.SetColor(0,128,0)
		leaves7.SetColor(34,139,34)
		leaves8.SetColor(0,128,0)
		leaves9.SetColor(34,139,34)
		leaves10.SetColor(0,128,0)
		
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
	Method OnLayerTransition:Int(transId:Int, layer:ftLayer)
		' This method is called when a layer finishes its transition
		Return 0
	End
	'------------------------------------------
	Method OnLayerUpdate:Int(layer:ftLayer)
		' This method is called when a layer finishes its update

		If KeyDown(KEY_LEFT)
			If layer.GetID() = 1  
			layer.SetPosX(0.4, True)	
			Endif
			If layer.GetID() = 2
			layer.SetPosY(-0.5, True)
			Endif
			If layer.GetID() = 3
			layer.SetPosY(0.5, True)
			Endif
			If layer.GetID() = 4
			layer.SetPosX(1.0, True)
			Endif
			If layer.GetID() = 5
			layer.SetPosX(0.6, True)
			Endif
			If layer.GetID() = 6
			layer.SetPosX(1.5, True)
			Endif
		Endif

		If KeyDown(KEY_RIGHT)
			If layer.GetID() = 1
			layer.SetPosX(-0.4, True)
			Endif
			If layer.GetID() = 2
			layer.SetPosY(0.5, True)
			Endif
			If layer.GetID() = 3
			layer.SetPosY(-0.5, True)
			Endif
			If layer.GetID() = 4
			layer.SetPosX(-1.0, True)
			Endif
			If layer.GetID() = 5
			layer.SetPosX(-0.6, True)
			Endif
			If layer.GetID() = 6
			layer.SetPosX(-1.5, True)
			Endif
		Endif		
		Return 0
	End	
	'------------------------------------------
	Method OnObjectCollision:Int(obj:ftObject, obj2:ftObject)
		' This method is called when an object collided with another object
		Return 0
	End
	'------------------------------------------
	Method OnObjectRender:Int(obj:ftObject)
		' This method is called when an object was being rendered
		Return 0
	End
	'------------------------------------------
	Method OnObjectSort:Int(obj1:ftObject, obj2:ftObject)
		' This method is called when objects are compared during a sort of its layer list
		Return 0
	End	
	'------------------------------------------
	Method OnObjectTimer:Int(timerId:Int, obj:ftObject)
		' This method is called when an objects' timer was being fired
		Return 0
	End	
	'------------------------------------------
	Method OnObjectTouch:Int(obj:ftObject, touchId:Int)
		' This method is called when an object was touched
		Return 0
	End
	'------------------------------------------
	Method OnObjectTransition:Int(transId:Int, obj:ftObject)
		' This method is called when an object finishes its transition
		Return 0
	End
	'------------------------------------------
	Method OnObjectUpdate:Int(obj:ftObject)
		' This method is called when an object finishes its update
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