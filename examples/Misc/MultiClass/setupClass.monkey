Strict

' Import the main file
Import MultiClass

'***************************************
' The cSetup class takes care of setting up some objects during its creation
Class cSetup
	Field eng:ftEngine
	'------------------------------------------
	'We only need one method for this class
	Method New()
		' Let's store the engine instance inside a local class field so it is easier to access
		eng = _g.fE
		
		' Now we create a normal ftObject and set some properties
		Local circle := eng.CreateCircle(30, _g.cW/2.0, _g.cH/2.0)
		circle.SetWrapScreen(True)
		circle.SetSpeed(5,45)
		circle.SetColor(0,255,0)
		
		' Next we create a custom object. Its definition is made inside the customObjClass.monkey file
		Local custCircle :cCustomObj = cCustomObj(eng.CreateCircle(30, _g.cW/2.0, _g.cH/2.0, New cCustomObj))
		' Give this object a type that is not take care of in its regular Render method as we draw it ourselfs
		custCircle.type  = 9999
		custCircle.myfield = 7777



		' Now we create a normal ftObject and set some properties
		Local circle2 := eng.CreateCircle(20, _g.cW/2.0, _g.cH/2.0)
		circle2.SetWrapScreen(True)
		circle2.SetSpeed(5,145)
		circle2.SetColor(255,0,0)
	End
End
