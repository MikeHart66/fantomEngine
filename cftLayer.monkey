#rem
	Title:        fantomEngine
	Description:  A 2D game framework for the Monkey programming language
	
	Author:       Michael Hartlef
	Contact:      michaelhartlef@gmail.com
	
	Website:      http://www.fantomgl.com
	
	License:      MIT
#End

Import fantomEngine

'nav:<blockquote><nav><b>fantomEngine documentation</b> | <a href="index.html">Home</a> | <a href="classes.html">Classes</a> | <a href="3rdpartytools.html">3rd party tools</a> | <a href="examples.html">Examples</a> | <a href="changes.html">Changes</a></nav></blockquote>

'header:The module [b]cftLayer[/b] contains the ftLayer class and the lObjList class with is a sub object for the ftLayer class.

'#DOCOFF#
'***************************************
Class lObjList Extends List<ftObject>
	Field layer:ftLayer = Null
	'-----------------------------------------------------------------------------
	Method Compare:Int( obj1:ftObject, obj2:ftObject )
		Return layer.engine.OnObjectSort(obj1, obj2)
	End

End
'#DOCON#

'***************************************
#Rem
'summery:The class [b]ftLayer[/b] groups assigned objects. A layer then will update, render, touch and collision check all its objects together in one batch. 
#End
Class ftLayer
'#DOCOFF#
	Field xPos:Float = 0.0
	Field yPos:Float = 0.0
	Field alpha:Float = 1.0
	Field scale:Float = 1.0
	'Field objList := New List<ftObject>
	Field objList := New lObjList
	Field transitionList := New List<ftTrans>
	Field isVisible:Bool = True
	Field isActive:Bool = True
	Field engine:ftEngine = Null
	Field engineNode:list.Node<ftLayer> = Null
	Field inUpdate:Bool = False
	Field inTouch:Bool = False
	Field angle:Float = 0.0
	Field id:Int = 0
	Field tag:Int = 0
	Field isGUI:Bool = False
	
	Field scissorX:Float = 0.0
	Field scissorY:Float = 0.0
	Field scissorWidth:Float = 0.0
	Field scissorHeight:Float = 0.0
	
	'-----------------------------------------------------------------------------
	Method CleanupLists:Void()
		For Local trans:ftTrans = Eachin transitionList
			If trans.deleted Then trans.Cancel()
		Next
		For Local obj:ftObject = Eachin objList.Backwards()
			If obj.deleted Then obj.Remove(True)
		Next
	End
'#DOCON#

	'------------------------------------------
#Rem
'summery:Does a collision check on all active objects of this layer with a assigned collision group. 
'If a collision appears, ftEngine.OnObjectCollision is called.	
#End
	Method CollisionCheck:Void()
		Local obj:ftObject
		Local obj2:ftObject
		For obj = Eachin objList
			'If obj.isActive = True And obj.parentObj = Null 
			If obj.isActive = True Then
				If obj.collGroup > 0 And obj.colCheck = True Then 
					For obj2 = Eachin objList	
						If obj <> obj2 Then
							If obj.CheckCollision(obj2)
								If engine.OnObjectCollision(obj, obj2) <> 0 Then Exit
							Endif
						Endif
					Next
				Endif
			Endif
		Next
		CleanupLists()
	End
	'------------------------------------------
