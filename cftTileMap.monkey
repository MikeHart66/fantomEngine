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

'header:The cftTileMap file provides the ftMapObj class that holds datas from map objects. Also it provides the ftTileMap class which stores the tilemap itself.


Import fantomEngine

'#DOCOFF#
'***************************************
Class ftMapTile
	Field tileID:Int
	Field tileSetIndex:Int = 0
	Field column:Int
	Field row:Int
	Field srcX:Int
	Field srcY:Int
	Field sizeX:Int
	Field sizeY:Int
	Field xOff:Float
	Field yOff:Float
	Field tileType:Int = 0
End

'#DOCON#
'***************************************
#Rem
'summery:The ftMapObj class stores and deals with map objects provided by a Tiled compatible map.
The content of each object is only defined by the content of the map. So for an example, the object type
can be set by the map creator and you have to make sure that your app acts accordingly.
#End
Class ftMapObj
'#DOCOFF#
	Field layerName:String
	Field name:String
	Field type:String
	
	Field x:Float
	Field y:Float
	Field width:Float
	Field height:Float
	Field isVisible:Bool
	Field alpha:Float
	Field polyline:Float[]
	Field polygon:Float[]
'#DOCON#
	Field properties:StringMap<String> = Null
	'-----------------------------------------------------------------------------
'summery:Get the alpha value of a map object.
	Method GetAlpha:Float()
		Return Self.alpha
	End 
	'-----------------------------------------------------------------------------
'summery:Get the height of a map object.
	Method GetHeight:Float()
		Return Self.height
	End 
	'-----------------------------------------------------------------------------
'summery:Returns the name of the map layer, NOT the ftLayer.
	Method GetLayerName:String ()
		Return Self.layerName
	End	
	'-----------------------------------------------------------------------------
'summery:Returns the name of map object.
	Method GetName:String ()
		Return Self.name
	End	
	'-----------------------------------------------------------------------------
'summery:Returns the polygon of a map object.
	Method GetPolygon:Float[]()
		Return Self.polygon		
	End
	'-----------------------------------------------------------------------------
'summery:Returns the polyline of a map object.
	Method GetPolyLine:Float[]()
		Return Self.polyline		
	End
	'-----------------------------------------------------------------------------
'summery:Returns the objects X and Y position in a 2D Float array. This is NOT the position of the ftObject.
	Method GetPos:Float[]()
		Local p:Float[2]
		p[0] = Self.x
	    p[1] = Self.y
		Return p		
	End
	'-----------------------------------------------------------------------------
'summery:Get the X position of a map object. This is NOT the position of the ftObject.
	Method GetPosX:Float()
		Return Self.x
	End 
	'-----------------------------------------------------------------------------
'summery:Get the Y position. This is NOT the position of the ftObject.
	Method GetPosY:Float()
		Return Self.y
	End 
	'-----------------------------------------------------------------------------
'summery:Get the value of a specific property of a map object.
	Method GetProperty:String(key:String)
		Return Self.properties.Get(key)
	End 
	'-----------------------------------------------------------------------------
'summery:Get number of properties of a map object.
	Method GetPropertyCount:Int()
		Return Self.properties.Count()
	End 
	'-----------------------------------------------------------------------------
'summery:Returns the type of map object.
	Method GetType:String ()
		Return Self.type
	End	
	'-----------------------------------------------------------------------------
'summery:Get the visible flag of a map object.
	Method GetVisible:Bool()
		Return Self.isVisible
	End 
	'-----------------------------------------------------------------------------
'summery:Get the width of a map object.
	Method GetWidth:Float()
		Return Self.width
	End 
End

'***************************************
#Rem
'summery:The ftTileSet class stores tileSet information.
#End
Class ftTileSet
'#DOCOFF#
	Field firstGID:Int = 0
	Field lastGID:Int = 0
	Field imageName:String = ""
	Field imageheight:Int = 0
	Field imagewidth:Int = 0
	Field margin:Int = 0
	Field name:String = ""
	Field spacing:Int = 0
	Field tileheight:Int = 0
	Field tilewidth:Int = 0
	
End

