Strict

#rem
	Script:			SortObjects.monkey
	Description:	Sample script that shows how so sort objects inside a layer
	Author: 		Michael Hartlef
	Version:      	1.04
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
	
	' Create a field for a new layer
	Field myLayer:ftLayer
	
	' Create a field for a player controllable circle object
	Field myCircle:ftObject

	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate to 60 FPS.
		SetUpdateRate(60)
		
		' Create an instance of the fantomEngine, which was created via the engine class
		eng = New engine
		
		' Create the myLayer layer and set it as the default layer for new objects
		myLayer = eng.CreateLayer()
		eng.SetDefaultLayer(myLayer)

		' Create a yellow circle that moves with the mouse cursor
		myCircle = eng.CreateCircle(30, eng.GetCanvasWidth()/2, eng.GetCanvasHeight()/2)
		myCircle.SetColor(255,255,0)
				
		' Create a red box that doesn't move
		Local myBox := eng.CreateBox(130, 20, eng.GetCanvasWidth()/2, eng.GetCanvasHeight()/2)
		myBox.SetColor(255,0,0)

		
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' Determine the delta time and the update factor for the engine
		Local d:Float = Float(eng.CalcDeltaTime())/60.0
		
		' Check if the app is not suspended
		If eng.GetPaused() = False Then
		
			' Move the circle to the mouse position
			myCircle.SetPos(eng.GetTouchX(), eng.GetTouchY())
		
			' Update all objects of the engine
			eng.Update(d)
			
			' Sort all objects in the myLayer layer.
			myLayer.SortObjects()
			
		Endif
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
	'------------------------------------------
	Method OnObjectSort:Int(obj1:ftObject, obj2:ftObject)
		' This method is called when objects are compared during a sort of its layer list
		
		' We compare the bottom (yPos+Height/2) of each object, the ones with a smaller result will
		' be sort infront of the other object and so appear behind the over object.
		If (obj1.yPos + obj1.GetHeight()/2) < (obj2.yPos + obj2.GetHeight()/2) Then 
			Return False
		Else
			Return True
		Endif
	End	
End

'***************************************
Function Main:Int()
	' Create an instance of the game class and store it inside the global var 'g'
	g = New game
	
	Return 0
End
