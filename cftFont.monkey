#rem
	Title:        fantomEngine
	Description:  A 2D game framework for the Monkey programming language
	
	Author:       Michael Hartlef
	Contact:      michaelhartlef@gmail.com
	
	Website:      http://www.fantomgl.com
	
	License:      MIT
#End

Import fantomEngine


#Rem
'nav:<blockquote><nav><b>fantomEngine documentation</b> | <a href="index.html">Home</a> | <a href="classes.html">Classes</a> | <a href="3rdpartytools.html">3rd party tools</a> | <a href="examples.html">Examples</a> | <a href="changes.html">Changes</a></nav></blockquote>
#End
'header:The module cftFont hosts several classes which add bitmap font drawing to fantomEngine. Bitmap fonts are important if you need to show text information inside your game fast and easy.

'#DOCOFF#
'***************************************
Class ftChar
	Field id:Int
	Field page:Int
	Field x:Int
	Field y:Int
	Field width:Int
	Field height:Int
	Field xoff:Int
	Field yoff:Int
	Field xadv:Int
End
'#DOCON#
'***************************************
'summery:The class ftFont provides a few methods regarding the definition of a loaded font.
Class ftFont
'#DOCOFF#
	Field pages:Image[]
	Field pageCount:Int
	Field filename:String
	Field charMap:IntMap<ftChar> = New IntMap<ftChar> 
	Field lineHeight:Int
	Field drawBorder:Bool = False
	Field drawShadow:Bool = False
	Field borderMap:IntMap<ftChar> = New IntMap<ftChar> 
	Field shadowMap:IntMap<ftChar> = New IntMap<ftChar> 
	'------------------------------------------
	Method Draw:Void(t:String, xpos:Float, ypos:Float)
		Local currx:Float
		Local curry:Float
		Local c:Int=0
		Local tmpChar:ftChar

		Local len:Int = t.Length()
		currx = xpos
		curry = ypos
		If Self.drawShadow = True
			For Local i:Int = 1 To len
				c=t[i-1]
				tmpChar = Self.shadowMap.Get(c)
				If tmpChar <> Null Then
					DrawImageRect( Self.pages[tmpChar.page], currx + tmpChar.xoff, curry + tmpChar.yoff, tmpChar.x, tmpChar.y, tmpChar.width, tmpChar.height)
					currx += tmpChar.xadv
				Endif
			Next
		Endif

		currx = xpos
		curry = ypos
		If Self.drawBorder = True
			For Local i:Int = 1 To len
				c=t[i-1]
				tmpChar = Self.borderMap.Get(c)
				If tmpChar <> Null Then
					DrawImageRect( Self.pages[tmpChar.page], currx + tmpChar.xoff, curry + tmpChar.yoff, tmpChar.x, tmpChar.y, tmpChar.width, tmpChar.height)
					currx += tmpChar.xadv
				Endif
			Next
		Endif

		currx = xpos
		curry = ypos
		For Local i:Int = 1 To len
			c=t[i-1]
			tmpChar = Self.charMap.Get(c)
			If tmpChar <> Null Then
				DrawImageRect( Self.pages[tmpChar.page], currx + tmpChar.xoff, curry + tmpChar.yoff, tmpChar.x, tmpChar.y, tmpChar.width, tmpChar.height)
				currx += tmpChar.xadv
			Endif
		Next
	End
'#DOCON#
	'------------------------------------------
'summery:Returns the maximum height of the font.
'seeAlso:Height
	Method Height:Int()
		Return lineHeight
	End
	'------------------------------------------
'summery:Returns the length in pixel of the given text string.
'seeAlso:Length
	Method Length:Int(t:String)
		Local currx:Int=0
		Local c:Int=0
		Local len:Int = t.Length()
		Local tmpChar:ftChar
		For Local i:Int = 1 To len
			c=t[i-1]
			tmpChar = Self.charMap.Get(c)
			If tmpChar <> Null Then
				currx += tmpChar.xadv
			Endif
		Next
		Return currx
	End
