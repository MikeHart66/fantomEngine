'#DOCON#
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

'header:The module cftObjAnimMng contains several classes to manage animated objects inside your game.

'***************************************
'summery:The ftObjAnimMng class manages the animations of an object.
Class ftObjAnimMng
'#DOCOFF#'	
	Field currAnim:ftAnim = Null
	Field animMap:StringMap<ftAnim> = New StringMap<ftAnim>
	Field animObj:ftObject = Null
	Field isAnimPaused:Bool = False
	'-----------------------------------------------------------------------------
	Method _CopyAnim:ftObjAnimMng ()
		Local newAnimMng:ftObjAnimMng = New ftObjAnimMng
		newAnimMng.isAnimPaused = Self.isAnimPaused

		For Local currAnim:ftAnim = Eachin animMap.Values()

			Local newAnim:ftAnim = New ftAnim

			newAnim.name = currAnim.name
			newAnim.animMng = newAnimMng
			newAnim.animFrames = currAnim.animFrames
			newAnim.animTime = currAnim.animTime
			newAnim.frameTime = currAnim.frameTime
			newAnim.currFrame = currAnim.currFrame
			newAnim.frameCount = currAnim.frameCount
			If newAnim.name = Self.currAnim.name Then
				newAnimMng.currAnim = newAnim
			Endif
			newAnimMng.animMap.Set(newAnim.name,newAnim)

		Next
		Return newAnimMng
	End	
'#DOCON#	
	'-----------------------------------------------------------------------------
'summery:Add to an existing animation. Image and frame indexes start at 1.
	Method AddAnim:Void (animName:String, imgIndex:Int, _frameStart:Int = 1, _frameEnd:Int = 1)
		'Return
		Local anim:ftAnim = Null
		anim = Self.animMap.Get(animName)
		'anim.animMng = self
		If anim <> Null Then
			For Local i:Int = _frameStart To _frameEnd
				anim.AddFrame(imgIndex-1, i)
			Next
		Else
#If CONFIG="debug"
			Error("~n~nError in file fantomEngine.cftObjAnimMng, Method ftObjAnimMng.AddAnim:Void(animName:String, imgIndex:Int, _frameStart:Int = 1, _frameEnd:Int = 1):~n~nanimName ("+animName+") is unknown!")
#End
		Endif
	End	
	'-----------------------------------------------------------------------------
'summery:Creates a new animation. Image and frame indexes start at 1.
	Method CreateAnim:Void (animName:String, imgIndex:Int, _frameStart:Int = 1, _frameEnd:Int = 1)
		Local anim:ftAnim = New ftAnim
		anim.name = animName
		anim.animMng = self
		For Local i:Int = _frameStart To _frameEnd
			anim.AddFrame(imgIndex-1, i)
		Next
		Self.animMap.Set(animName,anim)
		currAnim = anim
	End	
	'-----------------------------------------------------------------------------
'summery:Get the number of frames from the active animation.
	Method GetCurrAnimCount:Int ()
		Return currAnim.animFrames.Length()
	End
	'-----------------------------------------------------------------------------
'summery:Get the current frame of the active animation.
	Method GetCurrAnimFrame:Float()
		Return (currAnim.animTime/currAnim.frameTime)+1.0
	End
	'-----------------------------------------------------------------------------
'summery:Get the animation name.
	Method GetCurrAnimName:String ()
		Return currAnim.name
	End
	'-----------------------------------------------------------------------------
'summery:Get the animation frame time.
	Method GetCurrAnimTime:Float ()
		Return currAnim.frameTime
	End
	'-----------------------------------------------------------------------------
'summery:Remove all animations.
	Method RemoveAll:Void()
		Self.animObj = Null
		Self.animMap.Clear()
	End
	'-----------------------------------------------------------------------------
'summery:Set the current active anim
	Method SetActiveAnim:Void (animName:String)
		Local anim:ftAnim = Null
		anim = Self.animMap.Get(animName)
		If anim <> Null Then
			currAnim = anim
		Endif
	End	
	'-----------------------------------------------------------------------------
'summery:Set the frame of the current animation. The frame number starts with 1.
	Method SetCurrAnimFrame:Void (frame:Float )
		If frame < 1 Then 
			frame = 1
		Elseif frame > currAnim.frameCount Then
			frame = currAnim.frameCount
		Endif
		currAnim.animTime = (frame-1) * currAnim.frameTime
		currAnim.currFrame = Int(Min(Float(currAnim.frameCount-1),(currAnim.animTime/currAnim.frameTime)))
		animObj.SetCurrImage(currAnim.animFrames[currAnim.currFrame].imgIndex+1, currAnim.animFrames[currAnim.currFrame].frameIndex )
	End
	'-----------------------------------------------------------------------------
'changes:New in version 1.54.
#Rem
'summery:Set the repeat count of the current animation.
'The default value of -1 means it runs forever. A value greater than 0 describes how many times the animation repeats itself.
#End
	Method SetCurrAnimRepeatCount:Void (repeatCount:Int = -1 )
		currAnim.loop = repeatCount
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Set the factor for the frame time of the current animation.
'The default value is 10.0. The higher the value is, the longer a frame is displayed.
#End
	Method SetCurrAnimTime:Void (time:Float = 10.0 )
		currAnim.animTime = currAnim.animTime/currAnim.frameTime
		currAnim.animTime = currAnim.animTime * time
		currAnim.frameTime = time
	End
	'-----------------------------------------------------------------------------
	Method UpdateCurrAnim:Void (delta:Float = 1.0 )
		currAnim.Update(delta)
		animObj.SetCurrImage(currAnim.animFrames[currAnim.currFrame].imgIndex+1, currAnim.animFrames[currAnim.currFrame].frameIndex )
	End	
End

'***************************************
'summery:The ftAnim class represents one animation of an object.
Class ftAnim
'#DOCOFF#'	
	Field name:String = "DEFAULT"
	'Field animFrameList := New List<ftAnimFrame>
	Field animFrames:ftAnimFrame[]

	Field animTime:Float = 0.0
	Field frameTime:Float = 10
	Field currFrame:Int = 0
	Field frameCount:Int = 0
	Field loop:Int = -1
	Field animMng:ftObjAnimMng = null
'#DOCON#'	
	'-----------------------------------------------------------------------------
'summery:Adds a frame to an animated object.
	Method AddFrame:Void (_imgIndex:Int, _frameIndex:Int)
		Local frame:ftAnimFrame = New ftAnimFrame
		
		frame.imgIndex = _imgIndex
		frame.frameIndex = _frameIndex
		
		Local currSize:Int = Self.animFrames.Length()
		Self.animFrames = Self.animFrames.Resize(currSize + 1)
		Self.animFrames[currSize] = frame
		Self.frameCount = Self.animFrames.Length()
	End	
	'-----------------------------------------------------------------------------
'summery:Updates the animation of an object.
	Method Update:Void (delta:Float = 1.0)
		Self.animTime += delta 
		If (Self.animTime > (Self.frameCount*Self.frameTime)) Then 
			If Self.loop = -1 Then 
				Self.animTime -= (Self.frameCount*Self.frameTime)
			Elseif Self.loop > 0 Then
				Self.animTime -= (Self.frameCount*Self.frameTime)
				Self.loop -= 1
			Endif
			Self.animMng.animObj.engine.OnObjectAnim(Self.animMng.animObj)
		Endif			
		currFrame = Int(Min(Float(Self.frameCount-1),(Self.animTime/Self.frameTime)))
	End
End

'#DOCOFF#'	
'***************************************
Class ftAnimFrame
	Field imgIndex:Int = 0
	Field frameIndex:Int = 0
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