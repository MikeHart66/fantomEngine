Strict

#rem
	Script:			DragNDrop.monkey
	Description:	Sample script to show how to drag and drop and object
	Author: 		Michael Hartlef
	Version:      	1.0
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
	
	' Create a field to store the dragged object
	Field dragObj:ftObject
	
	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate to 60 FPS.
		SetUpdateRate(60)
		
		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine
		
		' Now create 25 boxes which we can drag over the screen 
		For Local x:Int = 1 To 5
			For Local y:Int = 1 To 5
				' Create a box randomly on the canvas
				Local dragBox := fE.CreateBox(60,60,Rnd(40,fE.GetCanvasWidth()-80), Rnd(40,fE.GetCanvasHeight()-80))
				' Set its color to a random color
				dragBox.SetColor(Rnd(50,255),Rnd(50,255),Rnd(50,255))
				' Now set the touchmode to a bounding box
				dragBox.SetTouchMode(ftEngine.tmBound)
				' Lastly, set its ID so we can display it when an object is touched
				dragBox.SetID(x*y)
			Next
		Next
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
			' Check if a Touch is currently done
			If TouchDown(0) 
				' If no objected was previously touched/dragged, do a touch check
				If dragObj = Null
					fE.TouchCheck()
				Endif
			Else
				' if no touch is currently done, check if there was a previous touched object
				If dragObj <> Null
					' Display a message about the lost touch
					Print ("Touch lost")
					' Set the dragObj field to null
					dragObj = Null
				Endif
			Endif
			' Call the Update method of the engine so all objects are updated automatically
			' That also calles the ftEngine.OnObject Update method where we position the dragged object
			fE.Update(timeDelta)
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Check if the engine is not paused
		If fE.GetPaused() = False Then
			' Clear the screen 
			Cls 0,0,0
		
			' Render all visible objects of the engine
			fE.Render()
			
			' Draw the current FPS value in the top left corner
			DrawText( "FPS= "+fE.GetFPS(),Int(fE.GetLocalX(10)), Int(fE.GetLocalY(10)))
		Endif
		Return 0
	End
End	

'***************************************
' The cEngine class extends the ftEngine class to override the On... methods
Class cEngine Extends ftEngine

	'------------------------------------------
	Method OnObjectTouch:Int(obj:ftObject, touchId:Int)
		' This method is called when an object was touched
		
		'  Create a local variable to store the return value.
		Local ret:Int = False
		' Check if the touched object wasn't touched previously
		If _g.dragObj <> obj
			' Print out some info
			Print("Object ID="+obj.GetID()+" is touched")
			' Set the general dragObj field to the touched object
			_g.dragObj = obj
			' Set the return value to TRUE so no further TouchCheck will be performed during this frame
			ret = True
		Endif
		Return ret
	End
	'------------------------------------------
	Method OnObjectUpdate:Int(obj:ftObject)
		' This method is called when an object finishes its update. You can deactivate the event via ftObject.ActivateUpdateEvent.
		
		' Check if the obj is the one that is currently dragged
		If _g.dragObj = obj
			' Set its position to the current touch coordinates.
			obj.SetPos(Self.GetTouchX(0), Self.GetTouchY(0)) 
		Endif
		Return 0
	End
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var '_g'
	_g = New cGame
	
	Return 0
End

