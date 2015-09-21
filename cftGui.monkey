#rem
	Title:        fantomEngine
	Description:  A 2D game framework for the Monkey programming language
	
	Author:       Michael Hartlef
	Contact:      michaelhartlef@gmail.com
	
	Repository:   http://code.google.com/p/fantomengine/
	
	License:      MIT
#End
Strict
Import fantomEngine

'nav:<blockquote><nav><b>fantomEngine documentation</b> | <a href="index.html">Home</a> | <a href="classes.html">Classes</a> | <a href="3rdpartytools.html">3rd party tools</a> | <a href="examples.html">Examples</a> | <a href="changes.html">Changes</a></nav></blockquote>
#Rem
'header:The class [b]ftGuiGadget[/b] is the base class for each gui object/gadget.
#End

'***************************************
'changes:New in version 1.57.
Class ftGuiGadget Extends ftObject
'#DOCOFF#
	Field gotHit:Bool = False
	Field vjMng:ftGuiMng = Null
	Field listNode:list.Node<ftObject> = Null
	Field smoothFactor:Float = .9
	Field alphaVal:Float = 0.0
	Field state:Bool = True
	Field hitCount:Int = 0
	'-----------------------------------------------------------------------------
	Method _GetLastHitState:Bool()
		Local retVal:Bool = False
		If Self.gotHit = True
			retVal = True
			Self.gotHit = False
		Endif
		Return retVal
	End
	'-----------------------------------------------------------------------------
	Method _Reset:Void()
		Self.alphaVal *= Self.smoothFactor
		Self.SetAlpha(1.0-Self.alphaVal)
		Self.hitCount -= 1
		If Self.hitCount < 0 Then Self.hitCount = 0
	End
	
'#DOCON#
	'-----------------------------------------------------------------------------
'summery:Returns the state of the control.
	Method GetState:Bool()
		Return Self.state
	End
	'-----------------------------------------------------------------------------
'summery:Sets the smoothness factor for the control.
	Method SetSmoothness:Void(smoothFactor:Float = 0.9)
		Self.smoothFactor =	smoothFactor	
	End
	'-----------------------------------------------------------------------------
'summery:Sets the state of the control.
	Method SetState:Void(newState:Bool)
		Self.state = newState
	End

End

'***************************************
'changes:New in version 1.57.
Class ftGuiButton Extends ftGuiGadget
	'-----------------------------------------------------------------------------
	' Overriding the default method so it will handle the fading effect.
	Method CheckTouchHit:Bool(px:Float, py:Float)
		Local retVal:Bool = Super.CheckTouchHit(px, py)
		If retVal = True
			Self.alphaVal = 0.8
			Self.gotHit = True
		Else
			Self.alphaVal *= Self.smoothFactor
			Self.gotHit = False
		Endif
		Self.SetAlpha(1.0-Self.alphaVal)
		Return retVal
	End

	'-----------------------------------------------------------------------------
'summery:Returns TRUE if the button just got pressed.
	Method GetPressed:Bool()
		Return Self.gotHit
	End

End

'***************************************
'changes:New in version 1.57
Class ftGuiCheckbox Extends ftGuiGadget
	'-----------------------------------------------------------------------------
	' Overriding the default method so it will handle the fading effect.
	Method CheckTouchHit:Bool(px:Float, py:Float)
		Local retVal:Bool = Super.CheckTouchHit(px, py)
		If retVal = True And hitCount = 0
			Self.state = Not Self.state
			If Self.state = True
				Self.SetCurrImage(1,1)
			Else
				Self.SetCurrImage(2,1)
			Endif			
			Self.alphaVal = 0.8
			Self.gotHit = True
			Self.hitCount = 2
		Elseif retVal = True And hitCount > 0
			Self.alphaVal = 0.8
			hitCount = 2
		Else
			'
		Endif
		Self.SetAlpha(1.0-Self.alphaVal)
		Return retVal
	End

	'-----------------------------------------------------------------------------
'summery:Sets the check state of the checkbox. TRUE means it is checked.
	Method SetState:Void(checkState:Bool)
		Super.SetState(checkState)
		If Self.state = True
			Self.SetCurrImage(1,1)
		Else
			Self.SetCurrImage(2,1)
		Endif			
	End

End

'***************************************
'changes:New in version 1.57.
Class ftGuiJoystick Extends ftGuiGadget
'#DOCOFF#
	Field xStickOff:Float = 0.0
	Field yStickOff:Float = 0.0
	Field stick:ftObject = Null
	Field deadZone:Float = 0.1
	Field maxZone:Float = 1.0
	Field distance:Float = 0.0
	'-----------------------------------------------------------------------------
