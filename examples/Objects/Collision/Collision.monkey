Strict

#rem
	Script:			Collision.monkey
	Description:	Sample script to show how to do collisions
	Author: 		Michael Hartlef
	Version:      	1.15
#End

' Set the AutoSuspend functionality to TRUE so OnResume/OnSuspend are called
#MOJO_AUTO_SUSPEND_ENABLED=True

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
	
	' Create a field for the default scene and layer of the engine
	Field defLayer:ftLayer
	Field defScene:ftScene
	
	Field box:ftObject
	Field box2:ftObject
	Field circle:ftObject
	
	Const grpCircle:Int = 1
	Const grpBox:Int = 2
	Const grpBox2:Int = 3
	
	
	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate events to be determined by the devices refresh rate.
		SetUpdateRate(0)
		
		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine
		
		' Get the default scene of the engine
		defScene = fE.GetDefaultScene()

		' Get the default layer of the engine
		defLayer = fE.GetDefaultLayer()
		
		Local colScale:Float = 1.3
		
		' Create a simple circle
		circle = fE.CreateCircle(40,fE.GetCanvasWidth()/2-50,fE.GetCanvasHeight()/2)
		circle.SetColGroup(grpCircle)
		circle.SetColType(ftEngine.ctCircle)
		circle.SetColWith(grpBox,True)
		circle.SetColWith(grpBox2,True)
		circle.ActivateRenderEvent(True)
		circle.SetColor(255,0,0)
		circle.SetAlpha(0.5)
		circle.SetScale(0.5)
		circle.SetColScale(colScale)
						
		' Create a simple box
		box = fE.CreateBox(80,80,fE.GetCanvasWidth()/2+50,fE.GetCanvasHeight()/2)
		box.SetColGroup(grpBox)
		box.SetColType(ftEngine.ctBox)
		box.SetColor(255,50,0)
		box.ActivateRenderEvent(True)
		box.SetAlpha(0.5)
		box.SetScale(0.7)
		box.SetColScale(colScale)
		
		' Create a simple box
		box2 = fE.CreateBox(80,80,fE.GetCanvasWidth()/2,fE.GetCanvasHeight()/2+100)
		box2.SetColGroup(grpBox2)
		box2.SetColType(ftEngine.ctBox)
		box2.SetColor(0,255,0)
		box2.ActivateRenderEvent(True)
		box2.SetColWith(grpBox,True)
		box2.SetScale(1.2)
		box2.SetAlpha(0.5)
		box2.SetColScale(colScale)

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
			box2.SetPos(fE.GetTouchX(), fE.GetTouchY()) 
			If KeyDown(KEY_RIGHT) Then circle.SetPosX(0.5,True)
			If KeyDown(KEY_LEFT) Then circle.SetPosX(-0.5,True)
			fE.CollisionCheck()
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
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnLoading:Int()
		' If loading of assets in OnCreate takes longer, render a simple loading screen
		fE.RenderLoadingBar()
		
		Return 0
	End
	'------------------------------------------
	Method OnResume:Int()
		' Set the pause flag of the engine to FALSE so objects, timers and transitions are updated again
		fE.SetPaused(False)
		
		Return 0
	End
	'------------------------------------------
	Method OnSuspend:Int()
		' Set the pause flag of the engine to TRUE so objects, timers and transitions are paused (not updated)
		fE.SetPaused(True)
		
		Return 0
	End
End	

'***************************************
' The cEngine class extends the ftEngine class to override the On... methods
Class cEngine Extends ftEngine
	'------------------------------------------
	Method OnObjectCollision:Int(obj:ftObject, obj2:ftObject)
		' This method is called when an object collided with another object
		obj2.SetAngle(0.5,True)
		Return 0
	End
	'------------------------------------------
	Method OnObjectRender:Int(obj:ftObject)
		' This method is called when an object was being rendered. You need to activate the event via ftObject.ActivateRenderEvent.
		SetColor(255,255,255)
		'If KeyDown(KEY_C) 
			If obj.GetColType() = ftEngine.ctCircle 
				SetAlpha(0.6)
				DrawCircle(obj.GetPosX(), obj.GetPosY(), obj.GetRadius() * obj.collScale)
				'DrawCircle(obj.GetPosX(), obj.GetPosY(), obj.GetRadius())
			Else
				DrawLine(obj.GetPosX()+obj.x1c * obj.collScale, obj.GetPosY()+obj.y1c * obj.collScale, obj.GetPosX()+obj.x2c * obj.collScale, obj.GetPosY()+obj.y2c * obj.collScale)
				DrawLine(obj.GetPosX()+obj.x2c * obj.collScale, obj.GetPosY()+obj.y2c * obj.collScale, obj.GetPosX()+obj.x3c * obj.collScale, obj.GetPosY()+obj.y3c * obj.collScale)
				DrawLine(obj.GetPosX()+obj.x3c * obj.collScale, obj.GetPosY()+obj.y3c * obj.collScale, obj.GetPosX()+obj.x4c * obj.collScale, obj.GetPosY()+obj.y4c * obj.collScale)
				DrawLine(obj.GetPosX()+obj.x4c * obj.collScale, obj.GetPosY()+obj.y4c * obj.collScale, obj.GetPosX()+obj.x1c * obj.collScale, obj.GetPosY()+obj.y1c * obj.collScale)
				'DrawLine(obj.GetPosX()+obj.x1c, obj.GetPosY()+obj.y1c, obj.GetPosX()+obj.x2c, obj.GetPosY()+obj.y2c)
				'DrawLine(obj.GetPosX()+obj.x2c, obj.GetPosY()+obj.y2c, obj.GetPosX()+obj.x3c, obj.GetPosY()+obj.y3c)
				'DrawLine(obj.GetPosX()+obj.x3c, obj.GetPosY()+obj.y3c, obj.GetPosX()+obj.x4c, obj.GetPosY()+obj.y4c)
				'DrawLine(obj.GetPosX()+obj.x4c, obj.GetPosY()+obj.y4c, obj.GetPosX()+obj.x1c, obj.GetPosY()+obj.y1c)
			Endif
		'Endif
		Self.RestoreAlpha()
		Self.RestoreColor()
		Return 0
	End
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var 'g'
	_g = New cGame
	
	Return 0
End

