Strict

#rem
	Script:			MultilineText.monkey
	Description:	Sample fantomEngine script, that shows how To use multiline text objects 
	Author: 		Michael Hartlef
	Version:      	1.02
#End
#MOJO_AUTO_SUSPEND_ENABLED=True
Import fantomEngine
Global g:game

'***************************************
Class game Extends App
    ' Create a field to store the instance of the engine class, which is an instance
    ' of the ftEngine class itself
	Field eng:engine

	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate to 60 FPS.
		SetUpdateRate(60)
		
		' Create an instance of the fantomEngine, which was created via the engine class
		eng = New engine
		
		' Store the width and height of the canvas
		Local cw:Int = 1280
		Local ch:Int = 900
		
		' Set virtual canvas size
		eng.SetCanvasSize(cw, ch)

		' Load a bitmap font
		Local font:ftFont = eng.LoadFont("font.txt")
		
		' Create to small boxes to define a cross hair
		Local b1:=eng.CreateBox(cw,3,cw/2,ch/2)
		Local b2:=eng.CreateBox(3,ch,cw/2,ch/2)
		
		' Create some multi line text objects
		Local multitxt_TL:ftObject = eng.CreateText(font,"Hello World!~nMonkey is awesome~ntextAlignMode = taTopLeft",cw/2,ch/2, eng.taTopLeft)
		'Local multitxt_CL:ftObject = eng.CreateText(font,"Hello World!~nMonkey is awesome~ntextAlignMode = taCenterLeft",cw/2,ch/2, eng.taCenterLeft)
		Local multitxt_BL:ftObject = eng.CreateText(font,"Hello World!~nMonkey is awesome~ntextAlignMode = taBottomLeft",cw/2,ch/2, eng.taBottomLeft)
		
		'Local multitxt_TR:ftObject = eng.CreateText(font,"Hello World!~nMonkey is awesome~ntextAlignMode = taTopRight",cw/2,ch/2, eng.taTopRight)
		Local multitxt_CR:ftObject = eng.CreateText(font,"Hello World!~nMonkey is awesome~ntextAlignMode = taCenterRight",cw/2,ch/2, eng.taCenterRight)
		'Local multitxt_BR:ftObject = eng.CreateText(font,"Hello World!~nMonkey is awesome~ntextAlignMode = taBottomRight",cw/2,ch/2, eng.taBottomRight)
		
		'Local multitxt_TC:ftObject = eng.CreateText(font,"Hello World!~nMonkey is awesome~ntextAlignMode = taTopCenter",cw/2,ch/2, eng.taTopCenter)
		'Local multitxt_CC:ftObject = eng.CreateText(font,"Hello World!~nMonkey is awesome~ntextAlignMode = taCenterCenter",cw/2,ch/2, eng.taCenterCenter)
		'Local multitxt_BT:ftObject = eng.CreateText(font,"Hello World!~nMonkey is awesome~ntextAlignMode = taBottomCenter",cw/2,ch/2, eng.taBottomCenter)
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
		Cls 0,0,155
		
		' Render all visible objects of the engine
		eng.Render()
		Return 0
	End
	'------------------------------------------
	Method OnSuspend:Int()
		' Clear the screen 
		Error("xxx")
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
