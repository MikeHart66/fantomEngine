Strict

' Import the main file
Import MultiClass

'***************************************
' The cSetup class takes care of setting up some objects during its creation
Class cCustomObj Extends ftObject
	Field myfield:Int = 0
	'------------------------------------------
	Method New()
		' Set some properties during the creation of the object
		Self.SetWrapScreen(True)
		Self.SetSpeed(10,-45)
		Self.SetColor(255,0,0)
		Self.SetID(888)
	End	
	'------------------------------------------
	' Overwrite the ftObject.Render method
	Method Render:Void(xoff:Float=0.0, yoff:Float=0.0)
		' Call the super class render method which takes care of alpha, color and blendmode changes automatically for us
		' Attention, childs of this object will be drawn first if you do it this way.
		Super.Render(xoff, yoff)
		
		' Now render the object ourself
		PushMatrix
		Translate ((xPos+xoff), (yPos+yoff)) 
		Rotate 360.0-angle
		Scale (Self.scaleX, Self.scaleY)
		DrawCircle -Self.w * (Self.handleX-0.5), -Self.h * (Self.handleY-0.5), Self.radius
		mojo.SetColor(255,255,0)
		mojo.SetAlpha(1.0)
		DrawRect -5, -h*Self.handleY, 10, h

		' As we have changed mojo's color and alpha settings, we need to restore them from the engines internal stored values,
		' so the next obejct will be rendered correctly.
		Self.engine.RestoreColor()
		Self.engine.RestoreAlpha()
		
		PopMatrix

	End
	'------------------------------------------
	' Overwrite the ftObject.Update method of the ftObject so we can call the local CustOnObjectUpdate method. 
	Method Update:Void(delta:Float=1.0)
		Super.Update(delta)
		' Now get the current alpha and lower its value
		Local alpha:= Self.GetAlpha()
		alpha -= 0.02
		If alpha < 0.0 Then alpha = 1.0
		Self.SetAlpha(alpha)
	End
	'------------------------------------------
	' Now we create a custom method of this object.
	Method customRotate:Void(angle:Float)
		Self.SetAngle(angle, True)
	End 
End
