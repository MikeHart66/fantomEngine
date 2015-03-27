Strict

#rem
	Script:			endlessMap.monkey
	Description:	Sample script that illustrates how to build an endless map
	Author: 		Michael Hartlef
	Version:      	1.0
#End

' Set the AutoSuspend functionality to TRUE so OnResume/OnSuspend are called
#MOJO_AUTO_SUSPEND_ENABLED=True

' Import the fantomEngine framework which imports mojo itself
Import fantomEngine

' The _g variable holds an instance to the cGame class
Global _g:cGame

'***************************************
' The cTile class extends the ftObject class
Class cTile Extends ftObject
	Field xTileOffset:Int 
	'------------------------------------------
	' In this overwritten Udpqte method, the position of the tile
	' will be updated and wrapped in relation to the mapPivot object.
	Method Update:Void(delta:Float=1.0)
		Self.SetPosX(Int(_g.mapPivot.GetPosX()+Self.xTileOffset))
		If (Self.GetPosX()-Self.GetWidth()/2.0) > _g.fE.GetCanvasWidth()  
			Self.SetPosX(-_g.fE.GetCanvasWidth() - Self.GetWidth(),True)
		Endif
	End
End
'***************************************
' The cGame class controls the app
Class cGame Extends App
	' Create a field to store the instance of the cEngine class, which is an instance
	' of the ftEngine class itself
	Field fE:cEngine
	
	' We need a filed to store the mapPivot object
	Field mapPivot:ftObject
	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate events to be determined by the devices refresh rate.
		SetUpdateRate(0)
		
		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine
		' Set a virtual canvas size
		fE.SetCanvasSize(320,240)
		
		' Now create some tiles that wil fill the screen.
		' also store the X offset regarding the mapPivot object
		For Local y:= 0 To fE.GetCanvasHeight() Step 64
			For Local x:= 0 To fE.GetCanvasWidth() Step 64
				Local tile:=fE.CreateBox(64,64,x,y,New cTile)
				Local col:= Rnd(100,200)
				tile.SetColor(col,col,col)
				cTile(tile).xTileOffset = x
			Next
		Next
		
		' Create the mapPivot object. You could create it before the tile objects,
		' but because we want to display its position with a child object, it has to be
		' created afterwards.
		mapPivot = fE.CreatePivot(0,0)
		mapPivot.SetSpeedX(3)
		
		' Create a simple circle as a child of the mapPivot object.
		' This will display the position of the MapPivot object.
		Local circle := fE.CreateCircle(20,0,0)
		circle.SetParent(mapPivot)

		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' If the CLOSE key was hit, exit the app ... needed for GLFW and Android I think. 
		If KeyHit( KEY_CLOSE ) Then fE.ExitApp()
		
		' Determine the delta time and the update factor for the engine
		Local timeDelta:Float = Float(fE.CalcDeltaTime())/60.0

		' Update all objects of the engine
		If fE.GetPaused() = False Then
			fE.Update(timeDelta)
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Check if the engine is not paused
		If fE.GetPaused() = False Then
			' Clear the screen 
			Cls 255,0,255
		
			' Render all visible objects of the engine
			fE.Render()
		Endif
		Return 0
	End
End	

'***************************************
' The cEngine class extends the ftEngine class to override the On... methods
Class cEngine Extends ftEngine
	'------------------------------------------
	Method OnObjectUpdate:Int(obj:ftObject)
		' Check if the mapPivot object left the screen and then wrap it back to the other side.
		' Please note, that we don't use the buildin WrapScreen methods as we want to let it wrap 
		' outside the canvas.
		If obj = _g.mapPivot
			If (obj.GetPosX()-32) > Self.GetCanvasWidth()  
				obj.SetPosX(-Self.GetCanvasWidth() - 64 ,True)
				Print ("privotWrap")
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

