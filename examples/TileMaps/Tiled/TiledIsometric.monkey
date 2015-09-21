Strict

#rem
	Script:			TiledIsometric.monkey
	Description:	Example script on how to use isometric tilemaps created by the tool Tiled
	Author: 		Michael Hartlef
	Version:      	1.01
#end

' Set the AutoSuspend functionality to TRUE so OnResume/OnSuspend are called
#MOJO_AUTO_SUSPEND_ENABLED=True

Import fantomEngine

Global g:game


'***************************************
Class game Extends App
	Field eng:engine
	Field tm:ftObject
	
	Field layerMap:ftLayer
	Field layerGUI:ftLayer
	Field txtInfo1:ftObject
	Field txtInfo2:ftObject
	'------------------------------------------
	Method OnCreate:Int()
		Local c:Int

		' Set the update rate of Mojo's OnUpdate to 60 FPS.
		SetUpdateRate(60)
		' Create an instance of the fantomEngine, which was created via the engine class
		eng = New engine

		'Set the canvas size of a usual Android canvas
		'eng.SetCanvasSize(480,800)
		'eng.SetCanvasSize(1024,768)
		
		'Load the tile map created by Tiled
		tm = eng.CreateTileMap("maps/isometric_grass_and_water.json", 200, 30 )
		
	
	
		'Set its scale factor 
			'tm.SetScale(2)
		'Set the scale mod factor for each tile of the map
			'tm.SetTileSModXY(-0.1,-0.1)

		' Load a bitmap font
		Local font:ftFont = eng.LoadFont("font.txt")

		' Set and create some layers
		layerMap = eng.GetDefaultLayer()
		layerGUI = eng.CreateLayer()
		' Set the GUI flag of the GUI layer so it isn't effected by the camera
		layerGUI.SetGUI(True)
		
	
		' Create some info text objects
		eng.SetDefaultLayer(layerGUI)
		txtInfo1 = eng.CreateText(font,"FPS: 60",10,10, eng.taTopLeft)
		txtInfo1.SetTouchMode(ftEngine.tmBound)
		txtInfo1.SetName("txtInfo1")

		txtInfo2 = eng.CreateText(font,"0:0=0",eng.GetCanvasWidth()-10,eng.GetCanvasHeight()-10, eng.taBottomRight)
		txtInfo2.SetTouchMode(ftEngine.tmBound)
		txtInfo2.SetName("txtInfo2")
		
 		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' Calculate the current delta time for this frame
		Local d:Float = Float(eng.CalcDeltaTime())/60.0
		
		' Determine the current touch/mouse coordinates
		Local x:Int = eng.GetTouchX()
		Local y:Int = eng.GetTouchY()
		
		' Check if the engine is paused
		If eng.GetPaused() = False Then
		
			' Update all objects of the engine
			eng.Update(Float(d))
			
			'Remove a tile when you click left with the mouse
			If MouseHit( MOUSE_LEFT ) Then
				' Do a touchcheck, if object is hit, engine.onObjectTouch is called.
				eng.TouchCheck()
				' Remove the tile 
				tm.SetTileIDAt(x ,y,-1)
			Endif
			
			'Set a random tile when you do a right mouse click
			If MouseHit( MOUSE_RIGHT ) Then
				tm.SetTileIDAt(x, y, Rnd(0,15))
			Endif
			
			'Move the camera with the cursor keys
			If KeyDown(KEY_LEFT) Then eng.SetCamX(-5*d,True)
			If KeyDown(KEY_RIGHT) Then eng.SetCamX(5*d,True)
			If KeyDown(KEY_UP) Then eng.SetCamY(-5*d,True)
			If KeyDown(KEY_DOWN) Then eng.SetCamY(5*d,True)
			
			'Update the info text objects
			txtInfo1.SetText("FPS:"+eng.GetFPS())
			txtInfo2.SetText(x+":"+y+"  tileID="+tm.GetTileIDAt(x,y))
			
	
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		If eng.GetPaused()=False Then
			Cls 100,100,100
			eng.Render()
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnResume:Int()
		eng.SetPaused(False)
		Return 0
	End
	'------------------------------------------
	Method OnSuspend:Int()
		eng.SetPaused(True)
		Return 0
	End
End	

'***************************************
Class engine Extends ftEngine
	'------------------------------------------
	' This method is called when an object was touched.
	Method OnObjectTouch:Int(obj:ftObject, touchId:Int)
		Return 0
	End
End

'***************************************
Function Main:Int()
	g = New game
	Return 0
End