'summery:Resets the stick to the center
	Method _Reset:Void()
		Self.xStickOff *= Self.smoothFactor		
		Self.yStickOff *= Self.smoothFactor
		Self.stick.SetPos(Self.xPos + xStickOff, Self.yPos + yStickOff)
	End
'#DOCON#
	'-----------------------------------------------------------------------------
	' Overriding the default method so the X/Y offset of the stick will be stored and its
	' object will be positioned automatically.
	Method CheckTouchHit:Bool(px:Float, py:Float)
		Local retVal:Bool = Super.CheckTouchHit(px, py)
		If retVal = True
			Self.xStickOff = px - Self.xPos
			If Abs(Self.GetJoyX())< Self.deadZone Then Self.xStickOff = 0.0
			If Abs(Self.GetJoyX())> Self.maxZone Then Self.xStickOff = Self.maxZone * (Self.GetWidth()/2.0) * Sgn(Self.xStickOff)
			
			Self.yStickOff = py - Self.yPos
			If Abs(Self.GetJoyY())< Self.deadZone Then Self.yStickOff = 0.0
			If Abs(Self.GetJoyY())> Self.maxZone Then Self.yStickOff = Self.maxZone * (Self.GetHeight()/2.0) * Sgn(Self.yStickOff)
			
			Self.gotHit = True
			Self.distance = Self.GetVectorDist(px, py)
		Else
			Self.xStickOff *= Self.smoothFactor
			Self.yStickOff *= Self.smoothFactor
			Self.gotHit = False
		Endif
		Self.stick.SetPos(Self.xPos + xStickOff, Self.yPos + yStickOff)
		Return retVal
	End
	'-----------------------------------------------------------------------------
'summery:Returns the X offset of the joystick
	Method GetJoyX:Float(raw:Bool = False)
		Local retval:Float
		If raw = True
			Return Self.xStickOff
		Else
			retval = Self.xStickOff/(Self.GetWidth()/2.0) * 10
			If retval>0.0
				retval = Floor ( retval + 0.5 ) / 10.0
			Else	
				retval = Ceil ( retval - 0.5 ) / 10.0
			Endif

			Return retval
		Endif
	End
	'-----------------------------------------------------------------------------
'summery:Returns the Y offset of the joystick
	Method GetJoyY:Float(raw:Bool = False)
		Local retval:Float
		If raw = True
			Return Self.yStickOff
		Else
			'Return Self.yStickOff/(Self.GetHeight()/2.0)
			retval = Self.yStickOff/(Self.GetHeight()/2.0) * 10
			If retval>0.0
				retval = Floor ( retval + 0.5 ) / 10.0
			Else	
				retval = Ceil ( retval - 0.5 ) / 10.0
			Endif

			Return retval
		Endif
	End
	
	'-----------------------------------------------------------------------------
'summery:Returns the hit state of the joystick
	Method isHit:Bool()
		Return Self.gotHit
	End
	
	'-----------------------------------------------------------------------------
'summery:Sets the deadzone of the joystick. Affects relative values less or equal the deadzone value.
	Method SetDeadZone:Void(deadZone:Float = 0.1)
		Self.deadZone =	deadZone	
	End
	'-----------------------------------------------------------------------------
'summery:Sets the deadzone of the joystick. Affects relative values less or equal the deadzone value.
	Method SetMaxZone:Void(maxZone:Float = 0.9)
		Self.maxZone =	maxZone	
	End

End
'***************************************
'changes:New in version 1.57.
Class ftGuiLabel Extends ftGuiGadget
	Field hasShadow:Bool = False
	Field shadowX:Float = 2.0
	Field shadowY:Float = 2.0
	'-----------------------------------------------------------------------------
	Method Render:Void(xoff:Float=0.0, yoff:Float=0.0)
		Local xAlpha:Float = Self.GetAlpha()
		Local xColor:Float[]
		
		If Self.hasShadow = True
			xAlpha = Self.GetAlpha()
			xColor = Self.GetColor()
			Self.SetColor(50,50,50)
			Self.SetAlpha(xAlpha-0.3)
			Super.Render(xoff+Self.shadowX, yoff+Self.shadowY)
			Self.SetColor(xColor[0],xColor[1],xColor[2])
			Self.SetAlpha(xAlpha)
		Endif
		Super.Render(xoff, yoff)
	End
	'-----------------------------------------------------------------------------
	Method SetShadowOffset:Void(xOff:Float, yOff:Float)
		Self.shadowX = xOff
		Self.shadowY = yOff
	End

