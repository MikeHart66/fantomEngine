#rem
	Title:        fantomEngine
	Description:  A 2D game framework for the Monkey programming language
	
	Author:       Michael Hartlef
	Contact:      michaelhartlef@gmail.com
	
	Website:      http://www.fantomgl.com
	
	License:      MIT
#End


'nav:<blockquote><nav><b>fantomEngine documentation</b> | <a href="index.html">Home</a> | <a href="classes.html">Classes</a> | <a href="3rdpartytools.html">3rd party tools</a> | <a href="examples.html">Examples</a> | <a href="changes.html">Changes</a></nav></blockquote>

'header:The module cftKeyMapping contains ...


Import fantomEngine

'***************************************
'summery:The class [b]ftKeyMapping[/b] is an object which helps you supporting different key maps in your app.
Class ftKeyMapping
'#DOCOFF#
	Field keyMap:IntMap<Int> = Null
	'------------------------------------------
	Method New()
		Self.keyMap = New IntMap<Int>
	End
'#DOCON#
	'------------------------------------------
#Rem
'summery:This method clears all the mapping data.
#End
	Method Clear:Void()
		Self.keyMap.Clear()
	End
	'------------------------------------------
#Rem
'summery:This method sets the mapping of a key code.
#End
'seeAlso:GetKey,SafeToString
	Method SetKey:Void(keyCode:Int, mapCode:Int)
		Self.keyMap.Set(keyCode, mapCode)
	End
	'------------------------------------------
#Rem
'summery:This method returns the mapped key code.
'If no mapping is found, it will return the given key code.
#End
'seeAlso:SetKey,LoadFromString
	Method GetKey:Int(keyCode:Int)
		Local retCode:Int  = Self.keyMap.Get(keyCode)
		If retCode = 0 Then retCode = keyCode
		Return retCode
	End
	'------------------------------------------
#Rem
'summery:This method loads the keymapping class via a string
'The format of the string has to be (key;mappedKey~nkey;mappedKey...):
'65;32
'67;33
#End
'seeAlso:SaveToString,GetKey
	Method LoadFromString:Void(mapStr:String)
		Self.Clear()
		Local lines := mapStr.Split("~n")
		For Local line:= Eachin lines
			If line = "" Then Continue
			Local ct$[] = line.Split(";")
			Local keyVal:Int = Int(ct[0])
			Local mapVal:Int = Int(ct[1])
			Self.SetKey(keyVal,mapVal)
		Next
	End	


	'------------------------------------------
#Rem
'summery:This method saves the key mapping data to a string.
#End
'seeAlso:LoadFromString,SetKey
	Method SaveToString:String()
		Local retStr:String=""
		For Local item:= Eachin Self.keyMap
			retStr = retStr + item.Key() + ";" + item.Value() + "~n"
		Next
		Return retStr
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