#Rem
'summery:Does a collision check on the given object. 
'The object needs to be active. If a collision appears, ftEngine.OnObjectCollision is called.
#End
	Method CollisionCheck:Void(obj:ftObject)
		Local obj2:ftObject
		If obj.isActive = True Then 
			If obj.collGroup > 0 Then 
				For obj2 = Eachin objList	
					If obj <> obj2 Then
						If obj.CheckCollision(obj2)
							If engine.OnObjectCollision(obj, obj2) <> 0 Then Exit
						Endif
					Endif
				Next
			Endif
			If obj.deleted = True Then obj.Remove(True)
		Endif
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Create an alpha transition for the layer.
'The duration is the time in milliseconds, the transition takes to complete. Only a transID > 0 will fire the [b]ftEngine.OnLayerTrans[/b] method.
#End
'seeAlso:CreateTransPos
	Method CreateTransAlpha:ftTrans(alpha:Float, duration:Float, relative:Int, transId:Int=0 )
		Local trans:ftTrans = New ftTrans
		trans.engine = Self.engine
		trans.obj = Null
		trans.layer = Self
		
		'trans.startTime = Self.engine.time
		'trans.currTime = trans.startTime
		trans.currTime = Self.engine.time
		'trans.lastTime = trans.startTime
		'trans.endTime = trans.startTime + duration
		trans.finishID = transId
		trans.duration = duration
		trans.AddAlpha(alpha,Self,duration, relative)
		
		trans.transNode = Self.transitionList.AddLast(trans)
		Return trans
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Create a position transition.
'The duration is the time in milliseconds, the transition takes to complete. Only a transID > 0 will fire the [b]ftEngine.OnLayerTrans[/b] method.
#End
'seeAlso:CreateTransAlpha
	Method CreateTransPos:ftTrans(xt:Float, yt:Float, duration:Float, relative:Int, transId:Int=0 )
		Local trans:ftTrans = New ftTrans
		trans.engine = Self.engine
		trans.obj = Null
		trans.layer = Self
		trans.currTime = Self.engine.time
		trans.finishID = transId
		trans.duration = duration
		trans.AddPos(xt, yt, Self, duration, relative)
		
		trans.transNode = Self.transitionList.AddLast(trans)
		Return trans
	End
'#DOCOFF#
	'-----------------------------------------------------------------------------
	Method New()
		objList.layer = Self
	End 
'#DOCON#
	'-----------------------------------------------------------------------------
'summery:Returns if a layer is active or not.	
'seeAlso:SetActive
	Method GetActive:Bool()
		Return isActive
	End 
	'-----------------------------------------------------------------------------
'summery:Returns the alpha value of a given layer, ranging from 0.0 to 1.0.	
'seeAlso:SetAlpha
	Method GetAlpha:Float()
		Return alpha
	End 
	'-----------------------------------------------------------------------------
'summery:Returns the layer ID value.
'seeAlso:SetID
	Method GetID:Int ()
		Return id
	End	
	'-----------------------------------------------------------------------------
'summery:Returns the first active object found at the given coordinates.
	Method GetObjAt:ftObject(x:Float, y:Float)
		'For Local obj := Eachin objList
		For Local obj := Eachin objList.Backwards()
			'If obj.touchMode > 0 
			If obj.GetActive()=True Then 
				If Self.isGUI=True Then
					If obj.internal_isObjAt(x-Self.engine.camX,y-Self.engine.camY) Then
						Return obj
					Endif
				Else
					'If obj.CheckTouchHit(x,y) Then 
					If obj.internal_isObjAt(x,y) Then
						Return obj
					Endif
				Endif
			Endif
		Next
		Return Null
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Returns the number of objects in a layer. 
'Type=0 >>> All objects are counted
'Type=1 >>> Only active objects are counted
'Type=2 >>> Only active and visible objects are counted
#End
	Method GetObjCount:Int(countType:Int=0)
		Local oc:Int = 0
		Select countType
			Case 1
				For Local obj := Eachin objList
					If obj.GetActive()=True Then 
						oc += 1
					Endif
				Next
			Case 2
				For Local obj := Eachin objList
					If obj.GetActive()=True And obj.GetVisible()=True Then 
						oc += 1
					Endif
				Next
			Default
				oc = objList.Count()
		End
		Return oc
	End
	'-----------------------------------------------------------------------------
'summery:Returns the object with the given index of a layer. Index starts with 1.
	Method GetObj:ftObject(index:Int)
		Local i:Int = 0
		For Local obj := Eachin objList
			i+=1
			If i = index Then Return obj
		Next 
		Return Null
	End
	'-----------------------------------------------------------------------------
