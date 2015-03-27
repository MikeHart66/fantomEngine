'#DOCON#
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
'#DOCOFF#
'------------------------------------------
Function XWA:Int (_dummy:Int)
	Return 0
End

'------------------------------------------
Function _CalculateCatmull:ftVec2D(t:Float, p0:ftVec2D, p1:ftVec2D, p2:ftVec2D, p3:ftVec2D )
	Local ret:ftVec2D = New ftVec2D
	ret.x = 0.5 *((2.0*p1.x) + (p2.x-p0.x)*t + (2.0*p0.x-5.0*p1.x+4.0*p2.x-p3.x)*t*t + (3.0*p1.x-p0.x-3.0*p2.x+p3.x)*t*t*t)   'X
   	ret.y = 0.5 *((2.0*p1.y) + (p2.y-p0.y)*t + (2.0*p0.y-5.0*p1.y+4.0*p2.y-p3.y)*t*t + (3.0*p1.y-p0.y-3.0*p2.y+p3.y)*t*t*t)   'Y
	Return ret
End Function
'------------------------------------------
#rem
summery: This funtion rotates the display.
It is for internal purposes only.
#end
Function RotateDisplay:Void (X:Float, Y:Float, angle:Float)
	'PushMatrix				' Store current rotation, scale, etc
	Translate X, Y			' Shift origin across to here
	Rotate angle			' Rotate around origin
	Translate -X, -Y		' Shift origin back where it was
	'Return 0
End
'------------------------------------------
'#DOCON#
#Rem
'summery:Calculates the pitchrate for the amount of given halfsteps. 
The default base note is 'A4'
#End
Function GetPitchRate:Float(halfStep:Float, base:Float=1.0)
	'Pow(2.0,1.0/12.0) = 1.0594630943592953
	Local pr:Float = Pow(1.0594630943592953,halfStep) * base
	Return pr
End	

'#DOCOFF#	
'***************************************
Class tPointS
	  Field x:Float
	  Field y:Float
End
'***************************************
Class tLine2D
	  Field p1:tPointS
	  Field p2:tPointS
	'------------------------------------------
	  Method New()
		p1 = New tPointS
		p2 = New tPointS
	  End
End


'#DOCON#



#rem
footer:This fantomEngine framework is released under the MIT license:
[quote]Copyright (c) 2011-2015 Michael Hartlef

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software, and to permit persons to whom the software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
[/quote]
#end