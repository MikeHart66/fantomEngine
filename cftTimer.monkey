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
'header:The class [b]ftTimer[/b] handles ftEngine and ftObject timer objects.  
#End

'***************************************
Class ftTimer
'#DOCOFF#

	Field id:Int=0
	'Field startTime:Int=0
	Field currTime:Int=0
	Field duration:Int=0
	'Field endTime:Int=0
	Field intervall:Int=0
	Field loop:Int = 0
	Field obj:ftObject=Null
	Field engine:ftEngine = Null
	Field timerNode:list.Node<ftTimer> = Null
	Field deleted:Bool = False
	Field isPaused:Bool = False
'#DOCON#	
	'------------------------------------------
'summery:Returns TRUE if a transition is paused. 
'seeAlso:SetPaused
	Method GetPaused:Bool()
		Return Self.isPaused
	End
	'------------------------------------------
'summery:With this method removes the timer. 
	Method RemoveTimer:Void()

		'If Self <> Null
			If Self.timerNode <> Null Then	Self.timerNode.Remove()
			Self.timerNode = Null
			Self.obj = Null
			Self.engine = Null
		'Endif
	End
	'------------------------------------------
'summery:With this method you can pause and resume the timer. 
'seeAlso:GetPaused,Update
	Method SetPaused:Void(pauseFlag:Bool = True)
		Self.isPaused = pauseFlag
	End
'#DOCOFF#
	'------------------------------------------
	Method Update:Void()
'seeAlso:SetPaused
		Local oldCurrTime:Int
		Local diffTime:Int
		If deleted = False Then
			If Self.duration > 0 Then
				oldCurrTime = currTime
				currTime = engine.time
				diffTime = currTime - oldCurrTime
				If Self.isPaused <> True And engine.isPaused <> True Then
					duration -= diffTime 
				Endif 

				If duration <= 0 Then
					If Self.obj = Null Then
						engine.OnTimer(id)
					Else
						engine.OnObjectTimer(id, obj)
					Endif
					If loop = 0 Then
						'obj.timerList.Remove(Self)
						'Self.Remove()         '1.2.1
						If Self.obj = Null Then
							Self.RemoveTimer()
						Else
							Self.deleted = True
						Endif
					Endif
					If loop = -1 Then duration += intervall
					If loop > 0 Then
						duration += intervall
						loop -= 1
					Endif
				Endif
			Else
				Self.deleted = True
			Endif
		Endif
	End
	'------------------------------------------
#Rem
	Method Update_old:Void()
		Local oldCurrTime:Int
		Local diffTime:Int
		If deleted = False Then
			If Self.currTime > 0 Then
				oldCurrTime = currTime
				currTime = engine.time

				If Self.isPaused = True Or engine.isPaused = True Then
					diffTime = currTime - oldCurrTime
					endTime += diffTime 
					startTime += diffTime
				Endif 

				If currTime >= endTime Then
					engine.OnObjectTimer(id, obj)
					If loop = 0 Then
						'obj.timerList.Remove(Self)
						'Self.Remove()         '1.2.1
						Self.deleted = True
					Endif
					If loop = -1 Then endTime += intervall
					If loop > 0 Then
						endTime += intervall
						loop -= 1
					Endif
				Endif
			Endif
		Endif
	End
#End	
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