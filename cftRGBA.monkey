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

'header:The cftRGBA module provides a RGBA color class.

'***************************************
Class ftRGBA

'#DOCOFF#
	Field red:Float = 255
	Field green:Float = 255
	Field blue:Float = 255
	Field alpha:Float = 1.0
'#DOCON#	
	'------------------------------------------
	Method Add:Void(_red:Float, _green:Float, _blue:Float, _alpha:Float=-1.0)
		Self.red += _red
		Self.green += _green
		Self.blue += _blue
		If _alpha >= 0.0 Then Self.alpha += _alpha
		
		Self.red = Min(Self.red, 255.0)
		Self.green = Min(Self.green, 255.0)
		Self.blue = Min(Self.blue, 255.0)
		If _alpha >= 0.0 Then Self.alpha = Min(Self.alpha, 1.0)
	End
	
	'------------------------------------------
	Method Add:Void(color:ftRGBA)
		Self.Add (color.red, color.green, color.blue, color.alpha)
	End
	
	'------------------------------------------
	Method Copy:ftRGBA()
		Return New ftRGBA (red, green, blue, alpha)
	End
	
	'------------------------------------------
	Method Inverse:Void(inklAlpha:Bool = False)
		Self.red = 255.0 - Self.red
		Self.green = 255.0 - Self.green
		Self.blue = 255.0 - Self.blue
		If inklAlpha = True Then Self.alpha = 1.0 - Self.alpha
	End
	
	'------------------------------------------
	Method Multiply:Void(_red:Float, _green:Float, _blue:Float, _alpha:Float=-1.0)
		Self.red *= _red
		Self.green *= _green
		Self.blue *= _blue
		If _alpha >= 0.0 Then Self.alpha *= _alpha
		
		Self.red = Min(Self.red, 255.0)
		Self.green = Min(Self.green, 255.0)
		Self.blue = Min(Self.blue, 255.0)
		If _alpha >= 0.0 Then Self.alpha = Min(Self.alpha, 1.0)
	End
	
	'------------------------------------------
	Method Multiply:Void(color:ftRGBA)
		Self.Multiply (color.red, color.green, color.blue, color.alpha)
	End
	
	'------------------------------------------
	Method New (_red:Float, _green:Float, _blue:Float, _alpha:Float=-1.0)
		If _alpha < 0.0 Then _alpha = 1.0
		Self.Set (_red, _green, _blue, _alpha)
	End
	
	'------------------------------------------
	Method Set:Void (color:ftRGBA)
		Self.Set (color.red, color.green, color.blue, color.alpha)
	End
	
	'------------------------------------------
	Method Set:Void (_red:Float, _green:Float, _blue:Float, _alpha:Float=-1.0)
		red = _red
		green = _green
		blue = _blue
		If _alpha >= 0.0 Then alpha = _alpha
	End
	'------------------------------------------
	Method Sub:Void(_red:Float, _green:Float, _blue:Float, _alpha:Float=-1.0)
		Self.red -= _red
		Self.green -= _green
		Self.blue -= _blue
		If _alpha >= 0.0 Then Self.alpha -= _alpha
		
		Self.red = Max(Self.red, 0.0)
		Self.green = Max(Self.green, 0.0)
		Self.blue = Max(Self.blue, 0.0)
		If _alpha >= 0.0 Then Self.alpha = Max(Self.alpha, 0.0)
	End
	
	'------------------------------------------
	Method Sub:Void(color:ftRGBA)
		Self.Sub (color.red, color.green, color.blue, color.alpha)
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