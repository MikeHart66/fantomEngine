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
#Rem
'header:The class [b]ftScene[/b] groups assigned layers and lets you manage them in a combined way. Layers can be connected to several scenes at one time.
#End




'***************************************
Class ftScene
'#DOCOFF#
	Field layerList := New List<ftLayer>
	Field engine:ftEngine = Null
	Field engineNode:list.Node<ftScene> = Null
	
	Field isActive:Bool = True
	Field isVisible:Bool = True
	Field alpha:Float = 1.0
	
'#DOCON#

	'------------------------------------------
#Rem
'summery:Add a layer to a scene.
#End
'SeeAlso:RemoveLayer
	Method AddLayer:Void(layer:ftLayer)
		layerList.AddLast(layer)
	End
	'-----------------------------------------------------------------------------
'changes:fixed in v1.54
#Rem
'summery:Create an alpha transition for the scene.
'The duration is the time in milliseconds, the transition takes to complete. Only a transID > 0 will fire the [b]ftEngine.OnLayerTrans[/b] method for the first layer of a scene.
#End
'seeAlso:CreateTransPos
	Method CreateTransAlpha:ftTrans(alpha:Float, duration:Float, relative:Int, transId:Int=0 )
		Local layer:ftLayer = Null
		Local trans:ftTrans = Null
		Local c:Int = 0
		For layer = Eachin layerList
			If c = 0 Then
				trans = layer.CreateTransAlpha(alpha, duration, relative, transId )
			Else
				trans.AddAlpha(alpha, layer, duration, relative )
			Endif
			c += 1
		Next
		Return trans
	End
	'-----------------------------------------------------------------------------
'changes:fixed in v1.54
#Rem
'summery:Create an position transition for the scene.
'The duration is the time in milliseconds, the transition takes to complete. Only a transID > 0 will fire the [b]ftEngine.OnLayerTrans[/b] method for the first layer of a scene.
#End
'seeAlso:CreateTransAlpha
	Method CreateTransPos:ftTrans(xt:Float, yt:Float, duration:Float, relative:Int, transId:Int=0 )
		Local layer:ftLayer = Null
		Local trans:ftTrans = Null
		Local c:Int = 0
		For layer = Eachin layerList
			If c = 0 Then
				trans = layer.CreateTransPos(xt, yt, duration, relative, transId )
			Else
				trans.AddPos(xt, yt, layer, duration, relative )
			Endif
			c += 1
		Next
		Return trans
	End
	'------------------------------------------
#Rem
'summery:Returns the active flag of the scene.	
#End
'SeeAlso:SetActive
	Method GetActive:Bool()
		Return Self.isActive
	End
	'------------------------------------------
#Rem
'summery:Returns the visible flag of the scene.	
#End
'SeeAlso:SetVisible
	Method GetVisible:Bool()
		Return Self.isVisible
	End
	'------------------------------------------
#Rem
'summery:Remove the scene from the engine.
#End
	Method Remove:Void()
		layerList.Clear()
		Self.engineNode.Remove()     
		Self.engine = Null
	End
	'------------------------------------------
#Rem
'summery:Remove a layer from a scene.
#End
'SeeAlso:AddLayer
	Method RemoveLayer:Void(layer:ftLayer)
		layerList.RemoveEach(layer)
	End
	'------------------------------------------
#Rem
'summery:Set the active flag of the scenes layers.
#End
'SeeAlso:GetActive
	Method SetActive:Void(activeFlag:Bool)
		Local layer:ftLayer = Null
		For layer = Eachin layerList
			layer.SetActive(activeFlag)
		Next
		Self.isActive = activeFlag
		
	End
	'------------------------------------------
#Rem
'summery:Set the alpha value of each layer in the scene.
#End
'seeAlso:SetPos
	Method SetAlpha:Void(newAlpha:Float, relative:Bool = False)
		Local layer:ftLayer = Null
		For layer = Eachin layerList
			layer.SetAlpha(newAlpha, relative)
		Next
		Self.alpha = newAlpha
		
	End
	'------------------------------------------
#Rem
'summery:Set the position of each layer in the scene.
#End
'seeAlso:SetAlpha
	Method SetPos:Void(x:Float, y:Float, relative:Bool = False)
		Local layer:ftLayer = Null
		For layer = Eachin layerList
			layer.SetPos(x, y, relative)
		Next

	End
	'------------------------------------------
#Rem
'summery:Set the visible flag of the scenes layers.	
#End
'SeeAlso:GetVisible
	Method SetVisible:Void(visibleFlag:Bool)
		Local layer:ftLayer = Null
		For layer = Eachin layerList
			layer.SetVisible(visibleFlag)
		Next
		Self.isVisible = visibleFlag
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