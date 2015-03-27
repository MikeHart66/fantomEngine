Strict

#rem
	Script:		FlashObject2.monkey
	Description:	This sample script shows some ways on how to flash an object 
	Author: 	based on sample from Michael Hartlef, expanded by Douglas Williams 
	Version:      	1.02
#End

' Set the AutoSuspend functionality to TRUE so OnResume/OnSuspend are called
#MOJO_AUTO_SUSPEND_ENABLED=True

' Import the fantomEngine framework which imports mojo itself
Import fantomEngine

' The _g variable holds an instance to the cGame class
Global _g:cGame

'***************************************
Class myObject Extends ftObject
	
	Field frameOnTime:Int = 100
	Field frameOn:Int = 0	

	Method New()
		Self.SetColor(Rnd(50,255), Rnd(50,255), Rnd(50,255))	'Set random color on object
	End
	Method myUpdate:Void()		'--obj4-- & --obj5-- 	'Called from "feEngine.OnObjectUpdate"
		Self.frameOnTime -= 1		
		
		If Self.frameOnTime < 0
			Self.frameOnTime = 100
			Self.frameOn = 1 - Self.frameOn	  '1-1=0 / 1-0=1
		Endif
		
		If Self.frameOn = 1 Then
			Self.SetScale(+0.01,True) 'Expand
		Else
			Self.SetScale(-0.01,True) 'Contract
		Endif
	End
End