End

'***************************************
'changes:New in version 1.57.
Class ftGuiListviewItem
	Field text:String = ""
	Field img:ftImage = Null
	'-----------------------------------------------------------------------------
	Method GetImage:ftImage()
		Return Self.img
	End
	'-----------------------------------------------------------------------------
	Method GetText:String()
		Return Self.text
	End
	'-----------------------------------------------------------------------------
	Method SetText:Void(lviText:String)
		Self.text = lviText 
	End
	'-----------------------------------------------------------------------------
	Method SetImage:Void(lviImage:ftImage)
		Self.img = lviImage 
	End
End	

'***************************************
'changes:New in version 1.57.
Class ftGuiListview Extends ftGuiGadget
	Field itemList:= New List<ftGuiListviewItem>
	Field scrollX:Float = 0.0
	Field scrollY:Float = 0.0
	Field selItem:Int = -1
	Field font:ftFont = Null
	
	'-----------------------------------------------------------------------------
	Method AddItem:ftGuiListviewItem(t:string)
		Local newItem:= New ftGuiListviewItem
		newItem.SetText(t)
		itemList.AddLast(newItem)
		Return newItem
	End
	
	'-----------------------------------------------------------------------------
	' Overriding the default method so it will handle the fading effect.
	Method CheckTouchHit:Bool(px:Float, py:Float)
		Local retVal:Bool = Super.CheckTouchHit(px, py)
		If retVal = True And hitCount = 0
			Self.state = Not Self.state
			Self.alphaVal = 0.8
			Self.gotHit = True
			Self.hitCount = 2
			Self.selItem = Int((py - (Self.yPos-Self.GetHeight()/2.0))/Self.vjMng.font1.Height())
'Print(py +":"+(Self.yPos-Self.GetHeight()/2.0)+"="+Self.selLine)			
		Elseif retVal = True And hitCount > 0
			Self.alphaVal = 0.8
			hitCount = 2
		Else
			'
		Endif
		Self.SetAlpha(1.0-Self.alphaVal)
		Return retVal
	End
	
	'-----------------------------------------------------------------------------
	Method GetItem:ftGuiListviewItem(index:Int = 0)
		Local retItem:ftGuiListviewItem = Null
		If index >= 0
			Local i:Int = 0
			For Local item := Eachin Self.itemList
				If i = index
					retItem = item
					Exit
				Endif
				i += 1
			Next		
		Endif
		Return retItem
	End
	'-----------------------------------------------------------------------------
	Method GetSelected:Int()
		Return Self.selItem
	End
	'-----------------------------------------------------------------------------
	Method GetItemText:String(index:Int)
		Local retval:String = ""
		Local i:Int = 0
		For Local item :ftGuiListviewItem = Eachin Self.itemList
			If i = index
				retval = item.GetText()
				Exit
			Endif
			i += 1
		Next		

		Return retval
	End
	'-----------------------------------------------------------------------------
	Method SetSelected:Void(selectedID:Int = -1)
		Self.selItem = selectedID
	End
	'-----------------------------------------------------------------------------
	Method Render:Void(xoff:Float=0.0, yoff:Float=0.0)
		Local _fE:ftEngine = Self.vjMng.engine
		Local sfx:Float = _fE.scaleX
		Local sfy:Float = _fE.scaleY
		
		Local i:Int = 1

		Super.Render(xoff, yoff)

		Local sc:Float[] = GetScissor()
		SetScissor(_fE.GetLocalX(Self.xPos-Self.GetWidth()/2), _fE.GetLocalY(Self.yPos-Self.GetHeight()/2), Self.GetWidth()*sfx, Self.GetHeight()*sfy)

		mojo.SetColor(255,255,255)
		mojo.SetAlpha(1.0)

		For Local item:= Eachin Self.itemList
			Self.vjMng.font1.Draw(item.GetText(), xoff+Self.xPos-Self.GetWidth()/2-Self.scrollX, yoff+Self.yPos+(i-1)*Self.vjMng.font1.Height()-Self.GetHeight()/2-Self.scrollY)
			i += 1
		Next

		SetScissor(sc[0],sc[1],sc[2],sc[3])
		Self.vjMng.engine.RestoreAlpha()
		Self.vjMng.engine.RestoreColor()
	End
	'-----------------------------------------------------------------------------
	Method SetLines:Void(newLines:String)
		Local lines:string[] = newLines.Split("~n")
		For Local is:String = Eachin lines
			Self.AddItem(is)
		Next
	End
	'-----------------------------------------------------------------------------
	Method SetLines:Void(newLines:String[])
		Local lines:String[] = newLines
		For Local is:String = Eachin lines
			Self.AddItem(is)
		Next
	End
	'-----------------------------------------------------------------------------
