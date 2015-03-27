Strict

#rem
	Script:			SheetAnim.monkey
	Description:	Sample script that shows how to use spritesheets for animated objects
	Author: 		Michael Hartlef
	Version:      	1.0
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
	
	' Now we need a field to store the spritesheet/spriteatlas in it
	Field sprAtlas:ftSpriteAtlas
	
	' Next create 2 objects to store the animated objects from the spritesheet
	Field blinker:ftObject
	Field circle:ftObject
	
	'------------------------------------------
	Method OnCreate:Int()
		' Set the update rate of Mojo's OnUpdate events to be determined by the devices refresh rate.
		SetUpdateRate(0)
		
		' Create an instance of the fantomEngine, which was created via the cEngine class
		fE = New cEngine
		
		' Load the spriteatlas
		sprAtlas = fE.CreateSpriteAtlas("spriteSheet.png", "spriteSheet.txt")
		
		' Now create the first animated object from an image strip inside the sprite sheet
		' Load the image strip
		Local subImg:Image = sprAtlas.GetImage("Blinker")

		' Determine the height and width
		Local blHeight:Int = sprAtlas.GetImageHeight("Blinker")
		Local blWidth:Int = sprAtlas.GetImageWidth("Blinker")

		' Calculate the framecount
		Local flFrameCount:Int = blWidth / blHeight

		' Create the animated object
		If subImg <> Null
			blinker = fE.CreateAnimImage(subImg,0,0, blHeight, blHeight ,flFrameCount, fE.GetCanvasWidth()/2, fE.GetCanvasHeight()/4.0 * 1)
		Endif
		'Give the object a name so we can disoplay it later
		blinker.SetName("BLINKER")
		
		
		' Let's now create an animated object by composing it from single images of the spritesheet
		' Load the first image
		circle = fE.CreateImage(sprAtlas.GetImage("Circle1"), fE.GetCanvasWidth()/2, fE.GetCanvasHeight()/4.0 * 3)
		' Add 3 more images to the object. 
		circle.AddImage(sprAtlas.GetImage("Circle2"))
		circle.AddImage(sprAtlas.GetImage("Circle3"))
		circle.AddImage(sprAtlas.GetImage("Circle4"))
		
		' To turn this object into an animated one by creating an animation sequence.
		circle.CreateAnim("myANIM",1)
		circle.AddAnim("myANIM", 2)
		circle.AddAnim("myANIM", 3)
		circle.AddAnim("myANIM", 4)
		
		' Finally, speed up the animation of the object
		circle.SetAnimTime(4)
		
		'Give the object a name
		circle.SetName("CIRCLE")

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
		Endif
		Return 0
	End
	'------------------------------------------
	Method OnRender:Int()
		' Check if the engine is not paused
		If fE.GetPaused() = False Then
			' Clear the screen 
			Cls 0,0,255
		
			' Render all visible objects of the engine
			fE.Render()
		Endif
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
	Method OnObjectAnim:Int(obj:ftObject)
		'This Method is called when an animation of an object (obj) has finished one loop.
		Print ("Object " + obj.GetName() + " has finished an animation cicle from the "+obj.GetAnimName()+" animation.")
		Return 0
	End
End

'***************************************
Function Main:Int()
	' Create an instance of the cGame class and store it inside the global var 'g'
	_g = New cGame
	
	Return 0
End

