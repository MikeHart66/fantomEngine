#rem
	Title:        fantomEngine
	Description:  A 2D game framework for the Monkey programming language
	
	Author:       Michael Hartlef
	Contact:      michaelhartlef@gmail.com
	
	Website:      http://www.fantomgl.com
	
	License:      MIT
#End

Import fantomEngine
Import cftTween

'nav:<blockquote><nav><b>fantomEngine documentation</b> | <a href="index.html">Home</a> | <a href="classes.html">Classes</a> | <a href="3rdpartytools.html">3rd party tools</a> | <a href="examples.html">Examples</a> | <a href="changes.html">Changes</a></nav></blockquote>
#Rem
'header:The class [b]ftTrans[/b] controls the way an object or layer does a transition. Starting with version 1.49, it utilizes the tween class from the 
'monkey sample script in bananas/skn3/tweening/tween.monkey
#End

'#DOCOFF#

'***************************************
Class ftTransEntry
	Field typ:Int
	Field x:Float
	Field y:Float
	Field rot:Float
	Field alpha:Float
	Field scale:Float
	Field duration:Float
	Field timeLapsed:Float = 0.0
	Field s_x:Float
	Field s_y:Float
	Field s_rot:Float
	Field s_alpha:Float
	Field s_scale:Float
	Field e_x:Float
	Field e_y:Float
	Field e_rot:Float
	Field e_alpha:Float
	Field e_scale:Float
	Field obj:ftObject = Null
	Field layer:ftLayer = Null
	'------------------------------------------
	Method Update:Void(delta:Int, tween:Tween)
		timeLapsed += delta
		If obj <> Null Then

			If delta = -1 Then
				Select typ
					Case 1
						obj.SetPos(e_x, e_y, False)
					Case 2
						obj.SetAngle(e_rot, False)
					Case 3
						obj.SetScale(e_scale, False)
					Case 4
						obj.SetAlpha(e_alpha, False)
				End
			Else
				Select typ
					Case 1
						'obj.SetPos(x * delta, y * delta, True)
						'obj.SetPos(tween.equation.Call(timeLapsed, s_x, e_x - s_x, duration), tw.equation.Call(timeLapsed, s_y, e_y - s_y, duration), false)
						obj.SetPosX(tween.equation.Call(timeLapsed, s_x, e_x - s_x, duration))
						obj.SetPosY(tween.equation.Call(timeLapsed, s_y, e_y - s_y, duration))
					Case 2
						obj.SetAngle(rot * delta, True)
					Case 3
						obj.SetScale(scale * delta, True)
					Case 4
						obj.SetAlpha(alpha * delta, True)
				End
			Endif
		Else
			If delta = -1 Then
				Select typ
					Case 1
						layer.SetPos(e_x, e_y, False)
					'Case 2
						'layer.SetAngle(e_rot, False)
					Case 3
						layer.SetScale(e_scale, False)
					Case 4
						layer.SetAlpha(e_alpha, False)
				End
			Else
				Select typ
					Case 1
						layer.SetPos(x*delta, y*delta, True)
					'Case 2
						'layer.SetAngle(rot*delta, True)
					Case 3
						layer.SetScale(scale*delta, True)
					Case 4
						layer.SetAlpha(alpha*delta, True)
				End
			Endif
		Endif
	End

End

