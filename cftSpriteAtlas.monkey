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
#Rem
'header:The class [b]ftSpriteAtlas[/b] manages spritesheets inside the fantomEngine. It reduces the call to the device storage by imprting all relevant data into memory.
#End

Import fantomEngine
'#DOCOFF#
'***************************************
Class ftAtlasSubImage
	Field name:String
	Field img:Image
	Field tpXPos:Int = 0
	Field tpYPos:Int = 0
	Field tpWidth:Int = 0
	Field tpHeight:Int = 0
	Field isRotated:Bool = False
	Field angleOffset:Float = 0.0
End
'#DOCON#
'***************************************
Class ftSpriteAtlas
'#DOCOFF#
	Field atlas:Image = Null
	Field name:String
	Field tpStringFromFile:String
	Field tpAllStrings:String[]
	Field engine:ftEngine
	Field imgMap:StringMap<ftAtlasSubImage> = Null
	'------------------------------------------
	Method _Print:Void()
		For Local item:= Eachin Self.imgMap
			Print(item.Key() + ";" + ftAtlasSubImage(item.Value()).name)
		Next
	End
	'------------------------------------------
'changes:Fixed in v1.54 to take account of rotated images
	Method _Parse:Void()
		Local s:String	
		Local tpasLen:Int 
		tpasLen = tpAllStrings.Length()
	    For Local count:Int = 0 To (tpasLen-1)
	    	s =  String(tpAllStrings[count]).ToLower().Trim()
			If s.Contains("rotate:") Then
		    	Local si := New ftAtlasSubImage
				'** Get name
				si.name = String(tpAllStrings[count-1]).ToLower()
				
				'** Get rotation flag
				Local strRot:String = tpAllStrings[count]
				strRot = strRot.Replace("rotate:","").Trim()
				If strRot.ToLower = "true" Then 
					si.isRotated = True
					si.angleOffset = -90.0
				Endif
				
				'** Get X, Y
				Local strXY:String = tpAllStrings[count+1]
				strXY = strXY.Replace("xy:","").Trim()
				Local strXYsplit:String[] = strXY.Split(",")
				si.tpXPos = Int(strXYsplit[0])
				si.tpYPos = Int(strXYsplit[1])
				
				'** Get Width, Height
				Local strWH:String = tpAllStrings[count+2]
				strWH = strWH.Replace("size:","").Trim()
				Local strWHsplit:String[] = strWH.Split(",")
				si.tpWidth = Int(strWHsplit[0])
				si.tpHeight = Int(strWHsplit[1])
				
				'** Grab the sub image
				If strRot.ToLower = "true" Then
					si.img = Self.atlas.GrabImage( si.tpXPos,si.tpYPos,si.tpHeight,si.tpWidth,1,Image.MidHandle )
				Else
					si.img = Self.atlas.GrabImage( si.tpXPos,si.tpYPos,si.tpWidth,si.tpHeight,1,Image.MidHandle )
				Endif
				si.img.SetHandle(si.img.Width()/2, si.img.Height()/2)
				'** Add subimage to the image map
				Self.imgMap.Add(si.name, si)
			Endif
		Next
	End
'#DOCON#
	'------------------------------------------
'summery:Returns the angle offset of an image.
	Method GetAngleOffset:Float(imageName:String)
		Local si := Self.imgMap.Get(imageName.ToLower())
		If si <> Null Then
			Return si.angleOffset
		Endif
		Return 0.0
	End
	'------------------------------------------
'summery:Returns the height of an image.
	Method GetHeight:Int(imageName:String)
		Local si := Self.imgMap.Get(imageName.ToLower())
		If si <> Null Then
			Return si.tpHeight
		Endif
		Return 0
	End
	'------------------------------------------
'summery:Returns the image with the given name.
	Method GetImage:Image(imageName:String)
		Local img:Image = Null
		Local si := Self.imgMap.Get(imageName.ToLower())
		If si <> Null Then
			img = si.img
		Endif
		Return img
	End
	'------------------------------------------
'changes:New in v1.55
'summery:Returns the height of the subimage with the given name.
	Method GetImageHeight:Float(imageName:String)
		Local retVal:Float = 0.0
		Local si := Self.imgMap.Get(imageName.ToLower())
		If si <> Null Then
			retVal = si.tpHeight
		Endif
		Return retVal
	End
	'------------------------------------------
'changes:New in v1.55
'summery:Returns the width of the subimage with the given name.
	Method GetImageWidth:Float(imageName:String)
		Local retVal:Float = 0.0
		Local si := Self.imgMap.Get(imageName.ToLower())
		If si <> Null Then
			retVal = si.tpWidth
		Endif
		Return retVal
	End
	'------------------------------------------
'summery:Returns the number of images in the sprite atlas.
	Method GetImageCount:Int()
		Return Self.imgMap.Count()
	End
	'------------------------------------------
'summery:Returns TRUE if the image with the given name is rotated inside the sprite atlas.
	Method GetRotated:Bool(imageName:String)
		Local si := Self.imgMap.Get(imageName.ToLower())
		If si <> Null Then
			Return si.isRotated
		Endif
		Return False
	End
	'------------------------------------------
'summery:Returns the width of an image.
	Method GetWidth:Int(imageName:String)
		Local si := Self.imgMap.Get(imageName.ToLower())
		If si <> Null Then
			Return si.tpWidth
		Endif
		Return 0
	End
	'------------------------------------------
'changes:Fixed in version 1.54 to support LINUX lines delimiters (13,10)
'summery:Loads a sprite atlas from the given image and data file name.
	Method Load:Void(imgName:String, dataName:String)
		tpStringFromFile = LoadString(dataName)

		If tpStringFromFile.Length() > 0 Then
			'tpAllStrings = tpStringFromFile.Split(String.FromChar(10))
			tpAllStrings = tpStringFromFile.Split(String.FromChar(13)+String.FromChar(10))
			If tpAllStrings.Length() < 2 then
				tpAllStrings = tpStringFromFile.Split(String.FromChar(10))
			Endif
			atlas = LoadImage(imgName)
			name = dataName
			imgMap = New StringMap<ftAtlasSubImage>
			Self._Parse()
		Endif
	End
	'------------------------------------------
'summery:Remove a sprite atlas. Set discard to TRUE if you want the corresponding images to be discarded.
	Method Remove:Void(discard:Bool = False)
		If discard = True Then Self.atlas.Discard()
		Self.atlas = Null
		Self.engine = Null
		Self.atlas = Null
		For Local item:= Eachin Self.imgMap
			If discard = True Then 
				ftAtlasSubImage(item.Value()).img.Discard()
			Else
				ftAtlasSubImage(item.Value()).img = Null
			Endif
		Next
		Self.imgMap.Clear()
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