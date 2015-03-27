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

'header:The module cftImageMng contains several classes to manage loaded images inside your game.

Import fantomEngine

'***************************************
'summery:The ftImage class contains a mojo image and some information about.
Class ftImage
'#DOCOFF#
	Field img:Image= Null
	Field atlas:ftImage = Null
	Field flags:Int = Image.DefaultFlags
	Field path:String = ""
	Field imageNode:list.Node<ftImage> = Null  
	Field frameWidth:Int = -1
	Field frameHeight:Int = -1
	Field frameCount:Int = -1 
	Field frameStartX:Int = -1
	Field frameStartY:Int = -1
	Field isGrabed:Bool = False
	Field isAtlas:Bool = False
	Field engine:ftEngine
'#DOCON#
	'------------------------------------------
'summery:Returns the frame count of a ftImage.
	Method GetFrameCount:Int()
		Return Self.frameCount
	End
	'------------------------------------------
'summery:Returns the frame height of a ftImage.
	Method GetFrameHeight:Int()
		Return Self.frameHeight
	End
	'------------------------------------------
'summery:Returns the frame width of a ftImage.
	Method GetFrameWidth:Int()
		Return Self.frameWidth
	End
	'------------------------------------------
	Method GetImage:Image()
'summery:Returns the image of a ftImage.
		Return Self.img
	End
	'------------------------------------------
'summery:Returns the path (filename) of a ftImage.
	Method GetPath:String()
		Return Self.path
	End
	'------------------------------------------
'summery:Reloads an image.
	Method ReLoad:Void()
		If path.Length() > 1 Or Self.isGrabed = True Then
			If Self.isGrabed = True Or Self.path.Length()> 1 then
				Self.img.Discard()
				If Self.isGrabed = True Then
					Self.img = atlas.img.GrabImage( frameStartX,frameStartY,frameWidth,frameHeight,frameCount,flags )
				Else
					If frameCount = 1 Then
						Self.img = mojo.LoadImage(path, frameCount, flags)
					Else
						Self.img = mojo.LoadImage(path, frameWidth, frameHeight, frameCount, flags)
					Endif
				Endif
				If img <> Null Then
					If img.HandleX = 0.5 And img.HandleY = 0.5
						img.SetHandle(img.Width()/2, img.Height()/2)
					Endif
				Endif
			Endif
		Endif
	End
	'------------------------------------------
'summery:Removes an ftImage.
	Method Remove:Void(discard:Bool = False)
		If discard = True Then Self.img.Discard()
		Self.img = Null
		Self.engine = Null
		Self.imageNode.Remove()
	End
	'------------------------------------------
'changes:New in version 1.54.
'summery:Sets the path (filename) of a ftImage.
	Method SetPath:String(filePath:String)
		Self.path = filePath
	End
End

'***************************************
'summery:The ftImageManager class handles all images for fantomEngine.
Class ftImageManager
'#DOCOFF#
	Field imageList := New List<ftImage>
	Field engine:ftEngine
'#DOCON#	
	'-----------------------------------------------------------------------------
'summery:Creates an ftImage by grabbing it from a ftImage atlas.
	Method GrabImage:ftImage(atlas:ftImage, frameStartX:Int,frameStartY:Int,frameWidth:Int,frameHeight:Int,frameCount:Int, flags:Int=Image.DefaultFlags)
		Local tmpImg:Image = Null
		Local newImage:ftImage = Null
		
		If newImage = Null Then 
			newImage = New ftImage
			newImage.engine = Self.engine
			newImage.atlas = atlas
			newImage.flags = flags
			newImage.frameCount = frameCount
			newImage.frameHeight = frameHeight
			newImage.frameWidth = frameWidth
			newImage.frameStartX = frameStartX
			newImage.frameStartY = frameStartY
			newImage.isGrabed = True
			
			' Mark the atlas is being one
			atlas.isAtlas = True
			tmpImg = atlas.img.GrabImage( frameStartX,frameStartY,frameWidth,frameHeight,frameCount,flags )
			
			If tmpImg <> Null Then
				If tmpImg.HandleX = 0.5 And tmpImg.HandleY = 0.5
					tmpImg.SetHandle(tmpImg.Width()/2, tmpImg.Height()/2)
				Endif
			Endif
			
