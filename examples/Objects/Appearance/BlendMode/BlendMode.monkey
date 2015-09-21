Strict

#rem
	Script:			BlendMode.monkey
	Description:	Sample script that shows how To use the blend mode 
	Author: 		Michael Hartlef
	Version:      	1.02
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

	Field p:ftObject
	Field p2:ftObject

	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate to 60 FPS.
		SetUpdateRate(60)
		
		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine
		
		' Create one particle below the squares
		p=fE.CreateImage("particle.png",320,240)

		'Create 4 squares with different colors, alpha values and blendmodes.
		Local obj0:=fE.CreateBox(200,200,220,140)
		obj0.SetColor(0,0,255)

		Local obj1:=fE.CreateBox(200,200,220,340)
		obj1.SetColor(0,255,0)
		obj1.SetBlendMode(mojo.AdditiveBlend)
		
		Local obj3:=fE.CreateBox(200,200,420,140)
		obj3.SetColor(255,0,0)
		obj3.SetAlpha(0.8)
		
		Local obj4:=fE.CreateBox(200,200,420,340)
		obj4.SetColor(0,255,255)
		obj4.SetBlendMode(mojo.AdditiveBlend)
		obj4.SetAlpha(0.8)		
		
		' Create one particle above the squares
		p2=fE.CreateImage("particle.png",320,240)
		
		Return 0
	End
	'------------------------------------------
	Method OnUpdate:Int()
		' Determine the delta time and the update factor for the engine
		Local d:Float = Float(fE.CalcDeltaTime())/60.0

		p.SetPos(MouseX()-50, MouseY()-50)
		p2.SetPos(MouseX()+50, MouseY()+50)
		
		' Update all objects of the engine
		fE.Update(d)
		
		' Switch the blendmodes of the particles when you hit the space bar
		If KeyHit(KEY_SPACE) Then 
			Print ("BlendMode(p)  set to "+(1-p.GetBlendMode()))
			Print ("BlendMode(p2) set to "+(1-p2.GetBlendMode()))
			p.SetBlendMode(1-p.GetBlendMode())
			p2.SetBlendMode(1-p2.GetBlendMode())
		Endif
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
	_g = New cGame
	Return 0
End