'#DOCON#
'***************************************
Class ftTrans
'#DOCOFF#
	Field entryList := New List<ftTransEntry>
	'Field startTime:Int
	'Field lastTime:Int=0
	Field currTime:Int=0

	'Field endTime:Int=0
	'Field deltaTime:Int=0
	Field duration:Int
	Field finishID:Int
	Field obj:ftObject=Null
	Field layer:ftLayer=Null
	Field engine:ftEngine = Null
	Field transNode:list.Node<ftTrans> = Null
	Field deleted:Bool = False
	Field isPaused:Bool = False

	Field tween:Tween
    Field equations:String[] = ["Linear","Back","Bounce","Circ","Cubic","Elastic","Expo","Quad","Quart","Quint","Sine"]
    Field easeTypes:String[] = ["EaseIn","EaseOut","EaseInOut"]

    Field currentEquation:Int
    Field currentEaseType:Int

	'-----------------------------------------------------------------------------
	Method AddAlpha:Void(alpha:Float, obj:ftObject, duration:Float, relative:Int )
		Local transEntry:ftTransEntry = New ftTransEntry
		transEntry.typ = 4
		transEntry.s_alpha = obj.alpha
		If relative = True Then
			transEntry.e_alpha = alpha + obj.alpha
		Else
			transEntry.e_alpha = alpha
		Endif
		transEntry.alpha = (transEntry.e_alpha - obj.alpha) / duration
		transEntry.duration = duration
		transEntry.timeLapsed = 0.0
		transEntry.obj = obj
		transEntry.layer = Null
		entryList.AddLast(transEntry)
	End
	'-----------------------------------------------------------------------------
	Method AddAlpha:Void(alpha:Float, layer:ftLayer, duration:Float, relative:Int )
		Local transEntry:ftTransEntry = New ftTransEntry
		transEntry.typ = 4
		transEntry.s_alpha = layer.alpha
		If relative = True Then
			transEntry.e_alpha = alpha + layer.alpha
		Else
			transEntry.e_alpha = alpha
		Endif
		transEntry.alpha = (transEntry.e_alpha - layer.alpha) / duration
		transEntry.duration = duration
		transEntry.timeLapsed = 0.0
		transEntry.obj = Null
		transEntry.layer = layer
		entryList.AddLast(transEntry)
	End
	'-----------------------------------------------------------------------------
	Method AddPos:Void(xt:Float, yt:Float, obj:ftObject, duration:Float, relative:Int )
		Local transEntry:ftTransEntry = New ftTransEntry
		transEntry.typ = 1
		transEntry.s_x = obj.xPos
		transEntry.s_y = obj.yPos
		If relative = True Then
			transEntry.e_x = xt + obj.xPos
			transEntry.e_y = yt + obj.yPos
		Else
			transEntry.e_x = xt
			transEntry.e_y = yt
		Endif
		transEntry.x = (transEntry.e_x - obj.xPos) / duration
		transEntry.y = (transEntry.e_y - obj.yPos) / duration
		transEntry.duration = duration
		transEntry.timeLapsed = 0.0
		transEntry.obj = obj
		transEntry.layer = Null
		entryList.AddLast(transEntry)
	End
	'-----------------------------------------------------------------------------
	Method AddPos:Void(xt:Float, yt:Float, layer:ftLayer, duration:Float, relative:Int )
		Local transEntry:ftTransEntry = New ftTransEntry
		transEntry.typ = 1
		transEntry.s_x = layer.xPos
		transEntry.s_y = layer.yPos
		If relative = True Then
			transEntry.e_x = xt + layer.xPos
			transEntry.e_y = yt + layer.yPos
		Else
			transEntry.e_x = xt
			transEntry.e_y = yt
		Endif
		transEntry.x = (transEntry.e_x - layer.xPos) / duration
		transEntry.y = (transEntry.e_y - layer.yPos) / duration
		transEntry.duration = duration
		transEntry.timeLapsed = 0.0
		transEntry.obj = Null
		transEntry.layer = layer
		entryList.AddLast(transEntry)
	End
	'-----------------------------------------------------------------------------
	Method AddRot:Void(rot:Float, obj:ftObject, duration:Float, relative:Int )
		Local transEntry:ftTransEntry = New ftTransEntry
		transEntry.typ = 2
		transEntry.s_rot = obj.angle
		If relative = True Then
			transEntry.e_rot = rot + obj.angle
		Else
			transEntry.e_rot = rot
		Endif
		transEntry.rot = (transEntry.e_rot - obj.angle) / duration
		transEntry.duration = duration
		transEntry.timeLapsed = 0.0
		transEntry.obj = obj
		transEntry.layer = Null
		entryList.AddLast(transEntry)
	End
	'-----------------------------------------------------------------------------
	Method AddScale:Void(sca:Float, obj:ftObject, duration:Float, relative:Int )
		Local transEntry:ftTransEntry = New ftTransEntry
		transEntry.typ = 3
		transEntry.s_scale = obj.scaleX
		If relative = True Then
			transEntry.e_scale = sca + obj.scaleX
		Else
			transEntry.e_scale = sca
		Endif
		transEntry.scale = (transEntry.e_scale - obj.scaleX) / duration
		transEntry.duration = duration
		transEntry.timeLapsed = 0.0
		transEntry.obj = obj
		transEntry.layer = Null
		entryList.AddLast(transEntry)
	End
	'-----------------------------------------------------------------------------
	Method AddScale:Void(sca:Float, layer:ftLayer, duration:Float, relative:Int )
		Local transEntry:ftTransEntry = New ftTransEntry
		transEntry.typ = 3
		transEntry.s_scale = layer.scale
		If relative = True Then
			transEntry.e_scale = sca + layer.scale
		Else
			transEntry.e_scale = sca
		Endif
		transEntry.scale = (transEntry.e_scale - layer.scale) / duration
		transEntry.duration = duration
		transEntry.timeLapsed = 0.0
		transEntry.obj = Null
		transEntry.layer = layer
		entryList.AddLast(transEntry)
	End
	'-----------------------------------------------------------------------------
	Method Cancel:Void()
		Self.Clear()
		Self.transNode.Remove()
		Self.transNode = Null
		Self.obj = Null
		Self.engine = Null
		Self.layer = Null
	End
	'------------------------------------------
	Method Clear:Void()
		For Local entry := Eachin entryList
			entry.obj = Null
			entry.layer = Null
		Next
		entryList.Clear()
	End