'***************************************
#Rem
'summery:The ftTileMap class stores the tile map itself.
#End
Class ftTileMap
'#DOCOFF#
	Field tiles:ftMapTile[]
	Field tileSets:ftTileSet[1]
	Field tileSetCount:Int = 0
	Field tileCount:Int = 0
	Field tileCountX:Int = 0
	Field tileCountY:Int = 0
	Field tileSizeX:Int = 0
	Field tileSizeY:Int = 0
	Field tileModSX:Float = 0.0
	Field tileModSY:Float = 0.0
	Field tileSpacing:Int = 0
	Field mapObjList := New List<ftMapObj>
	Field obj:ftObject = Null
	'-----------------------------------------------------------------------------
'#DOCON#
#Rem
'summery:Returns the tile index at the given canvas coordinates, starting from zero.
#End
'seeAlso:SetTileID
	Method GetTileAt:Int(xp:Int,yp:Int)
		Local left2:Float, right2:Float, top2:Float, bottom2:Float
		Local tlW:Float, tlH:Float, tlxPos:Float, tlyPos:Float
		Local ytX:Int, ytY:Int, tilePos:Int, tileIDx:Int
		
		Local _cw:Float = obj.engine.GetCanvasWidth()
		Local _ch:Float = obj.engine.GetCanvasHeight()
		
		Local xoff:Float = obj.layer.xPos-obj.engine.camX
		Local yoff:Float = obj.layer.yPos-obj.engine.camY
		
		tlW = Self.tileSizeX * obj.scaleX
		tlH = Self.tileSizeY * obj.scaleY
		Local tlW2:Float = tlW/2.0
		Local tlH2:Float = tlH/2.0
		
		'Determine the first and last xCoordinate
		Local xFirst:Int = 1
		Local xLast:Int = Self.tileCountX
		If Self.tiles[0].tileType = 0
			For ytX = 1 To Self.tileCountX
				tlxPos = xoff+obj.xPos+Self.tiles[ytX-1].xOff * obj.scaleX
				If (tlxPos+tlW2)>=0 And (tlxPos-tlW2)<=_cw Then 
					xFirst = ytX
					Exit
				Endif
			Next
			
			For ytX = (xFirst+1) To Self.tileCountX
				tlxPos = xoff+obj.xPos+Self.tiles[ytX-1].xOff * obj.scaleX
				If (tlxPos+tlW2)<0 Or (tlxPos-tlW2)>_cw Then 
					xLast = ytX-1
					Exit
				Endif
			Next
		Endif
		'Determine the first and last yCoordinate
		Local yFirst:Int = 1
		Local yLast:Int = Self.tileCountY
		If Self.tiles[0].tileType = 0
			For ytY = 1 To Self.tileCountY
				tilePos = (ytY-1)*Self.tileCountX
				tlyPos = yoff+obj.yPos+Self.tiles[tilePos].yOff * obj.scaleY
				If (tlyPos+tlH2)>=0 And (tlyPos-tlH2)<=_ch Then 
					yFirst = ytY
					Exit
				Endif
			Next
			
			For ytY = (yFirst+1) To Self.tileCountY
				tilePos = (ytY-1)*Self.tileCountX
				tlyPos = yoff+obj.yPos+Self.tiles[tilePos].yOff * obj.scaleY
				If (tlyPos+tlH2)<0 Or (tlyPos-tlH2)>_ch Then 
					yLast = ytY-1
					Exit
				Endif
			Next
		Endif
		For ytY = yFirst To yLast
			For ytX = xFirst To xLast							
				tilePos = (ytX-1)+(ytY-1)*Self.tileCountX
				tileIDx = Self.tiles[tilePos].tileID

				'If tileIDx <> - 1 Then
					tlxPos = obj.xPos + Self.tiles[tilePos].xOff * obj.scaleX
					tlyPos = obj.yPos + Self.tiles[tilePos].yOff * obj.scaleY
					left2   = tlxPos - (tlW)/2.0
					right2  = left2 + tlW
					top2    = tlyPos - (tlH)/2.0
					bottom2 = top2 + tlH
					If (yp < top2) Then Continue
					If (yp > bottom2) Then Continue
					If (xp < left2) Then Continue
					If (xp > right2) Then Continue
					Return tilePos  
				'Endif
			Next
		Next	
		Return -1
	End