'summery:Set the X/Y offset position of the list items.
	Method SetScrollXY:Void (sx:Float, sy:Float, relative:Int = False )
		If relative = True
			Self.scrollX += sx
			Self.scrollY += sy
		Else
			Self.scrollX = sx
			Self.scrollY = sy
		Endif
	End

End

'***************************************
'changes:New in version 1.57.
Class ftGuiMng Extends ftObject
	'Field engine:ftEngine
	Field objList := New List<ftObject>
	Field font1:ftFont = Null
	
	Const idJoyStick:Int		= 1111
	Const idButton:Int			= 1112
	Const idSwitch:Int			= 1113
	Const idChkBox:Int			= 1114
	Const idListview:Int		= 1115
	Const idLabel:Int			= 1116
	'Const idGroup:Int			= 1116
	'Const idRadioBtn:Int		= 1117
	Const idSlider:Int			= 1118
	'Const idProgessbar:Int		= 1119
	'Const idLabel:Int			= 1120
	'Const idTextfield:Int		= 1121
	'Const idTextbox:Int			= 1122
	'Const idListbox:Int			= 1123
	'Const idComboBox:Int		= 1124
	'Const idTreeview:Int		= 1125
	'Const idTooltip:Int			= 1126
	'Const idGroup:Int			= 1127
	'Const idSpinner:Int			= 1128
	'Const idHyperlink:Int		= 1129
	'Const idScrollbar:Int		= 1130
	
	Const slHorizontal:Int = 1
	Const slVertical:Int = 2
	'------------------------------------------
'summery:Creates a new joypad manager.
	Method New(eng:ftEngine)
		Self.engine = eng
	End

	'------------------------------------------
'summery:Creates a new joypad button.
	Method CreateButton:ftGuiButton(imgBtn:String)
		Local obj:ftObject = engine.CreateImage(imgBtn, Self.engine.GetCanvasWidth()/2, Self.engine.GetCanvasHeight()/2, New ftGuiButton)
		obj.SetTouchMode(ftEngine.tmBox)

		ftGuiButton(obj).vjMng = Self
		'ftGuiButton(vb).listNode = Self.objList.AddLast(vb)
		obj.SetID(Self.idButton)

		obj.SetLayer(Self.GetLayer())
		obj.SetParent(Self)

		Return ftGuiButton(obj)
	End

	'------------------------------------------
'summery:Creates a new checkbox.
	Method CreateCheckbox:ftGuiCheckbox(imgChecked:String,imgUnchecked:String, checkState:Bool = True)
		Local obj:ftObject = engine.CreateImage(imgChecked, Self.engine.GetCanvasWidth()/2, Self.engine.GetCanvasHeight()/2, New ftGuiCheckbox)
		obj.SetTouchMode(ftEngine.tmBox)
		obj.AddImage(imgUnchecked)

		ftGuiCheckbox(obj).vjMng = Self
		'ftGuiCheckbox(obj).listNode = Self.objList.AddLast(obj)
		obj.SetID(Self.idChkBox)
		
		ftGuiCheckbox(obj).SetState(checkState)

		obj.SetLayer(Self.GetLayer())
		obj.SetParent(Self)

		Return ftGuiCheckbox(obj)
	End

	'------------------------------------------
'summery:Creates a new label.
	Method CreateLabel:ftGuiLabel(txt:String, shadowed:Bool = False)
		Local obj:ftObject = engine.CreateText(Self.font1, txt, Self.engine.GetCanvasWidth()/2, Self.engine.GetCanvasHeight()/2,ftEngine.taTopLeft, New ftGuiLabel)
		ftGuiLabel(obj).hasShadow = shadowed
		ftGuiLabel(obj).vjMng = Self
		'ftGuiLabel(obj).listNode = Self.objList.AddLast(obj)
		obj.SetID(Self.idLabel)

		obj.SetLayer(Self.GetLayer())
		obj.SetParent(Self)

		Return ftGuiLabel(obj)
	End
	
	'------------------------------------------