#If CONFIG="debug"
			If tmpImg = Null Then Error ("~n~nError in file cftImageMng.monkey, Method ftImageManager.GrabImage~n~nCould not grab image from atlas~n~n")
#End
			newImage.img = tmpImg
			newImage.imageNode = Self.imageList.AddLast(newImage)
		Endif

		Return newImage
	End	
	
	'-----------------------------------------------------------------------------
'summery:Creates an ftImage by grabbing it from a Image atlas.
	Method GrabImage:ftImage(atlas:Image, frameStartX:Int,frameStartY:Int,frameWidth:Int,frameHeight:Int,frameCount:Int, flags:Int=Image.DefaultFlags)
		Local tmpImg:Image = Null
		Local newImage:ftImage = Null
		
		If newImage = Null Then 
			newImage = New ftImage
			newImage.engine = Self.engine
			'newImage.atlas = atlas
			newImage.flags = flags
			newImage.frameCount = frameCount
			newImage.frameHeight = frameHeight
			newImage.frameWidth = frameWidth
			newImage.frameStartX = frameStartX
			newImage.frameStartY = frameStartY
			newImage.isGrabed = True
			
			' Mark the atlas is being one
			For Local tmpImgNode := Eachin Self.imageList
				If tmpImgNode.img = atlas Then 
					tmpImgNode.isAtlas = True
					newImage.atlas = tmpImgNode
					Exit
				Endif
			Next
			tmpImg = atlas.GrabImage( frameStartX,frameStartY,frameWidth,frameHeight,frameCount,flags )
			
			If tmpImg <> Null Then
				If tmpImg.HandleX = 0.5 And tmpImg.HandleY = 0.5
					tmpImg.SetHandle(tmpImg.Width()/2, tmpImg.Height()/2)
				Endif
			Endif

#If CONFIG="debug"
			If tmpImg = Null Then Error ("~n~nError in file cftImageMng.monkey, Method ftImageManager.GrabImage~n~nCould not grab image from atlas~n~n")
#End
			newImage.img = tmpImg
			newImage.imageNode = Self.imageList.AddLast(newImage)
		Endif

		Return newImage
	End	
	
	'-----------------------------------------------------------------------------
#Rem
'summery:Creates an ftImage from an image.
#End
	Method LoadImage:ftImage(image:Image)
		Local tmpImg:Image = Null
		Local newImage:ftImage = Null
		
		For Local tmpImgNode := Eachin Self.imageList
			If tmpImgNode.img = image Then 
				newImage = tmpImgNode
				Exit
			Endif
		Next
		
		If newImage = Null Then 
			newImage = New ftImage
			newImage.engine = Self.engine
			newImage.path = ""
			newImage.flags = Image.DefaultFlags
			newImage.frameCount = 1

			newImage.img = image
			newImage.imageNode = Self.imageList.AddLast(newImage)
		Endif

		If newImage.img <> Null Then
			If newImage.img.HandleX = 0.5 And newImage.img.HandleY = 0.5
				newImage.img.SetHandle(newImage.img.Width()/2, newImage.img.Height()/2)
			Endif
		Endif
		Return newImage
	End
	
	'-----------------------------------------------------------------------------