'summery:Returns the number of active transitions from all objects in a layer.
	Method GetObjTransCount:Int()
		Local c:Int = 0
		For Local obj := Eachin objList
			c += obj.GetTransitionCount()
		Next 
		Return c
	End
	'-----------------------------------------------------------------------------
'summery:Returns the position of a layer in a 2D Float array.
'seeAlso:SetPos,GetPosX,GetPosY
	Method GetPos:Float[]()
		Local p:Float[2]
		p[0] = xPos
	     p[1] = yPos
		Return p		
	End
	'-----------------------------------------------------------------------------
'summery:Returns the X position of a layer.
'seeAlso:SetPosX,GetPosY,GetPos
	Method GetPosX:Float()
		Return xPos
	End 
	'-----------------------------------------------------------------------------
'summery:Returns the Y position of a layer.
'seeAlso:SetPosY,GetPosX,GetPos
	Method GetPosY:Float()
		Return yPos
	End 
	'-----------------------------------------------------------------------------
'summery:Returns the scale factor of a layer.
'seeAlso:SetScale
	Method GetScale:Float()
		Return scale
	End 
	'-----------------------------------------------------------------------------
'summery:Returns the layer tag value.
'seeAlso:SetTag
	Method GetTag:Int ()
		Return tag
	End	
	'-----------------------------------------------------------------------------
'summery:Returns the amount of active transitions of the layer.
	Method GetTransitionCount:Int ()
		Return transitionList.Count()
	End
	'-----------------------------------------------------------------------------
'summery:Returns if a given layer is visible or not.	
'seeAlso:SetVisible
	Method GetVisible:Bool()
		Return isVisible
	End 
	'------------------------------------------
'summery:Removes this layer from the engine. If the delObjects flag is set to TRUE, then it will remove all attached objects too.
	Method Remove:Void(delObjects:Bool = False)
		If Self.engine <> Null Then
			For Local trans := Eachin transitionList.Backwards()    '1.5.7
				trans.Cancel()
			Next
			If delObjects = True Then
				Self.RemoveAllObjects()
			Endif
			For Local scene:= Eachin Self.engine.sceneList
				scene.RemoveLayer(Self)
			Next 
			Self.engineNode.Remove()     
			Self.engine = Null
		Endif
	End
	'------------------------------------------
'summery:Removes all objects assigned to a layer.
	Method RemoveAllObjects:Void()
		For Local obj:ftObject = Eachin objList.Backwards()
			If inUpdate Or inTouch Then 
				obj.Remove(False)
			Else
				obj.Remove(True)
			Endif
		Next
	End
	'------------------------------------------
'summery:Removes all objects with the given ID and assigned to the layer.	
	Method RemoveAllObjectsByID:Void(objID:Int)
		For Local obj := Eachin objList.Backwards()
			If obj.id = objID Then 
				If inUpdate Or inTouch Then 
					obj.Remove(False)
				Else
					obj.Remove(True)
				Endif
			Endif
		Next
	End
	'------------------------------------------
