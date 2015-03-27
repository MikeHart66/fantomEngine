Strict

#rem
	Script:			TexturePacker.monkey
	Description:	Example script on how To use packed texture images created by the tool TexturePacker 
	Author: 		Michael Hartlef
	Version:      	1.04
#end

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

	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate events to be determined by the devices refresh rate.
		SetUpdateRate(0)
		
		' Create an instance of the fantomEngine, which was created via the engine class
		eng = New engine
		
		' Set the virtual canvas size to 320x480 and the canvas scale mode to letter box
		eng.SetCanvasSize(320,480,ftEngine.cmLetterbox)
		
		' Load the packed texture atlas
		Local tpatlas:Image = LoadImage("td_spritesheet.png")
		
		' Load the packed texture atlas via ftSpriteAtlas class
		Local tpatlas2:ftSpriteAtlas = New ftSpriteAtlas
		tpatlas2.Load("td_spritesheet.png", "td_spritesheet.txt")
		
		' Create several objects
		Local myObject0:ftObject = eng.CreateBox(eng.GetCanvasWidth(), eng.GetCanvasHeight(), eng.GetCanvasWidth()/2, eng.GetCanvasHeight()/2) 
		myObject0.SetColor(0,0,155)
		
		Local myObject1:ftObject = eng.CreateImage(tpatlas, "td_spritesheet.txt", "gold", 0, 0) 
		Local myObject2:ftObject = eng.CreateImage(tpatlas2.GetImage("gold"), eng.GetCanvasWidth(), 0) 
		Local myObject3:ftObject = eng.CreateImage(tpatlas2.GetImage("gold"), 0, eng.GetCanvasHeight()) 
		Local myObject4:ftObject = eng.CreateImage(tpatlas, "td_spritesheet.txt", "gold", eng.GetCanvasWidth(), eng.GetCanvasHeight()) 
		
		Local myObject5:ftObject = eng.CreateImage(tpatlas, "td_spritesheet.txt", "turretbase", eng.GetCanvasWidth()/2, eng.GetCanvasHeight()/2) 
		myObject5.SetSpin(1)
		
		Local myObject5b:ftObject = eng.CreateImage(tpatlas2.GetImage("turretbase"), eng.GetCanvasWidth()/2, eng.GetCanvasHeight()/2) 
		'Set the render area of an Object
		myObject5b.SetRenderArea(0,0,64,64)
		'Set its color
		myObject5b.SetColor(205,50,205)
		'Make it spin automatically 
		myObject5b.SetSpin(-1)
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' Determine the delta time and the update factor for the engine
		Local d:Float = Float(eng.CalcDeltaTime())/60.0
		
		' Update all objects of the engine
		eng.Update(d)
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Check if the app is not suspended
		If eng.GetPaused() = False Then
			' Clear the screen 
			Cls 
		
			' Render all visible objects of the engine
			eng.Render()
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnResume:Int()
		' Set the pause flag of the engine to FALSE so objects, timers and transitions are updated again
		eng.SetPaused(false)
		Return 0
	End
	'------------------------------------------
	Method OnSuspend:Int()
		' Set the pause flag of the engine to TRUE so objects, timers and transitions are paused (not updated)
		eng.SetPaused(True)
		Return 0
	End

End	

'***************************************
' The engine class extends the ftEngine class to override the On... methods
Class engine Extends ftEngine
	' No On.. callback methods are used in this example
End

'***************************************
Function Main:Int()
	g = New game
	Return 0
End