'summery:Creates a new listview.
	Method CreateListview:ftGuiListview(x:Float, y:Float, w:Float, h:Float, newLines:String)
		Local obj:ftObject = engine.CreateBox(w,h,x,y, New ftGuiListview)
		obj.SetTouchMode(ftEngine.tmBox)
		ftGuiListview(obj).SetLines(newLines)

		ftGuiListview(obj).vjMng = Self
		'ftGuiListview(obj).listNode = Self.objList.AddLast(obj)
		obj.SetID(Self.idListview)

		obj.SetLayer(Self.GetLayer())
		obj.SetParent(Self)

		Return ftGuiListview(obj)
	End

	'------------------------------------------
'summery:Creates a new analog joystick.
	Method CreateJoyStick:ftGuiJoystick(imgRing:String, imgStick:String)
		Local obj:ftObject = engine.CreateImage(imgRing, Self.engine.GetCanvasWidth()/2, Self.engine.GetCanvasHeight()/2, New ftGuiJoystick)
		ftGuiJoystick(obj).stick = engine.CreateImage(imgStick, Self.engine.GetCanvasWidth()/2, Self.engine.GetCanvasHeight()/2)
		ftGuiJoystick(obj).stick.SetParent(obj)
		obj.SetTouchMode(ftEngine.tmCircle)

		ftGuiJoystick(obj).vjMng = Self
		'ftGuiJoystick(vj).listNode = Self.objList.AddLast(vj)
		obj.SetID(Self.idJoyStick)

		obj.SetLayer(Self.GetLayer())
		obj.SetParent(Self)

		Return ftGuiJoystick(obj)
	End

'------------------------------------------
'summery:Creates a slider.
	Method CreateSlider:ftGuiSlider(imgSliderBar:String, imgSliderKnob:String, startVal:Float, rangeVal:Float, orientation:Int = ftGuiMng.slHorizontal)
		Local obj:ftObject = engine.CreateImage(imgSliderBar, Self.engine.GetCanvasWidth()/2, Self.engine.GetCanvasHeight()/2, New ftGuiSlider)
		ftGuiSlider(obj).knob = engine.CreateImage(imgSliderKnob, Self.engine.GetCanvasWidth()/2, Self.engine.GetCanvasHeight()/2)
		ftGuiSlider(obj).knob.SetParent(obj)
		obj.SetTouchMode(ftEngine.tmBox)
		
		ftGuiSlider(obj).SetRange(startVal, rangeVal)
		ftGuiSlider(obj).orientation = orientation
		If ftGuiSlider(obj).orientation = ftGuiMng.slVertical
			ftGuiSlider(obj).SetAngle(90.0)
		Endif
		ftGuiSlider(obj).vjMng = Self
		'ftGuiSlider(obj).listNode = Self.objList.AddLast(obj)
		obj.SetID(Self.idSlider)

		obj.SetLayer(Self.GetLayer())
		obj.SetParent(Self)

		Return ftGuiSlider(obj)
	End


'------------------------------------------
'summery:Creates a new switch.
	Method CreateSwitch:ftGuiSwitch(imgSwitchOn:String,imgSwitchOff:String, switchState:Bool = True)
		Local obj:ftObject = engine.CreateImage(imgSwitchOn, Self.engine.GetCanvasWidth()/2, Self.engine.GetCanvasHeight()/2, New ftGuiSwitch)
		obj.SetTouchMode(ftEngine.tmBox)
		obj.AddImage(imgSwitchOff)

		ftGuiSwitch(obj).vjMng = Self
		'ftGuiSwitch(obj).listNode = Self.objList.AddLast(obj)
		obj.SetID(Self.idSwitch)
		ftGuiSwitch(obj).SetState(switchState)
		obj.SetLayer(Self.GetLayer())
		obj.SetParent(Self)

		Return ftGuiSwitch(obj)
	End

	'------------------------------------------
'summery:Updates all states of gui elements.
	Method Update:Void(delta:Float=1.0)
		Super.Update(delta)
		'For Local obj:= Eachin Self.objList
		For Local obj:= Eachin Self.childObjList
			Select obj.GetID()
				Case Self.idJoyStick
					If ftGuiJoystick(obj)._GetLastHitState() = False
						ftGuiJoystick(obj)._Reset()
					Endif
				Case Self.idButton
					If ftGuiButton(obj)._GetLastHitState() = False
						ftGuiButton(obj)._Reset()
					Endif
				Case Self.idSwitch
					If ftGuiSwitch(obj)._GetLastHitState() = False
						ftGuiSwitch(obj)._Reset()
					Endif
				Case Self.idChkBox
					If ftGuiCheckbox(obj)._GetLastHitState() = False
						ftGuiCheckbox(obj)._Reset()
					Endif
				Case Self.idListview
					If ftGuiListview(obj)._GetLastHitState() = False
						ftGuiListview(obj)._Reset()
					Endif
			End
		Next
	End