'changes:Changed/Fixed in v1.58 regarding layer scaling and layerScissor.
#Rem
'summery:Render all visible and active objects of a layer.
'Objects are normally rendered in their order of creation, unless you have sorted the objects of a layer via the ftLayer.SortObjects method. 
'Child objects are rendered right after their parent.
#End
'seeAlso:SetVisible,SetGUI,SetLayerScissor
	Method Render:Void()
		Local sc:Float[4] 
		Local _scissor:Bool = False
		PushMatrix
		'If xPos <> 0.0 Or yPos <> 0.0 Then Translate (xPos, yPos) 
		
		'If angle <> engine.lastLayerAngle Then 
		'	Rotate(-angle)
		'	engine.lastLayerAngle = angle
		'Endif
		If Self.angle <> 0
			RotateDisplay(engine.GetCanvasWidth()/2.0,engine.GetCanvasHeight()/2.0,-angle)
		Endif
		engine.lastLayerAngle = angle
		
		If scale <> engine.lastLayerScale Then 
			'Scale(scale, scale)
			engine.lastLayerScale = scale
		Endif
		If isVisible=True Then
			If Self.scissorX <> 0.0 Or Self.scissorY <> 0.0 Or Self.scissorWidth <> 0.0 Or Self.scissorHeight <> 0.0
				sc = mojo.GetScissor()

				'mojo.SetScissor( engine.autofitX+Self.scissorOffX, engine.autofitY+Self.scissorOffY, (engine.canvasWidth+Self.scissorOffWidth)*engine.scaleX, (engine.canvasHeight+Self.scissorOffHeight)*engine.scaleY )
				mojo.SetScissor( engine.autofitX + Self.scissorX * engine.scaleX, engine.autofitY + Self.scissorY * engine.scaleY, Self.scissorWidth * engine.scaleX, Self.scissorHeight * engine.scaleY )
           
				_scissor = True
			Endif
			For Local obj := Eachin objList
				If Self.isGUI = True Then
					If obj.isVisible And obj.isActive And obj.parentObj = Null
						If obj.type = ftEngine.otGUI
							ftGuiMng(obj).Render(Self.xPos, Self.yPos)
						Else
							obj.Render(Self.xPos, Self.yPos)
						Endif
					Endif
				Else
					If obj.isVisible And obj.isActive And obj.parentObj = Null
						If obj.type = ftEngine.otGUI
							ftGuiMng(obj).Render(Self.xPos-engine.camX, Self.yPos-engine.camY)
							'ftGuiMng(obj).Render((Self.xPos-engine.camX)/Self.scale, (Self.yPos-engine.camY)/Self.scale)
						Else
							obj.Render(Self.xPos-engine.camX, Self.yPos-engine.camY)
							'obj.Render((Self.xPos-engine.camX)/Self.scale, (Self.yPos-engine.camY)/Self.scale)
						Endif
					Endif
				Endif
			Next
			If _scissor = True
				'mojo.SetScissor( engine.autofitX, engine.autofitY, (engine.canvasWidth)*engine.scaleX, (engine.canvasHeight)*engine.scaleY )
'mojo.SetScissor( 0, 0 ,DeviceWidth() , DeviceHeight() )
mojo.SetScissor( sc[0], sc[1] ,sc[2] , sc[3] )
			Endif
		Endif
		PopMatrix
	End
	'------------------------------------------
'summery:Set the active flag of a layer.
'seeAlso:GetActive
	Method SetActive:Void(activeFlag:Bool)
		isActive = activeFlag
	End
	'------------------------------------------
'summery:Set the alpha value of a layer, ranging from 0.0 (invisible) to 1.0 (fully visible).
'seeAlso:GetAlpha
	Method SetAlpha:Void(newAlpha:Float, relative:Int=False)
		If relative=True Then
			alpha += newAlpha
		Else
			alpha = newAlpha
		Endif
		If alpha < 0.0 Then alpha = 0.0
		If alpha > 1.0 Then alpha = 1.0
	End
'#DOCOFF#	
	'-----------------------------------------------------------------------------
	Method SetAngle:Void (newAngle:Float, relative:Int = False )
		If relative = True
			angle = angle + newAngle
		Else
			angle = newAngle
		Endif
	End
'#DOCON#	
	'-----------------------------------------------------------------------------
'summery:Sets the layer GUI flag. When rendering a GUI layer, camera positions are not taken into a calculation of the position of this layer.
'seeAlso:Render
	Method SetGUI:Void (guiFlag:Bool )
		Self.isGUI = guiFlag
	End	
	'-----------------------------------------------------------------------------
'summery:Sets the layer ID field with any value.
'seeAlso:GetID
	Method SetID:Void (layerID:Int )
		Self.id = layerID
	End	
	'------------------------------------------
'changes:Changed in v1.58. No offset but real sizes.
'summery:Sets the position and the size of the scissor for this layer. Width and Height take a virtual canvas size into account.
'seeAlso:Render
	Method SetLayerScissor:Void(X:Float, Y:Float, Width:Float, Height:Float)
		Self.scissorX = X		
		Self.scissorY = Y
		Self.scissorWidth = Width
		Self.scissorHeight = Height
	End
	'-----------------------------------------------------------------------------