'#DOCOFF#
'bitofgold changes: 
'-----------------------------------------------------------------------------
'summary:Returns the tile index at the given canvas coordinates, starting from zero.
'even higher performance, only divisions

	Method GetTileAt_NEW:Int(xp:Int,yp:Int)
		Local pos:Float[2]
		pos = _GetTileCoordinates(xp,yp)
		Local x:Int = Floor(pos[0])
		Local y:Int = Floor(pos[1])
		If (x<0) Then Return -1
		If (y<0) Then Return -1
		If (x>=Self.tileCountX) Then Return -1
		If (y>=Self.tileCountY) Then Return -1
		Return(x+y*Self.tileCountX)
	End
'#DOCON#
	'-----------------------------------------------------------------------------
'summery:Returns the total number of tiles of a tilemap. 
	Method GetTileCount:Int()
		Return Self.tileCount
	End
	'-----------------------------------------------------------------------------
'summery:Returns the number of tiles in the X direction. 
	Method GetTileCountX:Int()
		Return Self.tileCountX
	End
	'-----------------------------------------------------------------------------
'summery:Returns the number of tiles in the Y direction. 
	Method GetTileCountY:Int()
		Return Self.tileCountY
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Returns the height of a tile with the given index. Index starts at 0. 
#End
'seeAlso:GetTileWidth
	Method GetTileHeight:Int(index:Int)
		Return Self.tiles[index].sizeY * obj.scaleY
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Returns the ID of the tiles texture map, at the given index, starting from zero. 
It returns -1 if there is no tile.
#End
'seeAlso:SetTileID
	Method GetTileID:Int(index:Int)
		Return Self.tiles[index].tileID
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Returns the ID of the tiles texture map, at the given map row and column, starting from zero. 
It returns -1 if there is no tile.
#End
'seeAlso:SetTileID
	Method GetTileID:Int(column:Int, row:Int)
		Local pos:Int = column+row*Self.tileCountX
		If pos < 0 Then 
			pos = 0
		Elseif pos > (Self.tileCount-1) Then
			pos = Self.tileCount - 1
		Endif
		Return Self.tiles[pos].tileID
	End
	'-----------------------------------------------------------------------------
#Rem
'summery:Returns the ID of the tiles texture, at the given canvas coordinates, starting from zero.
It returns -1 if there is no tile.
#End
'seeAlso:SetTileIDAt
	Method GetTileIDAt:Int(xp:Int,yp:Int)
		Local left2:Float, right2:Float, top2:Float, bottom2:Float
		Local tlW:Float, tlH:Float, tlxPos:Float, tlyPos:Float
		Local ytX:Int, ytY:Int, tilePos:Int, tileIDx:Int
		
		Local _cw:Float = obj.engine.GetCanvasWidth()
		Local _ch:Float = obj.engine.GetCanvasHeight()
		
		Local xoff:Float = obj.layer.xPos-obj.engine.camX
		Local yoff:Float = obj.layer.yPos-obj.engine.camY
		'tempScaleX = tempScaleX + Self.tileModSX
		'tempScaleY = tempScaleY + Self.tileModSY
		
		tlW = Self.tileSizeX * obj.scaleX
		tlH = Self.tileSizeY * obj.scaleY
		Local tlW2:Float = tlW/2.0
		Local tlH2:Float = tlH/2.0
		
		'Determine the first and last xCoordinate
		Local xFirst:Int = 1
		Local xLast:Int = Self.tileCountX
		If Self.tiles[0].tileType = 0
			For ytX = 1 To Self.tileCountX
				tlxPos = xoff+obj.xPos+Self.tiles[ytX-1].xOff * obj.scaleX
				If (tlxPos+tlW2)>=0 And (tlxPos-tlW2)<=_cw Then 
					xFirst = ytX
					Exit
				Endif
			Next
			
			For ytX = (xFirst+1) To Self.tileCountX
				tlxPos = xoff+obj.xPos+Self.tiles[ytX-1].xOff * obj.scaleX
				If (tlxPos+tlW2)<0 Or (tlxPos-tlW2)>_cw Then 
					xLast = ytX-1
					Exit
				Endif
			Next
		Endif
		'Determine the first and last yCoordinate
		Local yFirst:Int = 1
		Local yLast:Int = Self.tileCountY
		If Self.tiles[0].tileType = 0
			For ytY = 1 To Self.tileCountY
				tilePos = (ytY-1)*Self.tileCountX
				tlyPos = yoff+obj.yPos+Self.tiles[tilePos].yOff * obj.scaleY
				If (tlyPos+tlH2)>=0 And (tlyPos-tlH2)<=_ch Then 
					yFirst = ytY
					Exit
				Endif
			Next
			
			For ytY = (yFirst+1) To Self.tileCountY
				tilePos = (ytY-1)*Self.tileCountX
				tlyPos = yoff+obj.yPos+Self.tiles[tilePos].yOff * obj.scaleY
				If (tlyPos+tlH2)<0 Or (tlyPos-tlH2)>_ch Then 
					yLast = ytY-1
					Exit
				Endif
			Next
		endif
		For ytY = yFirst To yLast
			For ytX = xFirst To xLast							
				tilePos = (ytX-1)+(ytY-1)*Self.tileCountX
				tileIDx = Self.tiles[tilePos].tileID

				If tileIDx <> - 1 Then
					'tlxPos = xoff+xPos+Self.tileMap[tilePos].xOff * Self.scaleX
					'tlyPos = yoff+yPos+Self.tileMap[tilePos].yOff * Self.scaleY
					
					tlxPos = obj.xPos + Self.tiles[tilePos].xOff * obj.scaleX
					tlyPos = obj.yPos + Self.tiles[tilePos].yOff * obj.scaleY
					left2   = tlxPos - (tlW)/2.0
					right2  = left2 + tlW
					top2    = tlyPos - (tlH)/2.0
					bottom2 = top2 + tlH
					If (yp < top2) Then Continue
					If (yp > bottom2) Then Continue
					If (xp < left2) Then Continue
					If (xp > right2) Then Continue
					Return tileIDx  
				Endif
			Next
		Next	
		Return -1
	End

