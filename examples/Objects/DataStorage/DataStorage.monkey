Strict

#Rem
	Script:			DataStorage.monkey
	Description:	Sample script that shows how to store any data inside an Object and use it at runtime  
	Author: 		Michael Hartlef
	Version:      	1.03
#End

Import fantomEngine
Global g:game


'***************************************
' This class will store some user defined data fields for our shot objects.
' Here it is the x/y speed factors for each bullet
Class shotData
	Field xSpeed:Float
	Field ySpeed:Float
End


'***************************************
Class game Extends App
    ' Create a field to store the instance of the engine class, which is an instance
    ' of the ftEngine class itself
	Field eng:engine
	
	' Create a field to store the canon object so we can handle it directly
	Field canon:ftObject
	
	' Create two fields that store the width and height of the canvas
	Field cw:Float
	Field ch:Float

	'------------------------------------------
	' The SpawnShot method will create a new shot. It sets its ID , positions it 
	' infront of the canon and set its speed and heading reagrding the angle of the 
	' canon.
	Method SpawnShot:Int()
	    ' Determine the current angle of the canon
		Local curAngle:Float = canon.GetAngle()
		
		' Determine the vector that is 50 pixels away infront of the canon
		Local pos:Float[] = canon.GetVector(50,curAngle)
		
		' Create a shot in the middle of the screen
		Local shot:ftObject = eng.CreateCircle(5,pos[0], pos[1])
		
		' Create a new shotData object
		Local userData := New shotData
		
		' store the speed values in the data object
		userData.xSpeed = (pos[0] - cw/2) / 10
		userData.ySpeed = (pos[1] - ch/2) / 10
		
		' Set the data object of the shot object
		'shot.SetDataObj(Object(userData))
		shot.SetDataObj(userData)

		' Set its ID to 222 so we can detect it during the OnObjectUpdate event
		shot.SetID(222)
		Return 0
	End
	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate to 60 FPS.
		SetUpdateRate(60)
		
		' Create an instance of the fantomEngine, which was created via the engine class
		eng = New engine
		
		' Determine and store the width and height of the canvas
		cw = eng.GetCanvasWidth()
		ch = eng.GetCanvasHeight()
		
		' Create the canon in the middle of the screen
		canon = eng.CreateBox(20,60, cw/2, ch/2 )
		
		' Set the ID of the canon so it won't be detected as a shot later
		canon.SetID(111)
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' Determine the delta time and the update factor for the engine
		Local d:Float = Float(eng.CalcDeltaTime())/60.0
		
		' Update all objects of the engine
		eng.Update(d)
		
		' If the LEFT key was pressed, turn the canon by 2 degrees left
		If KeyDown(KEY_LEFT) Then canon.SetAngle(-2,True)
		
		' If the RIGHT key was pressed, turn the canon by 2 degrees right
		If KeyDown(KEY_RIGHT) Then canon.SetAngle(2,True)
		
		' If the SPACE key was pressed, spwan a new shot
		If KeyHit(KEY_SPACE) Then SpawnShot()

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
	Method OnObjectUpdate:Int(obj:ftObject)
		' Determine if the object is a shot
		If obj.GetID() = 222 Then
		
			' Get the data object, which holds the speed factors for the shot.		
			Local ud:shotData = shotData(obj.GetDataObj())
			
			'Set the position relatively via the speed factors
		    obj.SetPos(ud.xSpeed, ud.ySpeed, True)
		Endif
		Return 0
	End
End

'***************************************
Function Main:Int()
	g = New game
	Return 0
End
