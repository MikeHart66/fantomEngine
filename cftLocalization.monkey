#rem
	Title:        fantomEngine
	Description:  A 2D game framework for the Monkey programming language
	
	Author:       Michael Hartlef
	Contact:      michaelhartlef@gmail.com
	
	Website:      http://www.fantomgl.com
	
	License:      MIT
#End


'nav:<blockquote><nav><b>fantomEngine documentation</b> | <a href="index.html">Home</a> | <a href="classes.html">Classes</a> | <a href="3rdpartytools.html">3rd party tools</a> | <a href="examples.html">Examples</a> | <a href="changes.html">Changes</a></nav></blockquote>
'header:The module [b]cftLocalization[/b] contains...


Import fantomEngine

'***************************************
'summery:The class [b]ftLocalization[/b] is an object which helps you supporting multiple languages in your app.
Class ftLocalization
'#DOCOFF#
	Field strMap:StringMap<String> = Null
	Field defaultLang:String = "EN"
	'------------------------------------------
	Method _FindLocalStr:String(text:String, lang:String)
		Local ss:String = lang.ToLower()+text.ToLower()
		Local retStr:String = text
		If Self.strMap.Contains(ss)
			retStr = Self.strMap.Get(ss)
		Else
			ss = defaultLang.ToLower()+text.ToLower()
			If Self.strMap.Contains(ss)
				retStr = Self.strMap.Get(ss)
			Endif
		Endif
		Return retStr
	End
	'------------------------------------------
	Method New()
		Self.strMap = New StringMap<String>
	End
'#DOCON#
	'------------------------------------------
#Rem
'summery:This method clears all the mapping data.
#End
	Method Clear:Void()
		Self.strMap.Clear()
	End
	'------------------------------------------
'summery:This method returns the default language.
'seeAlso:SetDefaultLanguage
	Method GetDefaultLanguage:String()
		Return Self.defaultLang
	End
	'------------------------------------------
#Rem
'summery:This method returns the translated string.
'If no langStr is given, it will use the default language.
#End
'seeAlso:LoadFromString,SetDefaultLanguage
	Method GetString:String(text:String, langStr:String="")
		Local searchLang:String
		Local retStr:String
		If langStr="" Then 
			searchLang = Self.defaultLang
		Else
			searchLang = langStr
		Endif
		retStr = Self._FindLocalStr(text,searchLang)
		Return retStr
	End
	'------------------------------------------
#Rem
'summery:This method loads the localization class via a string
'The format of the string has to be (key%;%LanguageShortCut1%:%Translation1%;%...):
'Play%;%DE%:%Spielen
'Options%;%DE%:%Optionen
'Help%;%DE%:%Hilfe
'MultiLine%;%DE%:%Dieser Text%LF%erscheint in 2 Zeilen
#End
'seeAlso:GetString,SetDefaultLanguage
	Method LoadFromString:Void(locStr:String)
		'Local lines := locStr.Split(String.FromChar(10))
		Local lines := locStr.Split("~n")
		Local ctLen:Int
		For Local line:= Eachin lines
			If line = "" Then Continue
			'Local ct$[] = line.Split(";")
			Local ct$[] = line.Split("%;%")
			
			Local keyStr:String = ct[0].ToLower()
			ctLen = ct.Length()
			For Local i:Int = 2 To ctLen
				'Local valStr$[] = ct[i-1].Split(":")
				Local valStr$[] = ct[i-1].Split("%:%")
				Local lang:String = valStr[0].ToLower()
				Local value:String = valStr[1]
				value = value.Replace("%LF%","~n")
				Self.strMap.Set(lang+keyStr,value)
			Next 
		Next
	End
	'------------------------------------------
'summery:This method sets the default language.
'seeAlso:GetString,GetDefaultLanguage
	Method SetDefaultLanguage:Void(defLang:String ="EN")
#If CONFIG="debug"
		If defLang.Length()=0 Then Error ("~n~nError in file cftLocalzation.monkey, Method ftLocalization.SetDefaultLanguage - Length of defLang = 0")
#End
		Self.defaultLang = defLang
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