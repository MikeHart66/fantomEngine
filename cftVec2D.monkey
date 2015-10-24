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

'header:The cftVec2D module provides a 2D vector class.

'***************************************
Class ftVec2D

	Field x:Float = 0.0
	Field y:Float = 0.0
	
	'------------------------------------------
	Method Add:Void (vector:ftVec2D)
		x += vector.x
		y += vector.y
	End
	
	'------------------------------------------
	Method Add:Void (addX:Float, addY:Float)
		x += addX
		y += addY
	End
	
	'------------------------------------------
	Method Angle:Float (vector:ftVec2D)
		Local xdiff:Float
		Local ydiff:Float 
		Local ang:Float
		xdiff = vector.x - x
		ydiff = vector.y - y
			
    	ang = ATan2( ydiff, xdiff )+90.0
		If ang < 0.0 Then 
			ang = 360.0 + ang
		Endif
		Return ang
	End
	
	'------------------------------------------
	Method Angle:Float (xPos:Float, yPos:Float)
		Local xdiff:Float
		Local ydiff:Float 
		Local ang:Float
			
		xdiff = xPos - x
		ydiff = yPos - y
			
    	ang = ATan2( ydiff, xdiff )+90.0
		If ang < 0.0 Then 
			ang = 360.0 + ang
		Endif
		Return ang
	End
	
	'------------------------------------------
	Method Angle:Float ()
		Local ang:Float
    	ang = ATan2( y, x )+90.0
		If ang < 0.0 Then 
			ang = 360.0 + ang
		Endif
		Return ang
	End
	
	'------------------------------------------
	Method Copy:ftVec2D()
		Return New ftVec2D (x, y)
	End
	'------------------------------------------
	Method Dot:Float(xPos:Float, yPos:Float)
		Return (x * xPos + y * yPos)
	End
	
	'------------------------------------------
	Method Dot:Float (vector:ftVec2D)
		Return (x * vector.x + y * vector.y)
	End
	
	'------------------------------------------
	Method Equals:Bool (vector:ftVec2D)
		Return (x = vector.x) And (y = vector.y)
	End

	'------------------------------------------
	Method Inverse:Void()
		x = -x
		y = -y
	End
	
	'------------------------------------------
	Method InverseX:Void()
		x = -x
	End
	
	'------------------------------------------
	Method InverseY:Void()
		y = -y
	End
	
	'------------------------------------------
	Method Length:Float(vector:ftVec2D)
		Local xdiff:Float
		Local ydiff:Float 
		xdiff = vector.x - x
		ydiff = vector.y - y
		
		Return Sqrt(xdiff * xdiff + ydiff * ydiff)
	End
	'------------------------------------------
	Method Length:Float(xPos:Float, yPos:Float)
		Local xdiff:Float
		Local ydiff:Float 
		xdiff = xPos - x
		ydiff = yPos - y
		
		Return Sqrt(xdiff * xdiff + ydiff * ydiff)
	End
	
	'------------------------------------------
	Method Length:Float()
		Return Sqrt (x * x + y * y)
	End
	
	'------------------------------------------
	Method Mul:Void (scalar:Float)
		x *= scalar
		y *= scalar
	End
	
	'------------------------------------------
	Method New(xp:Float, yp:Float)
		x = xp
		y = yp
	End

	'------------------------------------------
	Method Normalize:Void()
		Local length:Float = Self.Length()
		If length = 0
			Return
		Endif
		Set (x/length, y/length)
	End
	
	'------------------------------------------
'changes:New in v1.54
	Method Perp:Void()
		Local xt:Float = Self.x
		
		Self.x = Self.y
		Self.y = -xt
	End
	
	'------------------------------------------
	Method Set:Void (setX:Float, setY:Float)
		x = setX
		y = setY
	End
	
	'------------------------------------------
	Method Set:Void (vector:ftVec2D)
		x = vector.x
		y = vector.y
	End
	
	'------------------------------------------
	Method Sub:Void (vector:ftVec2D)
		x -= vector.x
		y -= vector.y
	End
	
	'------------------------------------------
	Method Sub:Void (subX:Float, subY:Float)
		x -= subX
		y -= subY
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