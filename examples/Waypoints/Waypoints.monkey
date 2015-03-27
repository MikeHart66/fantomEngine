
Strict

#rem
	Script:			Waypoints.monkey
	Description:	Example script on how to use waypoints 
	Author: 		Michael Hartlef
	Version:      	1.03
#End

' Set the AutoSuspend functionality to TRUE so OnResume/OnSuspend are called
#MOJO_AUTO_SUSPEND_ENABLED=True

' Import the fantomEngine framework which imports mojo itself
Import fantomEngine

' The g variable holds an instance to the game class
Global g:game

'***************************************
' The game class controls the app
Class game Extends App
    ' Create a field to store the instance of the engine class, which is an instance
    ' of the ftEngine class itself
	Field eng:engine
	
	' Create a field for a waypoint path
	Field path:ftPath
	
	' Create a path marker, that object that runs along a path
	Field mk:ftMarker

	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate events to be determined by the devices refresh rate.
		SetUpdateRate(0)
		
		' Create an instance of the fantomEngine, which was created via the engine class
		eng = New engine
		
		' Now set the virtual canvas size
		eng.SetCanvasSize(800,600)
		
		' Now create a path with its origin at the center of the canvas
	    path = eng.CreatePath(eng.GetCanvasWidth()/2, eng.GetCanvasHeight()/2)

	    
		' Create 4 waypoints
		path.AddWP( -150,-150, True)
		path.AddWP( 150,-150, True)
		path.AddWP( 150,150, True)
		path.AddWP( -150,150, True)
		
		' Create a marker
		mk = path.CreateMarker()
		
		' Connect a new image object to the marker
		mk.ConnectObj(eng.CreateImage("CarSprite.png",0,0))
		
		' Let the marker circle around the path
		mk.SetMoveMode(path.mmCircle)
		
		' Set its interpolation mode to CatMull Rom spline
		mk.SetInterpolationMode(path.imCatmull)

		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' Determine the delta time and the update factor for the engine
		Local d:Float = Float(eng.CalcDeltaTime())/60.0
		
		' Update all objects of the engine
		eng.Update(d)

		' Check if the engine is not paused
		If eng.GetPaused() = False Then
			' Update all path marker and their connected objects
			path.UpdateAllMarker(d*10)

			' Scale the path when you press the Q or A key
			If KeyDown(KEY_Q) Then 
				path.SetScale(-0.01,-0.01,True)
			Endif
			If KeyDown(KEY_A) Then 
				path.SetScale(0.01,0.01,True)
			Endif

			' Move the path when you press the UP/DOWN key
			If KeyDown(KEY_UP) Then 
				path.SetPos(0,-1,True)
			Endif
			If KeyDown(KEY_DOWN) Then 
				path.SetPos(0,1,True)
			Endif

			' Turn the path when you press the RIGHT/LEFT key
			If KeyDown(KEY_RIGHT) Then 
				path.SetAngle(0.5,True)
			Endif
			If KeyDown(KEY_LEFT) Then 
				path.SetAngle(-0.5,True)
			Endif

		Endif
		' End the app when you press the ESCAPE key		
		If KeyHit(KEY_ESCAPE) Then eng.ExitApp
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Check if the engine is not paused
		If eng.GetPaused() = False Then
			' Clear the screen 
			Cls 
		
			' Render the waypoints of the path
			SetColor(0,0,255)
			path.RenderAllWP()

			' Render all visible objects of the engine
			eng.Render()
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnResume:Int()
		' Set the state of the app being not suspended
		eng.SetPaused(False)
		Return 0
	End
	'------------------------------------------
	Method OnSuspend:Int()
		' Set the state of the app being suspended
		eng.SetPaused(True)
		Return 0
	End
End	

'***************************************
' The engine class extends the ftEngine class to override the On... methods
Class engine Extends ftEngine
	'------------------------------------------
	Method OnMarkerCircle:Int(marker:ftMarker, obj:ftObject)
		Print ("One round is finished")
		Return 0
	End
	

End

'***************************************
Function Main:Int()
	' Create an instance of the game class and store it inside the global var 'g'
	g = New game
	
	Return 0
End
