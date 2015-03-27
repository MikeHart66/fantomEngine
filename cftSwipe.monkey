'#DOCOFF#
#rem
	Title:        fantomEngine
	Description:  A 2D game framework for the Monkey programming language
	
	Author:       Michael Hartlef
	Contact:      michaelhartlef@gmail.com
	
	Website:      http://www.fantomgl.com
	
	License:      MIT
#End

'nav:<blockquote><nav><b>fantomEngine documentation</b> | <a href="index.html">Home</a> | <a href="classes.html">Classes</a> | <a href="3rdpartytools.html">3rd party tools</a> | <a href="examples.html">Examples</a> | <a href="changes.html">Changes</a></nav></blockquote>

Import fantomEngine

'***************************************
Class ftSwipe
	Const _maxTouchIndex:Int = 10
	Field startX:Float[_maxTouchIndex]
	Field startY:Float[_maxTouchIndex]
	Field endX:Float[_maxTouchIndex]
	Field endY:Float[_maxTouchIndex]
	Field diffX:Float[_maxTouchIndex]
	Field diffY:Float[_maxTouchIndex]

	Field startTime:Int[_maxTouchIndex]
	Field endTime:Int[_maxTouchIndex]
	Field diffTime:Int[_maxTouchIndex]

	Field touchActive:Bool[_maxTouchIndex]
	
	Field angle:Float[_maxTouchIndex]
	Field dist:Float[_maxTouchIndex]
	Field speed:Float[_maxTouchIndex]

	Field angleSnap:Int = 1
	Field tmpAngle:Int
	Field deadDist:Float = 20.0
	Field engine:ftEngine
	Field swipeActive:Bool = False
	'------------------------------------------
	Method New()
		For Local i:Int = 0 To Self._maxTouchIndex-1
			startX[i] = 0.0
			startY[i] = 0.0
			endX[i] = 0.0
			endY[i] = 0.0
			diffX[i] = 0.0
			diffY[i] = 0.0
			startTime[i] = 0
			endTime[i] = 0
			diffTime[i] = 0
			touchActive[i] = False
			angle[i] = 0.0
			dist[i] = 0.0
			speed[i] = 0.0
		Next
	End
	'------------------------------------------
	Method Update:Void(index:Int = 0)
		'No touch 
		If TouchDown(index) = 0 Then
			If Self.touchActive[index] = True Then
				'touch has ended
				Self.endX[index] = engine.GetTouchX(index)
				Self.endY[index] = engine.GetTouchY(index)
				Self.touchActive[index] = False
				Self.endTime[index] = engine.GetTime()
				
				'Calculate angle				
				Self.diffX[index] = Self.endX[index] - Self.startX[index]
				Self.diffY[index] = Self.endY[index] - Self.startY[index]
			
    			Self.angle[index] = ATan2( Self.diffY[index], Self.diffX[index]) + 90.0
				If Self.angle[index] < 0.0 Then 
					Self.angle[index] = 360.0 + Self.angle[index]
				Endif
				'Angle snapping
				If Self.angleSnap > 1 Then
					Self.tmpAngle = ((Self.angle[index] / Self.angleSnap) + 0.5)
					Self.angle[index] = Self.tmpAngle * Self.angleSnap
					If Self.angle[index] >= 360.0 Then 
						Self.angle[index] = 0.0
					Endif
				Endif
				
				'Calculate distance
				Self.dist[index] = Sqrt(Self.diffX[index] * Self.diffX[index] + Self.diffY[index] * Self.diffY[index])
				
				'Calculate time
				Self.diffTime[index] = Self.endTime[index] - Self.startTime[index]
				If Self.diffTime[index] = 0 Then
					Self.diffTime[index] = 1
				Endif

				'Calculate speed
				Self.speed[index] = Self.dist[index] / Self.diffTime[index]

				'Call the event handler
				If Self.dist[index] > Self.deadDist Then
					engine.OnSwipeDone(index, Self.angle[index], Self.dist[index], Self.speed[index])
				Endif
			Endif 
		Else
			'Screen is touched
			If Self.touchActive[index] = False Then
				'Start touching
				Self.startX[index] = engine.GetTouchX(index)
				Self.startY[index] = engine.GetTouchY(index)
				Self.startTime[index] = engine.GetTime()
				Self.touchActive[index] = True
			Else
				'Current touch
				Self.endX[index] = engine.GetTouchX(index)
				Self.endY[index] = engine.GetTouchY(index)
			Endif
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