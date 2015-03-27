Strict

#rem
	Script:			ParentChild.monkey
	Description:	Sample script to show how to use parent/child relationships.
	Author: 		Michael Hartlef
	Version:      	1.03
#End

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
	
	' Create a field field that hold the parent 
	Field parent:ftObject = Null

	'------------------------------------------
	Method SpawnChild:Void()
		' Create the child, it's a box
		Local child := eng.CreateBox(20, 20, eng.GetCanvasWidth()*(Rnd(0.5)+0.25), eng.GetCanvasHeight()*(Rnd(0.5)+0.25))

		' Connect the child to the parent
		child.SetParent(parent)
		
		' Set a random color for the child
		child.SetColor(Rnd(255), Rnd(255), Rnd(255))
	End
	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate events to be determined by the devices refresh rate.
		SetUpdateRate(0)
		
		' Create an instance of the fantomEngine, which was created via the engine class
		eng = New engine
		
		' Seed the random number generator
		Seed = Millisecs()
		
		' Create the parent
		parent = eng.CreateBox(40,40,eng.GetCanvasWidth()/2,eng.GetCanvasHeight()/2)

		' Create the child and set its parent
		SpawnChild()
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' Determine the delta time and the update factor for the engine
		Local d:Float = Float(eng.CalcDeltaTime())/60.0
		Local child:ftObject = Null

		' If the parent has children, get the first child		
		If parent.GetChildCount()>0 Then
			child = parent.GetChild(1)
		Endif
		
		' Set the parents position accordingly to the mouse coordinates
		parent.SetPos(eng.GetTouchX(), eng.GetTouchY())
		
		' If there is a child, check for the P-Key and disconnect it from the parent
		If child <> Null Then 
			If KeyHit(KEY_P) Then
				If child.GetParent() <> Null Then
					child.SetParent(Null)
				Endif
			Endif
		Endif		
		' If the N-Key was hit, spawn another child
		If KeyHit(KEY_N) Then
			SpawnChild()
		Endif
		' If the Q-Key was hit, scale the parent upwards
		If KeyDown(KEY_Q) Then
			parent.SetScale(0.02,True)
		Endif
		' If the W-Key was hit, scale the parent downpwards
		If KeyDown(KEY_W) Then
			parent.SetScale(-0.02,True)
		Endif
		' If left mouse button was pressed, rotate the parent
		If MouseDown(MOUSE_LEFT)
			parent.SetAngle(2,True)
		Endif
		' If right mouse button was pressed, rotate the parent
		If MouseDown(MOUSE_RIGHT)
			parent.SetAngle(-2,True)
		Endif
		' Update all objects of the engine
		eng.Update(d)
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Clear the screen 
		Cls 
	
		' Render all visible objects of the engine
		eng.Render()
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
	' Create an instance of the game class and store it inside the global var 'g'
	g = New game
	
	Return 0
End