'#DOCON#
	'------------------------------------------
'summery:Returns TRUE if a transition is paused. 
'seeAlso:SetPaused
	Method GetPaused:Bool()
		Return Self.isPaused
	End
	'------------------------------------------
'#DOCOFF#
	Method New()
        tween = New Tween(Tween.Linear,0,1,2000)
        tween.Start()
	End
'#DOCON#
	'------------------------------------------
'summery:With this method you can pause and resume the transition. 
'seeAlso:GetPaused
	Method SetPaused:Void(pauseFlag:Bool = True)
		Self.isPaused = pauseFlag
	End
	'------------------------------------------
#Rem
'summery:Sets the equation type of a transition. 
This command sets the equation type of a transition. The equation type can be:
[list][*]Linear
[*]Back 
[*]Bounce
[*]Circ
[*]Cubic
[*]Elastic
[*]Expo
[*]Quad
[*]Quart
[*]Quint
[*]Sine[/list]
#End
'seeAlso:SetEase
    Method SetType(equationType:String="Linear")
        currentEquation = 0
        For Local i:Int = 0 To equations.Length()
        	If equations[i] = equationType Then 
        		currentEquation = i
        		Exit
        	Endif
        Next
        SetEquation1()
    End

	'------------------------------------------
#Rem
'summery:Sets the ease type of a transition. 
This command sets the ease type of a transition. The ease type can be:
[list][*]EaseIn
[*]EaseOut 
[*]EaseInOut[/list]
#End
'seeAlso:SetType
    Method SetEase(easeType:String="EaseIn")
        For Local i:Int = 0 To easeTypes.Length()
        	If easeTypes[i] = easeType Then 
        		currentEaseType = i
        		Exit
        	Endif
        Next
        SetEquation1()
    End

'#DOCOFF#

	'------------------------------------------
    Method SetEquation1()
        Select equations[currentEquation]
            Case "Linear"
                tween.SetEquation(Tween.Linear)
                tween.Rewind()
                tween.Start()
            Case "Back"
                SetEquation2(Tween.Back)
            Case "Bounce"
                SetEquation2(Tween.Bounce)
            Case "Circ"
                SetEquation2(Tween.Circ)
            Case "Cubic"
                SetEquation2(Tween.Cubic)
            Case "Elastic"
                SetEquation2(Tween.Elastic)
            Case "Expo"
                SetEquation2(Tween.Expo)
            Case "Quad"
                SetEquation2(Tween.Quad)
            Case "Quart"
                SetEquation2(Tween.Quart)
            Case "Quint"
                SetEquation2(Tween.Quint)
            Case "Sine"
                SetEquation2(Tween.Sine)
        End
    End

	'------------------------------------------
    Method SetEquation2(equation:TweenEquation)
        Select easeTypes[currentEaseType]
            Case "EaseIn"
                tween.SetEquation(equation.EaseIn)
                tween.Rewind()
                tween.Start()
            Case "EaseOut"
                tween.SetEquation(equation.EaseOut)
                tween.Rewind()
                tween.Start()
            Case "EaseInOut"
                tween.SetEquation(equation.EaseInOut)
                tween.Rewind()
                tween.Start()
        End
    End


	'------------------------------------------
	Method Update:Void()
		Local oldCurrTime:Int
		Local deltaTime:Int

		If deleted = False Then
			oldCurrTime = currTime
			currTime = engine.time
			
			deltaTime = currTime - oldCurrTime
			
			If engine.isPaused <> True And Self.isPaused <> True Then
				duration -= deltaTime
				If duration <= 0 Then
					For Local entry := Eachin entryList

						entry.Update(-1, Self.tween)
					Next
					If finishID <> 0 Then 
						If obj <> Null Then
							engine.OnObjectTransition(finishID, obj)
						Else
							engine.OnLayerTransition(finishID, layer)
						Endif
					Endif
					Self.deleted = True
				Else
					For Local entry := Eachin entryList
						entry.Update(deltaTime, Self.tween)
					Next
				Endif
			Endif 
			
		Endif
	End
End
'#DOCON#

#rem
footer:This fantomEngine framework is released under the MIT license:
[quote]Copyright (c) 2011-2016 Michael Hartlef

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software, and to permit persons to whom the software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
[/quote]
#end