'#DOCOFF#
	'------------------------------------------
	Method LoadFMPacked(info:String, url:String)
		Local pageNum:Int = 0
		'Local info:String = app.LoadString(url)
	
		Local header:String = info[.. info.Find(",")]
		
		Local separator:String
		Select header
			Case "P1"
				separator = "."
			Case "P1.01"
				separator = "_P_"
		End Select
		info = info[info.Find(",")+1..]

		Local maxPacked:Int = 0
		Local maxChar:Int = 0

		Local prefixName:String = url
		If prefixName.ToLower().EndsWith(".txt") Then prefixName = prefixName[..-4]

		Local charList:String[] = info.Split(";")
		
		For Local chr:String = Eachin charList

			Local chrdata:String[] = chr.Split(",")
			If chrdata.Length() <2 Then Exit 

			Local tmpChar:ftChar = New ftChar 

			Local charIndex:Int = Int(chrdata[0])
			
			Local packedFontIndex:Int = Int(chrdata[2])
			If packedFontIndex > Self.pageCount
				Self.pageCount = packedFontIndex
			Endif

			'char.packedPosition.x = Int(chrdata[3])
			'char.packedPosition.y = Int(chrdata[4])
			'char.packedSize.x = Int(chrdata[5])
			'char.packedSize.y = Int(chrdata[6])
			'char.drawingMetrics.drawingOffset.x = Int(chrdata[8])
			'char.drawingMetrics.drawingOffset.y = Int(chrdata[9])
			'char.drawingMetrics.drawingSize.x = Int(chrdata[10])
			'char.drawingMetrics.drawingSize.y = Int(chrdata[11])
			'char.drawingMetrics.drawingWidth = Int(chrdata[12])
			
			
			
			tmpChar.id = charIndex
			tmpChar.x = Int(chrdata[3])	'packedPosition.x
			tmpChar.y = Int(chrdata[4]) 'packedPosition.y
			tmpChar.width = Int(chrdata[5]) 'packedSize.x
			tmpChar.height = Int(chrdata[6]) 'packedSize.y
			tmpChar.xoff = Int(chrdata[8])	'drawingMetrics.drawingOffset.x
			tmpChar.yoff = Int(chrdata[9])	'drawingMetrics.drawingOffset.y
			tmpChar.xadv = Int(chrdata[12])	'drawingMetrics.drawingWidth	
			tmpChar.page = (Int(chrdata[2])-1)	'packedFontIndex
			
			If tmpChar.height > Self.lineHeight And chrdata[1] = "F"
				Self.lineHeight = tmpChar.height
			Endif
			
			If chrdata[1]<> "F" And Int(chrdata[12])< 1 
				tmpChar.xadv = _GetxAdv(tmpChar.id)
			Endif
			
			Select chrdata[1]
				Case "B"
					Self.borderMap.Add(tmpChar.id, tmpChar)
					Self.drawBorder = True
				Case "F"
					Self.charMap.Add(tmpChar.id, tmpChar)
				Case "S"
					Self.shadowMap.Add(tmpChar.id, tmpChar)
					Self.drawShadow = True
			End Select

		Next
		Self.pages = New Image[Self.pageCount]
		For Local i:Int = 1 To Self.pageCount
			pageNum = i - 1  
			If Self.pages[pageNum] = Null Then
				Self.pages[pageNum] = LoadImage(prefixName + separator + i +  ".png")
				Self.filename = prefixName + separator + i +  ".png"
#If CONFIG="debug"
				If Self.pages[pageNum] = Null Then Error("~n~nError in file cftFont.monkey, Method ftFont.LoadFMPacked~n~nCan not load page image: "+Self.filename)