#rem
	Method GetTileIDAt_Old:Int(xp:Int, yp:Int)
	
		Local left2:Float, right2:Float, top2:Float, bottom2:Float
		Local tlW:Float, tlH:Float, tlxPos:Float, tlyPos:Float
		Local ytX:Int, ytY:Int, tilePos:Int, tileIDx:Int
		      
		      
		tlW = Self.tileSizeX * Self.scaleX
		tlH = Self.tileSizeY * Self.scaleY
		For ytY = 1 To Self.tileCountY
			For ytX = 1 To Self.tileCountX
			
				tilePos = (ytX-1)+(ytY-1)*Self.tileCountX
				tileIDx = Self.tileMap[tilePos].tileID
				If tileIDx <> - 1 Then
					tlxPos = Self.xPos + Self.tileMap[tilePos].xOff * Self.scaleX
					tlyPos = Self.yPos + Self.tileMap[tilePos].yOff * Self.scaleY
					left2   = tlxPos - (tlW)/2.0
					right2  = left2 + tlW
					top2    = tlyPos - (tlH)/2.0
					bottom2 = top2 + tlH
					If (yp < top2) Then Continue
					If (yp > bottom2) Then Continue
					If (xp < left2) Then Continue
					If (xp > right2) Then Continue
					Return tileIDx  
				Endif
			Next
		Next
		
		Return -1
		
	End
#End	
'#DOCOFF#
'bitofgold changes: 
'-----------------------------------------------------------------------------
'summary: Returns the ID of the tiles texture, at the given canvas coordinates, starting from zero.
'It returns -1 If there is no tile.
'even higher performance, only divisions

	Method GetTileIDAt_NEW:Int(xp:Int,yp:Int)
		Local tilePos:Int = GetTileAt(xp,yp)
		If tilePos > 0 Then
			Return Self.tiles[tilePos].tileID
		Else
			Return -1
		Endif
	End
'#DOCON#	
	'-----------------------------------------------------------------------------
'summery:Returns the X position of a tile with the given index. Index starts with 0. 
'seeAlso:GetTilePosY
	Method GetTilePosX:Float(index:Int)
		Return obj.xPos + Self.tiles[index].xOff * obj.scaleX
	End
	'-----------------------------------------------------------------------------
'summery:Returns the Y position of a tile with the given index. Index starts with 0. 
'seeAlso:GetTimePoX
	Method GetTilePosY:Float(index:Int)
		Return obj.yPos + Self.tiles[index].yOff * obj.scaleY
	End
	'-----------------------------------------------------------------------------
