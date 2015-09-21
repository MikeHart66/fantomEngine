Strict

#rem
	Script:			MultiTileSets.monkey
	Description:	Example script on how to use tilemaps with more than one tile set
	Author: 		Michael Hartlef
	Version:      	1.02
#end

' Set the AutoSuspend functionality to TRUE so OnResume/OnSuspend are called
#MOJO_AUTO_SUSPEND_ENABLED=True

Import fantomEngine

Global g:game


'***************************************
Class game Extends App
	Field fE:cEngine
	Field tm:ftObject
	
	Field layerMap:ftLayer
	Field layerGUI:ftLayer
	Field txtInfo1:ftObject
	Field txtInfo2:ftObject
	Field txtInfo3:ftObject
	Field objCircle:ftObject
	
	Field tileMap:ftTileMap
	'------------------------------------------
	Method OnCreate:Int()
		Local c:Int

		' Set the update rate of Mojo's OnUpdate to 60 FPS.
		SetUpdateRate(60)
		
		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine
		
		'fE.SetCanvasSize(160,240)
		
		'Load the tile map created by Tiled
		tm = fE.CreateTileMap("maps/test_ortho_2tilesets.json", 24, 24 )

		tileMap = tm.GetTileMap()
		
		' Load a bitmap font
		Local font:ftFont = fE.LoadFont("font.txt")

		' Set and create some layers
		layerMap = fE.GetDefaultLayer()
		layerGUI = fE.CreateLayer()
		' Set the GUI flag of the GUI layer so it isn't effected by the camera
		layerGUI.SetGUI(True)
		
		' Create a circle, representing some kind of map object
		fE.SetDefaultLayer(layerGUI)
	
		' Create some info text objects
		fE.SetDefaultLayer(layerGUI)
		txtInfo1 = fE.CreateText(font,"FPS: 60",10,fE.GetCanvasHeight()-10, fE.taBottomLeft)
		txtInfo1.SetTouchMode(ftEngine.tmBound)
		txtInfo1.SetName("txtInfo1")

		txtInfo2 = fE.CreateText(font,"0:0=0",fE.GetCanvasWidth()-10,fE.GetCanvasHeight()-10, fE.taBottomRight)
		txtInfo2.SetTouchMode(ftEngine.tmBound)
		txtInfo2.SetName("txtInfo2")
		
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' Calculate the current delta time for this frame
		Local d:Float = Float(fE.CalcDeltaTime())/60.0
		
		' Determine the current touch/mouse coordinates
		Local x:Int = fE.GetTouchX()
		Local y:Int = fE.GetTouchY()
		
		' Check if the engine is paused
		If fE.GetPaused() = False Then
		
			' Update all objects of the engine
			fE.Update(Float(d))
			
			'Remove a tile when you click left with the mouse
			If MouseHit( MOUSE_LEFT ) Then
				' Do a touchcheck, if object is hit, engine.onObjectTouch is called.
				fE.TouchCheck()
				' Remove the tile 
				tm.SetTileIDAt(x ,y,-1)
			Endif
			
			'Set a random tile when you do a right mouse click
			If MouseHit( MOUSE_RIGHT ) Then
				tm.SetTileIDAt(x, y, Rnd(0,3))
			Endif
			
			'Move the camera with the cursor keys
			If KeyDown(KEY_LEFT) Then fE.SetCamX(-5*d,True)
			If KeyDown(KEY_RIGHT) Then fE.SetCamX(5*d,True)
			If KeyDown(KEY_UP) Then fE.SetCamY(-5*d,True)
			If KeyDown(KEY_DOWN) Then fE.SetCamY(5*d,True)
			
			'Update the info text objects
			txtInfo1.SetText("FPS:"+fE.GetFPS())
			txtInfo2.SetText(x+":"+y+"  tileID="+tm.GetTileIDAt(x,y))
			
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		Local x:Float
		Local y:Float
		Local xp:Float
		Local yp:Float
		Local xOff:Float
		Local yOff:Float
		Local tsX:Float
		Local tsY:Float
		If fE.GetPaused()=False Then
			Cls 40,40,40
			fE.Render()
			xp = tm.GetPosX()
			yp = tm.GetPosY()
			tsX = tileMap.tileSizeX
			tsY = tileMap.tileSizeY
			xOff = tsX * 1/2.0
			yOff = tsY * 1/2.0
			For y = 0 To tileMap.tileCountY-1
				For x = 0 To tileMap.tileCountX-1
					'Vertical
					DrawLine( xp+x*tsX-xOff, yp+y*tsY-yOff, xp+ x   *tsX-xOff, yp+(y+1)*tsY-yOff )
					'Horizontal
					'If x <> (tileMap.tileCountX-1) Then 
					DrawLine( xp+x*tsX-xOff, yp+y*tsY-yOff, xp+(x+1)*tsX-xOff, yp+ y   *tsY-yOff )
				Next
			Next
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnResume:Int()
		fE.SetPaused(False)
		Return 0
	End
	'------------------------------------------
	Method OnSuspend:Int()
		fE.SetPaused(True)
		Return 0
	End
End	

'***************************************
Class cEngine Extends ftEngine
	'------------------------------------------
End

'***************************************
Function Main:Int()
	g = New game
	Return 0
End
