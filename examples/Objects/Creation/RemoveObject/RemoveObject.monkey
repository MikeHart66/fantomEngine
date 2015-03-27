Strict

#rem
	Script:			RemoveObject.monkey
	Description:	Sampe script that shows how to remove objects 
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
	
	Field delCount:Int = 0
	Field layerNo:Int =1
	Field layer2:ftLayer
	Field layer1:ftLayer
	
	'------------------------------------------
	Method SpawnObjects:Void(anz:Int=100)
		If layerNo = 1 Then
			eng.SetDefaultLayer(layer1)
			layerNo = 2
		Else
			eng.SetDefaultLayer(layer2)
			layerNo = 1
		Endif
		For Local i:=1 To anz
			'Local obj := eng.CreateCircle(10,Rnd(eng.GetCanvasWidth()), Rnd(eng.GetCanvasHeight()))
			Local obj := eng.CreateImage("cratesmall.png",Rnd(eng.GetCanvasWidth()), Rnd(eng.GetCanvasHeight()))
			For Local i:=1 To 3
				'Local obj2 := eng.CreateCircle(5,Rnd(eng.GetCanvasWidth()), Rnd(eng.GetCanvasHeight()))
				Local obj2 := eng.CreateImage("cratesmall.png",Rnd(eng.GetCanvasWidth()), Rnd(eng.GetCanvasHeight()))
				obj2.SetParent(obj)
				obj2.SetScale(Rnd(0.5)+0.5)
			Next
		Next
	End
	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate events to be determined by the devices refresh rate.
		SetUpdateRate(0)
		
		' Create an instance of the fantomEngine, which was created via the engine class
		eng = New engine
		
		layer1 = eng.GetDefaultLayer()
		layer2 = eng.CreateLayer()
		
		SpawnObjects()
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' Determine the delta time and the update factor for the engine
		Local d:Float = Float(eng.CalcDeltaTime())/60.0
		
		' Check if the app is not suspended
		If eng.GetPaused() = False Then
			' Update all objects of the engine
			delCount = 0
			eng.Update(d)
			SpawnObjects()
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
			DrawText("objects1="+layer1.GetObjCount(),20,20)
			DrawText("objects2="+layer2.GetObjCount(),20,40)
			DrawText("FPS="+eng.GetFPS(),20,60)
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
	Method OnObjectUpdate:Int(obj:ftObject)
		' This method is called when an object finishes its update
		g.delCount = g.delCount + 1
		If g.delCount < 10001 Then obj.Remove()
		
		Return 0
	End

End

'***************************************
Function Main:Int()
	' Create an instance of the game class and store it inside the global var 'g'
	g = New game
	
	Return 0
End