End

'***************************************
'changes:New in version 1.57.
Class ftGuiSlider Extends ftGuiGadget
'#DOCOFF#
	Field xKnobOff:Float = 0.0
	Field yKnobOff:Float = 0.0
	Field knob:ftObject = Null
	Field startValue:Float = 0.0
	Field range:Float = 0.0
	Field currValue:Float = 0.0
	Field orientation:Int = ftGuiMng.slHorizontal
	Field idxx:Int= 0
'#DOCON#
	'-----------------------------------------------------------------------------
	' Overriding the default method so the X offset of the knob will be stored and its
	' object will be positioned automatically.
	Method CheckTouchHit:Bool(px:Float, py:Float)
		Local retVal:Bool = Super.CheckTouchHit(px, py)
		If retVal = True
			If Self.orientation = ftGuiMng.slHorizontal
				Self.xKnobOff = px - Self.xPos + Self.GetWidth()/2.0
				Self.currValue = (Self.range/Self.GetWidth()) * Self.xKnobOff + Self.startValue
				Self.currValue = Clamp(Self.currValue, Self.startValue,Self.startValue+Self.range) 		
				Self.gotHit = True
				Self.knob.SetPos(Self.xPos + xKnobOff - Self.GetWidth()/2.0, Self.yPos)
			Else
				Self.yKnobOff = py - Self.yPos + Self.GetWidth()/2.0
'Print ("Self.yKnobOff = "+Self.yKnobOff+"   Self.GetWidth()="+Self.GetWidth())

				Self.currValue = (Self.range/Self.GetWidth()) * Self.yKnobOff + Self.startValue
				Self.currValue = Clamp(Self.currValue, Self.startValue,Self.startValue+Self.range) 		
				Self.gotHit = True
				Self.knob.SetPos(Self.xPos, Self.yPos +  yKnobOff - Self.GetWidth()/2.0)
			Endif
			If Self.currValue>0.0
				Self.currValue = Floor ( Self.currValue + 0.5 )
			Else	
				Self.currValue = Ceil ( Self.currValue - 0.5 )
			Endif
		Endif
		
		Return retVal
	End
	
	'-----------------------------------------------------------------------------
'summery:Returns the current value of the slider
	Method GetValue:Float()
		Return Self.currValue
	End
	
	'-----------------------------------------------------------------------------
'summery:Returns the hit state of the slider
	Method isHit:Bool()
		Return Self.gotHit
	End
	
	'-----------------------------------------------------------------------------
'summery:Sets the range of the slider.
	Method SetRange:Void(startVal:Float, rangeVal:Float)
		Self.startValue = startVal
		Self.range = rangeVal	
		Self.currValue = (rangeVal/2.0)+startVal
'Print ("Self.currValue="+Self.currValue)			
	End
End

'***************************************
'changes:New in version 1.57.
Class ftGuiSwitch Extends ftGuiGadget
	'-----------------------------------------------------------------------------
	' Overriding the default method so it will handle the fading effect.
	Method CheckTouchHit:Bool(px:Float, py:Float)
		Local retVal:Bool = Super.CheckTouchHit(px, py)
		If retVal = True And hitCount = 0
			Self.state = Not Self.state
			If Self.state = True
				Self.SetCurrImage(1,1)
			Else
				Self.SetCurrImage(2,1)
			Endif			
			Self.alphaVal = 0.8
			Self.gotHit = True
			Self.hitCount = 2
		Elseif retVal = True And hitCount > 0
			Self.alphaVal = 0.8
			hitCount = 2
		Else
			'
		Endif
		Self.SetAlpha(1.0-Self.alphaVal)
		Return retVal
	End
	'-----------------------------------------------------------------------------
'summery:Sets the switch state of the switch. TRUE means it is ON.
	Method SetState:Void(switchState:Bool)
		Super.SetState(switchState)
		If Self.state = True
			Self.SetCurrImage(1,1)
		Else
			Self.SetCurrImage(2,1)
		Endif			
	End
End

#rem
footer:This fantomEngine framework is released under the MIT license:
[quote]Copyright (c) 2011-2015 Michael Hartlef

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software, and to permit persons to whom the software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
[/quote]
#end