'***************************************
' The cGame class controls the app
Class cGame Extends App
	' Create a field to store the instance of the cEngine class, which is an instance
	' of the ftEngine class itself
	Field fE:cEngine
	
	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate events to be determined by the devices refresh rate.
		SetUpdateRate(0)
		
		' Seed the random number generator
		Seed = Millisecs()
		
		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine
		
		' Load a bitmap font
		Local font:ftFont = fE.LoadFont("font.txt")		
		
		' Create some objects and text labels
		 'obj1 - Outer flashing box
		Local obj1 := fE.CreateBox(100, 100, 100, 150, New myObject) '(width, height, x, y, Object)
		obj1.SetID(3)
		obj1.ActivateRenderEvent(True)		'Activates "ftEngine.OnObjectRender"
		obj1.ActivateUpdateEvent(False) 	'Deactivates "ftEngine.OnObjectUpdate" for this object
		
		Local txtObj1 := fE.CreateText(font, "obj1", 100, 150, fE.taCenterCenter)	'(Font, "txt", x, y, alignment)
		txtObj1.ActivateUpdateEvent(False)
		
		 'obj2 - Flashing box
		Local obj2 := fE.CreateBox(100, 100, 300, 150, New myObject)
		obj2.SetID(2)
		obj2.CreateTimer(0, 1000, -1)		'(timerID, duration, repeatCount[-1 = run forever]) 	'Utilizes "ftEngine.OnObjectTimer"
		obj2.ActivateUpdateEvent(False)

		Local txtObj2 := fE.CreateText(font, "obj2", 300, 150, fE.taCenterCenter)	
		txtObj2.ActivateUpdateEvent(False)
		
		 'obj3 - Fade IN and OUT circle
		Local obj3 := fE.CreateCircle(50, 100, 320, New myObject) 	'(radius, x, y, New myObject)
		obj3.CreateTransAlpha(0, 1675, False, 1)			'(transAlpha, duration, relative, transID)  	'Utilizes "ftEngine.OnObjectTransition"
		obj3.ActivateUpdateEvent(False)

		Local txtObj3 := fE.CreateText(font, "obj3", 100, 320, fE.taCenterCenter)	
		txtObj3.ActivateUpdateEvent(False)
		txtObj3.SetAlpha(0.2)
		
		 'obj4 - Shrink and Expand circle
		Local obj4 := fE.CreateCircle(50, 300, 320, New myObject)   
		'obj4.ActivateUpdateEvent(True) 	'Activates "ftEngine.OnObjectUpdate" 	**DEFAULT ACTION command not required**

		Local txtObj4 := fE.CreateText(font, "obj4", 300, 320, fE.taCenterCenter)	
		txtObj4.ActivateUpdateEvent(False)
		txtObj4.SetAlpha(0.2)
		
		 'obj5 - Combine Shrink & Expand with Fade IN & OUT circle
		Local obj5 := fE.CreateCircle(50, 200, 410, New myObject)
		obj5.CreateTransAlpha(0, 1675, False, 1)
		
		Local txtObj5 := fE.CreateText(font, "obj5", 200, 410, fE.taCenterCenter)
		txtObj5.ActivateUpdateEvent(False)
		txtObj5.SetAlpha(0.2)
				
		 'alpha1 - Outer flashing circle
		Local alpha1 := fE.CreateCircle(50, 500, 180, New myObject)
		alpha1.SetID(4)
		alpha1.SetColor(0,255,255)
		alpha1.ActivateRenderEvent(True)
		alpha1.ActivateUpdateEvent(False)
		alpha1.SetAlpha(1.0)
		
		Local txtAlpha1 := fE.CreateText(font, "Alpha=1", 500, 180, fE.taCenterCenter)
		txtAlpha1.ActivateUpdateEvent(False)
		
		 'alphaLess - Flashing alpha from 0.2 to 1.0 circle
		Local alphaLess := fE.CreateCircle(50, 500, 320, New myObject)
		alphaLess.SetColor(0,255,255)
		alphaLess.SetAlpha(0.2)
		alphaLess.SetID(2)
		alphaLess.CreateTimer(0, 1000, -1)
		alphaLess.ActivateUpdateEvent(False)
		
		Local txtAlphaLess := fE.CreateText(font, "Alpha=.2", 500, 320, fE.taCenterCenter)
		txtAlphaLess.ActivateUpdateEvent(False)
		txtAlphaLess.SetAlpha(0.2)
		
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		If KeyHit( KEY_CLOSE ) fE.ExitApp()
		' Determine the delta time and the update factor for the engine
		Local d:Float = Float(fE.CalcDeltaTime())/60.0

		' Update all objects of the engine
		If fE.GetPaused() = False Then
			fE.Update(d)
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Check if the engine is not paused
		If fE.GetPaused() = False Then
			' Clear the screen 
			Cls 
		
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
	Method OnObjectRender:Int(obj:ftObject)		'--obj1-- & --alpha1--
		' This method is called when an object was being rendered
		Local o:myObject = myObject(obj)
		Local px:Float = o.GetPosX()
		Local py:Float = o.GetPosY()
		
		o.frameOnTime -= 1
		If o.frameOnTime < 0
			o.frameOnTime = 60
			o.frameOn = 1 - o.frameOn	'1-1=0 / 1-0=1
		Endif
		
		If o.frameOn = 1 Then
			If o.GetID() = 3 Then	'--obj1--
			DrawLine(px-55, py-55, px+55, py-55)	'Top       '(x1, y1, x2, y2)
			DrawLine(px-55, py+55, px+55, py+55)	'Bottom
			DrawLine(px-55, py-55, px-55, py+55)	'Left
			DrawLine(px+55, py-55, px+55, py+55)	'Right
			Endif
			
			If o.GetID() = 4 Then	'--alpha1--
			DrawCircle(px, py, 60)	'(x, y, radius)
			SetColor(0,0,0)			'Black
			DrawCircle(px, py, 58)
			SetColor(0,255,255)		'Aqua
			DrawCircle(px, py, 50)
			Endif
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnObjectTimer:Int(timerId:Int, obj:ftObject) 
		' This method is called when an objects' timer was being fired
		If obj.GetID() = 2 Then  	'--obj2-- & --alphaLess--
			obj.SetAlpha(1-obj.GetAlpha())
		Endif
		Return 0
	End	
	'------------------------------------------
	Method OnObjectTransition:Int(transId:Int, obj:ftObject) 	'--obj3--
		' This method is called when an object finishes its transition
		obj.CreateTransAlpha(1.0-obj.GetAlpha(), 1675, False,1)	'(transAlpha, duration, relative, transID)
		Return 0
	End
	'------------------------------------------
	Method OnObjectUpdate:Int(obj:ftObject)		'--obj4-- & --obj5--
		' This method is called when an object finishes its update
		myObject(obj).myUpdate()
		Return 0
	End
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var 'g'
	_g = New cGame
	
	Return 0
End
