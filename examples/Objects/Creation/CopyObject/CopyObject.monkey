Strict

#Rem
	Script:			CopyObject.monkey
	Description:	Sample script that shows how To copy an Object with most of its parameters at runtime  
	Author: 		Michael Hartlef
	Version:      	1.03
#End

Import fantomEngine
Global g:game

'***************************************
Class game Extends App
    ' Create a field to store the instance of the engine class, which is an instance
    ' of the ftEngine class itself
	Field eng:engine
	
	' Create two fields that store the width and height of the canvas
	Field cw:Float
	Field ch:Float

	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate events to be determined by the devices refresh rate.
		SetUpdateRate(0)
		
		' Create an instance of the fantomEngine, which was created via the engine class
		eng = New engine
		
		' Determine and store the width and height of the canvas
		cw = eng.GetCanvasWidth()
		ch = eng.GetCanvasHeight()
		
		' Create the 1st object in the middle of the screen
		Local obj1 := eng.CreateBox(20,20, cw/2, ch/2 )

		' Create a child object slightly in the middle of the screen and assign it to the 1st object
		Local childObj1 := eng.CreateBox(10,10, cw/2+40, ch/2+40 )
		childObj1.SetParent(obj1)

		' Copy the 1st object, which creates the 2nd object
		Local obj2 := eng.CopyObject(obj1)
		
		' Set the speed and angle of the 1st object. The second object will stand still
		obj1.SetSpeed(10,Rnd(360))		
		
		' Let the 2nd object spin and scale it up by a factor of 3
		obj2.SetSpin(10)		
		obj2.SetScale(3)

		' Let the 1st object wrap around the screen edges.
		obj1.SetWrapScreen(True)
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
		' Clear the screen 
		Cls 
		
		' Render all visible objects of the engine
		eng.Render()
		
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
