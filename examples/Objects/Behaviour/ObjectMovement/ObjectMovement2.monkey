Strict

#Rem
	Script:			ObjectMovement2.monkey
	Description:	Sample script that shows how to control your objects at runtime 
	Author: 		Michael Hartlef
	Version:      	1.03
#End

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
	
	' Create a list to store the shots in
	Field shotList := New List<ftObject>
	
	' Create two fields that store the width and height of the canvas
	Field cw:Float
	Field ch:Float

	'------------------------------------------
	' The SpawnShot method will create a new shot. It sets its ID , positions it 
	' infront of the canon and set its speed and heading reagrding the angle of the 
	' canon.
	Method SpawnShot:Int()
		' Create a shot in the middle of the screen
		Local shot:ftObject = fE.CreateCircle(5,cw/2, ch/2)
		
		' Set the tag of a shot
		shot.SetTag(Int(Rnd(1,5)))
		
		' Set the speed and the angle of the shot
		shotList.AddLast(shot)
		
		Return 0
	End
	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate to 60 FPS.
		SetUpdateRate(60)
		
		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine
		
		' Determine and store the width and height of the canvas
		cw = fE.GetCanvasWidth()
		ch = fE.GetCanvasHeight()
		
		' Output some info
		Print ("Press SPACE to release a shot")
		
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' Determine the delta time and the update factor for the engine
		Local d:Float = Float(fE.CalcDeltaTime())/60.0
		
		' Update all shots depending on their tag value
		For Local obj := Eachin shotList
			If obj.GetTag() = 1 Then obj.SetPos(-2,0,True)
			If obj.GetTag() = 2 Then obj.SetPos(2,0,True)
			If obj.GetTag() = 3 Then obj.SetPos(0,-2,True)
			If obj.GetTag() = 4 Then obj.SetPos(0,2,True)
		Next 
		
		' Update all objects of the engine
		fE.Update(d)
		
		' If the SPACE key was pressed, spwan a new shot
		If KeyHit(KEY_SPACE) Then SpawnShot()

		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Clear the screen 
		Cls 
		
		' Render all visible objects of the engine
		fE.Render()
		
		Return 0
	End
End	

'***************************************
' The cEngine class extends the ftEngine class to override the On... methods
Class cEngine Extends ftEngine
	' No On.. callback methods are used in this example
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var 'g'
	_g = New cGame
	Return 0
End