#End
			Endif
		Next

		
	End
	'------------------------------------------
	Method Load:Void(url:String)
		Local iniText:String
		Local pageNum:Int = 0
		Local idnum:Int = 0
		Local path:String =""
		Local tmpChar:ftChar = Null
		Local plLen:Int
		Local lines:String[]
		
		If url.Find("/") > -1 Then
			Local pl:= url.Split("/")
			plLen = pl.Length()
			For Local pi:= 0 To (plLen-2)
				path = path + pl[pi]+"/"
			Next
		Endif
		Local ts:String = url.ToLower()
		If (ts.Find(".txt") > 0) Then
			iniText = app.LoadString(url)
		Else
			iniText = app.LoadString(url+".txt")
		Endif
		If iniText.StartsWith("P1")
			Self.LoadFMPacked(iniText,url)
			Return
		Endif
		'Local lines := iniText.Split(String.FromChar(10))
		lines = iniText.Split(String.FromChar(13)+String.FromChar(10))
		If lines.Length() < 2 then
			lines = iniText.Split(String.FromChar(10))
		Endif

		For Local line := Eachin lines
		
			line = line.Trim()
			If line.StartsWith("info") Or line = "" Then Continue
			If line.StartsWith("padding") Then Continue
			If line.StartsWith("common") Then 
				Local commondata:= line.Split(String.FromChar(32)) 
				For Local common:= Eachin commondata
					' Maximum Line height
					If common.StartsWith("lineHeight=") Then
						Local lnh$[] = common.Split("=")
						lnh[1] = lnh[1].Trim()
						Self.lineHeight = Int(lnh[1])
					Endif
					' Number of bitmap font images
					If common.StartsWith("pages=") Then
						Local lnh$[] = common.Split("=")
						lnh[1] = lnh[1].Trim()
						Self.pageCount = Int(lnh[1])
						Self.pages = New Image[Self.pageCount]
					Endif
				Next
			Endif
			
			' Loading the bitmap font images
			If line.StartsWith("page") Then
				Local pagedata := line.Split(String.FromChar(32)) 
				For Local data := Eachin pagedata
					If data.StartsWith("file=") Then
						Local fn$[] = data.Split("=")
						fn[1] = fn[1].Trim()
						Self.filename = fn[1]
						If filename[0] = 34 Then
							Self.filename = filename[1..(filename.Length()-1)]
						Endif
						Self.filename = path+filename.Trim()

						Self.pages[pageNum] = LoadImage(Self.filename)
#If CONFIG="debug"
						If Self.pages[pageNum] = Null Then Error("~n~nError in file cftFont.monkey, Method ftFont.Load~n~nCan not load page image: "+Self.filename)
#End
						pageNum = pageNum + 1
					Endif
				Next
			Endif
			
			If line.StartsWith("chars") Then Continue

			If line.StartsWith("char") Then
			    tmpChar = New ftChar
				Local linedata:= line.Split(String.FromChar(32))
				For Local data:= Eachin linedata
					If data.StartsWith("id=") Then
						Local idc$[] = data.Split("=")
						idc[1] = idc[1].Trim()
						tmpChar.id = Int(idc[1])
					Endif
					If data.StartsWith("x=") Then
						Local xc$[] = data.Split("=")
						xc[1] = xc[1].Trim()
						tmpChar.x = Int(xc[1])
					Endif
					If data.StartsWith("y=") Then
						Local yc$[] = data.Split("=")
						yc[1] = yc[1].Trim()
						tmpChar.y = Int(yc[1])
					Endif
					If data.StartsWith("width=") Then
						Local wc$[] = data.Split("=")
						wc[1] = wc[1].Trim()
						tmpChar.width = Int(wc[1])
					Endif
					If data.StartsWith("height=") Then
						Local hc$[] = data.Split("=")
						hc[1] = hc[1].Trim()
						tmpChar.height = Int(hc[1])
					Endif
					If data.StartsWith("xoffset=") Then
						Local xoc$[] = data.Split("=")
						xoc[1] = xoc[1].Trim()
						tmpChar.xoff = Int(xoc[1])
					Endif
					If data.StartsWith("yoffset=") Then
						Local yoc$[] = data.Split("=")
						yoc[1] = yoc[1].Trim()
						tmpChar.yoff = Int(yoc[1])
					Endif
					If data.StartsWith("xadvance=") Then
						Local advc$[] = data.Split("=")
						advc[1] = advc[1].Trim()
						tmpChar.xadv = Int(advc[1])
					Endif
					If data.StartsWith("page=") Then
						Local advc$[] = data.Split("=")
						advc[1] = advc[1].Trim()
						tmpChar.page = Int(advc[1])
					Endif
				Next
				Self.charMap.Add(tmpChar.id, tmpChar)
			Endif
			Continue
		Next
	End
	'-----------------------------
	Method _GetxAdv:Int(id:Int)
		Local tmpChar:ftChar = Self.charMap.Get(id)
		Return tmpChar.xadv
	End
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