#Rem
'summery:Loads an image like mogo.LoadImage.
#End
	Method LoadImage:ftImage(path:String, frameCount:Int=1, flags:Int=Image.DefaultFlags)
		Local tmpImg:Image = Null
		Local newImage:ftImage = Null
		
		For Local tmpImgNode := Eachin Self.imageList
			If tmpImgNode.path = path Then 
				newImage = tmpImgNode
				Exit
			Endif
		Next
		
		If newImage = Null Then 
			newImage = New ftImage
			newImage.engine = Self.engine
			newImage.path = path
			newImage.flags = flags
			newImage.frameCount = frameCount

			tmpImg = mojo.LoadImage(path, frameCount, flags)
#If CONFIG="debug"
			If tmpImg = Null Then Error ("~n~nError in file cftImageMng.monkey, Method ftImageManager.LoadImage~n~nCould not load image~n~n"+path)
#End
			newImage.img = tmpImg
			newImage.imageNode = Self.imageList.AddLast(newImage)
		Endif

		If newImage.img <> Null Then
			If newImage.img.HandleX = 0.5 And newImage.img.HandleY = 0.5
				newImage.img.SetHandle(newImage.img.Width()/2, newImage.img.Height()/2)
			Endif
		Endif
		Return newImage
	End

	'-----------------------------------------------------------------------------
#Rem
'summery:Loads an image like mogo.LoadImage.
#End
	Method LoadImage:ftImage(path:String,  frameWidth:Int, frameHeight:Int, frameCount:Int, flags:Int=Image.DefaultFlags)
		Local tmpImg:Image = Null
		Local newImage:ftImage = Null
		
		For Local tmpImgNode := Eachin Self.imageList
			If tmpImgNode.path = path Then 
				newImage = tmpImgNode
				Exit
			Endif
		Next
		
		If newImage = Null Then 
			newImage = New ftImage
			newImage.engine = Self.engine
			newImage.path = path
			newImage.flags = flags
			newImage.frameCount = frameCount
			newImage.frameHeight = frameHeight
			newImage.frameWidth = frameWidth

			tmpImg = mojo.LoadImage(path, frameWidth, frameHeight, frameCount, flags)
#If CONFIG="debug"
			If tmpImg = Null Then Error ("~n~nError in file cftImageMng.monkey, Method ftImageManager.LoadImage~n~nCould not load image~n~n"+path)
#End
			newImage.img = tmpImg
			newImage.imageNode = Self.imageList.AddLast(newImage)
		Endif

		If newImage.img <> Null Then
			If newImage.img.HandleX = 0.5 And newImage.img.HandleY = 0.5
				newImage.img.SetHandle(newImage.img.Width()/2, newImage.img.Height()/2)
			Endif
		Endif

		Return newImage

	End
	'------------------------------------------
#Rem
'summery:Reload all images.
#End
	Method ReLoadAllImages:Void()
		' Reload sprite atlas
		For Local item:= Eachin Self.imageList.Backwards()
			If item.isAtlas = True Then item.ReLoad()
		Next
		' Reload grabbed images
		For Local item:= Eachin Self.imageList.Backwards()
			If item.isGrabed = True Then item.ReLoad()
		Next
		' Reload single images
		For Local item:= Eachin Self.imageList.Backwards()
			If item.isGrabed = False And item.isAtlas = False Then item.ReLoad()
		Next
	End
	'------------------------------------------
#Rem
'summery:Removes all images from the image handler.
#End
	Method RemoveAllImages:Void(discard:Bool = False)
		For Local item:= Eachin Self.imageList.Backwards()
			item.Remove(discard)
		Next
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Removes an image from the image handler by the given Image handle.
#End
	Method RemoveImage:Void(image:Image, discard:Bool = False)
		For Local item := Eachin Self.imageList.Backwards()
			If item.img = image Then
				item.Remove(discard)
				Exit
			Endif
		Next
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Removes an image from the image handler by the given filename.
#End
	Method RemoveImage:Void(filepath:String, discard:Bool = False)
		For Local item := Eachin Self.imageList.Backwards()
			If item.path = filepath Then
				item.Remove(discard)
				Exit
			Endif
		Next
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