'summery:Returns the width of a tile with the given index. Index starts at 0. 
'seeAlso:GetTileHeight
	Method GetTileWidth:Int(index:Int)
		Return Self.tiles[index].sizeY * obj.scaleY
	End
	'-----------------------------------------------------------------------------
'summery:Returns the tileSetIndex of a given tile ID
	Method GetTileSetIndex:Int(tileID:Int)
		Local retVal:Int = -1
		For Local ind:Int = 1 To Self.tileSets.Length()
			If tileID >= Self.tileSets[ind-1].firstGID And tileID <= Self.tileSets[ind-1].lastGID
				retVal = ind-1
			Endif
		Next
		Return retVal
	End
	'-----------------------------------------------------------------------------
'summery:Removes the tilemap from the corresponding ftObject.
	Method Remove:Void()
		'tiles.Resize(0)
		tiles = tiles.Resize(0)
		tileCount= 0
		tileCountX = 0
		tileCountY = 0
		tileSizeX = 0
		tileSizeY = 0
		tileModSX = 0.0
		tileModSY = 0.0
		tileSpacing = 0
		mapObjList.Clear()
		Self.obj.tileMap = Null
	End
	'-----------------------------------------------------------------------------
'summery:Sets the ID of the tiles texture map, at the given map row and column, starting from zero.
'seeAlso:GetTileID
	Method SetTileID:Void(column:Int, row:Int, id:Int)
		Local pos:Int = column+row*Self.tileCountX
		If pos < 0 Then 
			pos = 0
		Elseif pos > (Self.tileCount-1) Then
			pos = Self.tileCount - 1
		Endif
		Self.tiles[pos].tileID = id
		If id > -1
			Self.tiles[pos].tileSetIndex = Self.GetTileSetIndex(id+1)
			Self.tiles[pos].sizeX = Self.tileSets[Self.tiles[pos].tileSetIndex].tilewidth 
			Self.tiles[pos].sizeY = Self.tileSets[Self.tiles[pos].tileSetIndex].tileheight 
		Endif
	End
'#DOCOFF#
'bitofgold changed function
'-----------------------------------------------------------------------------
'Summary:Sets the ID of the tiles texture, at the given canvas coordinates, starting from zero.
	Method SetTileIDAt_NEW:Void(xp:Int,yp:Int, id:Int=-1)
		Local tilePos:Int = GetTileAt(xp,yp)
		If tilePos > 0 Then
			Self.tiles[tilePos].tileID = id
			If id > -1
				Self.tiles[tilePos].tileSetIndex = Self.GetTileSetIndex(id+1)
				Self.tiles[tilePos].sizeX = Self.tileSets[Self.tiles[tilePos].tileSetIndex].tilewidth 
				Self.tiles[tilePos].sizeY = Self.tileSets[Self.tiles[tilePos].tileSetIndex].tileheight 
			Endif
		Endif
	End
'#DOCON#
	'-----------------------------------------------------------------------------
'summery:Sets the tile scale modification factors which are used during rendering.
	Method SetTileSModXY:Void(xMod:Float, yMod:Float)
		Self.tileModSX = xMod
		Self.tileModSY = yMod
	End
'#DOCOFF#

'start of bitofgold changes:
'bitofgold new function: 
'-----------------------------------------------------------------------------
'summary: converts world coordinates to tile coordinates. Use Floor() to get integer tile position values from zero! (eg. returns 0.5 at half of first tile)
	Method _GetTileCoordinates:Float[](xp:Int,yp:Int)
		Local tlW:Float, tlH:Float, tlxPos:Float, tlyPos:Float
		Local xoff:Float = obj.xPos+obj.layer.xPos'-Self.engine.camX
		Local yoff:Float = obj.yPos+obj.layer.yPos'-Self.engine.camY
		tlW = Self.tileSizeX * obj.scaleX
		tlH = Self.tileSizeY * obj.scaleY
		tlxPos = (xp - xoff + tlW/2.0) / tlW 
		tlyPos = (yp - yoff + tlH/2.0) / tlH 
		Local p:Float[2]
		p[0] = tlxPos
	    p[1] = tlyPos
		Return p
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