'summery:Set the X and Y position of a layer.
'seeAlso:GetPos,SetPosXSetPosY
	Method SetPos:Void (x:Float, y:Float, relative:Int = False )
		If relative = True
			xPos = xPos + x
			yPos = yPos + y
		Else
			xPos = x
			yPos = y
		Endif
	End
	'-----------------------------------------------------------------------------
'summery:Set the X position of a layer.
'seeAlso:GetPosX,SetPos,SetPosY
	Method SetPosX:Void (x:Float, relative:Int = False )
		If relative = True
			xPos = xPos + x
		Else
			xPos = x
		Endif
	End
	'-----------------------------------------------------------------------------
'summery:Set the Y position of a layer.
'seeAlso:GetPosY,SetPos,SetPosX
	Method SetPosY:Void (y:Float, relative:Int = False )
		If relative = True
			yPos = yPos + y
		Else
			yPos = y
		Endif
	End
	'-----------------------------------------------------------------------------
'summery:Set the scale factor of a layer.
'seeAlso:GetScale
	Method SetScale:Void (scaleFactor:Float, relative:Int = False )
		If relative = True
			scale += scaleFactor
		Else
			scale = scaleFactor
		Endif
	End
	'-----------------------------------------------------------------------------
'summery:Sets the layer tag field with any value.
'seeAlso:GetTag
	Method SetTag:Void (newTag:Int )
		Self.tag = newTag
	End	
	'------------------------------------------
'summery:Set the visible flag of a layer.
'seeAlso:GetVisible,Render
	Method SetVisible:Void(visibleFlag:Bool)
		isVisible = visibleFlag
	End
	'-----------------------------------------------------------------------------
#rem
summery:Sorts the object list of a layer. 
Internally it will call the ftEngine.OnObjectSort method. 
Overwrite that method to get a different sorting. The default sorting will sort objects by their Z coordinate.
#End
	Method SortObjects:Void()
		objList.Sort()
	End
	'------------------------------------------
#Rem
'summery:Executes a touch check to each object at the given position.
'The object has to have a touchmode > 0 and needs to be active.
'If a touch of an object was detected, then the ftEngine.OnObjectTouch method is called with the object and the touchID as a parameter.
#End
	Method TouchCheck:Void(x:Float, y:Float, touchID:Int)
		inTouch = True
		For Local obj := Eachin objList.Backwards()
			If obj.touchMode > 0 And obj.isActive = True
				'If obj.CheckTouchHit(x,y) Then engine.OnObjectTouch(obj,touchID)
				If obj.CheckTouchHit(x - Self.xPos, y - Self.yPos)
					If engine.OnObjectTouch(obj,touchID) <> 0 Then Exit
				Endif
			Endif
		Next
		If inUpdate = False Then CleanupLists()
		inTouch = False
	End
	'------------------------------------------
#Rem
'summery:Updates all transitions and objects of a layer.
'The speed parameter will be used to automatically update the objects.
'After the layer was updated and the engine is not paused, the ftEngine.OnLayerUpdate method is called.
#End
	Method Update:Void(speed:Float=1.0)
		inUpdate = True
		Self.engine.delta = speed
		If engine.isPaused = False Then
			For Local trans:ftTrans = Eachin transitionList
				trans.Update()
			Next
		Endif
		
		For Local obj := Eachin objList
			If obj.parentObj = Null
				If obj.type = ftEngine.otGUI 
					ftGuiMng(obj).Update(speed)
				Else
					obj.Update(speed)
				Endif
			Endif
		Next
	
		If engine.isPaused = False Then engine.OnLayerUpdate(Self)
		CleanupLists()
		If inTouch = False Then CleanupLists()
		inUpdate = False
	End
End


#rem
footer:This fantomEngine framework is released under the MIT license:
[quote]Copyright (c) 2011-2016 Michael Hartlef

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software, and to permit persons to whom the software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
[/quote]
#end