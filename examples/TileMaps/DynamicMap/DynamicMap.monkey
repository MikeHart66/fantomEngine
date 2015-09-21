Strict

#rem
	Script:			DynamicMap.monkey
	Description:	Example script on how to self build a (dynamic) map.
	Author: 		Michael Hartlef
	Version:      	1.08
#end

' Set the AutoSuspend functionality to TRUE so OnResume/OnSuspend are called
#MOJO_AUTO_SUSPEND_ENABLED=True

Import fantomEngine
Global g:game


'***************************************
Class game Extends App
	Field eng:engine
	Field tileMap:ftObject
	Field atlas:Image
	'------------------------------------------
	Method OnCreate:Int()
		Local c:Int

		' Set the update rate of Mojo's OnUpdate to 60 FPS.
		SetUpdateRate(60)

		'Create an instance of the fantomEngine
		eng = New engine

		' Set the canvas size of a usual Android canvas
		eng.SetCanvasSize(320,480)
		
		'Define the tile size and how many tiles the map will have in each direction
		Local tileWidth:Int = 32
		Local tileHeight:Int = 32
		Local tileCountX:Int = 1000
		Local tileCountY:Int = 1000
		
		
		' Load the sprite sheet that contains the tiles of our map. 
		atlas = LoadImage("tilesheet.png" )
		If atlas = Null Then Print ("atlas = null")
		
		' Now create an empty tile map
		tileMap = eng.CreateTileMap(atlas, tileWidth, tileHeight, tileCountX , tileCountY, tileWidth/2.0, tileHeight/2.0 )
		
		' Next randomly build the map
		For Local yt:Int = 1 To tileCountY
			For local xt:Int = 1 To tileCountX
				tileMap.SetTileID(xt-1, yt-1, Rnd(0,15) )
			Next
		Next
	
		' Now add a text for the console
		Print "Use the cursor keys to move the map, and the mouse buttons to delete or randomly set a map tile."
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		Local d:Float = Float(eng.CalcDeltaTime())/60.0
		If eng.GetPaused() = False Then
			
			eng.Update(Float(d))
			'Remove a tile when you click left with the mouse
			If MouseHit( MOUSE_LEFT ) Then
				tileMap.SetTileIDAt(eng.GetTouchX(),eng.GetTouchY(),-1)
			Endif
			'Set a random tile
			If MouseHit( MOUSE_RIGHT ) Then
				tileMap.SetTileIDAt(eng.GetTouchX(),eng.GetTouchY(),Rnd(0,15))
			Endif
			'Move the camera with the cursor keys
			If KeyDown(KEY_LEFT) Then eng.SetCamX(-1,True)
			If KeyDown(KEY_RIGHT) Then eng.SetCamX(1,True)
			If KeyDown(KEY_UP) Then eng.SetCamY(-1,True)
			If KeyDown(KEY_DOWN) Then eng.SetCamY(1,True)
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		Local x:Int = eng.GetTouchX()
		Local y:Int = eng.GetTouchY()
		Cls 0,0,50
		eng.Render()
		'Print some debugging messages like FPS and the tile ID under the mouse cursor
		DrawText("Tile unter mouse at "+x+":"+y+" = "+tileMap.GetTileIDAt(x,y),eng.GetLocalX(20, False),eng.GetLocalY(10, False))
		DrawText("FPS:"+eng.GetFPS(),eng.GetLocalX(20, False),eng.GetLocalY(50, False))
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
	' No On.. callback methods are used in this example
End

'***************************************
Function Main:Int()
	g = New game
	Return 0
End
