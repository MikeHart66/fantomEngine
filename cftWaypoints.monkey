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
#Rem
'header:The waypoint module lets you create paths of waypoints by hand. Then you can create a marker that you can let run along the path. Also you can connect an object to that marker. Another functionality is A* path finding.
#End

'***************************************
'summery:The ftWaypoint class defines a single waypoint in a path. 
Class ftWaypoint
'#DOCOFF#
	Field xPos:Float = 0
	Field yPos:Float = 0
	Field xDist:Float = 0
	Field yDist:Float = 0
	Field pathNode:list.Node<ftWaypoint> = Null
	Field path:ftPath = Null
'#DOCON#	
	'------------------------------------------
'summery:Returns the path index of a waypoint. Index start with 1 
	Method GetIndex:Int()
		Local ci:Int = 0
		For Local waypoint := Eachin path.wpList
			ci = ci + 1
			If waypoint = Self Then Return ci    
		Next
		Return 0
	End
	'------------------------------------------
'summery:Returns the X/Y position of a waypoint. 
	Method GetPos:Float[]()
		Local p:Float[2]
		p[0] = xPos
	    p[1] = yPos
		Return p
	End
	'------------------------------------------
'summery:Removes a waypoint from its path. 
	Method Remove:Void()
		Self.pathNode.Remove()
		Self.path = Null
	End
	'------------------------------------------
#Rem
'summery:Renders a waypoint at its current position.	
'A renderType of 0 renders a box, every other value a circle.
#End
	Method Render:Void(renderType:Int=0)
		If renderType = 0 Then
			PushMatrix
			Translate (Self.xPos, Self.yPos) 
			DrawRect -5, -5, 10, 10
			PopMatrix
		Else
			DrawCircle Self.xPos, Self.yPos, 5
		Endif
	End

	'------------------------------------------
'summery:Sets the position of a waypoint inside a path.
	Method SetPos:Void(xpos:Float, ypos:Float, relative:Bool = False)
		If relative = True Then
			self.xDist = xpos
			self.yDist = ypos
			self.xPos = self.xDist + Self.path.xPos
			self.yPos = self.yDist + Self.path.yPos
		Else
			self.xDist = xpos - Self.path.xPos
			self.yDist = ypos - Self.path.yPos
		Endif
		'Scale and rotate all waypoints of the path
		Self.path.SetScale(0.0, 0.0, True)
		Self.path.SetAngle(0.0, True)
	End
	
End

'***************************************
'summery:The ftPath class defines a path created by hand. 
Class ftPath
'#DOCOFF#
    Field wpList:= New List<ftWaypoint>
    Field markerList:= New List<ftMarker>
    Field engine:ftEngine = Null
	Field xPos:Float = 0
	Field yPos:Float = 0
    Field angle:Float = 0.0
    Field scaleX:Float = 1.0
    Field scaleY:Float = 1.0
    Field inUpdate:Bool = False
    
'#DOCON#    
	'----- Marker direction -----
	Const mdForward:Int = 1
	Const mdBackwards:Int = 2
	
	'----- Marker move mode -----
	Const mmStop:Int = 0
	Const mmBounce:Int = 1    'Goes back and forth
	Const mmWarp:Int = 2     'Once it hits the end waypoint, it starts right away at the start waypoint.
	Const mmCircle:Int = 3   'Once it hits the end waypoint, it moves towards the start waypoint.
	
	'----- Interpolation mode for moving along the path ----- 
	Const imLinear:Int=0
	Const imCatmull:Int=1
	
	
	'------------------------------------------
'summery:This method adds a new waypoint to an existing path and returns it.
	Method AddWP:ftWaypoint(xpos:Float, ypos:Float, relative:Bool = False)
		Local waypoint := New ftWaypoint
		If relative = True Then
			waypoint.xDist = xpos
			waypoint.yDist = ypos
			waypoint.xPos = waypoint.xDist + Self.xPos
			waypoint.yPos = waypoint.yDist + Self.yPos
		Else
			waypoint.xPos = xpos
			waypoint.yPos = ypos
			waypoint.xDist = xpos - Self.xPos
			waypoint.yDist = ypos - Self.yPos
		Endif
		waypoint.pathNode = Self.wpList.AddLast(waypoint)
		waypoint.path = Self
		'Scale and rotate all waypoints of the path
		Self.SetScale(0.0, 0.0, True)
		Self.SetAngle(0.0, True)
		Return waypoint
	End
	
	'-----------------------------------------------------------------------------
	Method CleanupLists:Void()
		For Local marker := Eachin Self.markerList
			If marker.isDeleted = True Then
				marker.pathNode.Remove()
				marker.path = Null
				For Local tmpObj := Eachin marker.objList
					tmpObj.markerNode.Remove() 
					tmpObj.marker = Null			
				Next
			Endif
		Next
	End
	'------------------------------------------
'summery:This method creates a new marker for an existing path.
	Method CreateMarker:ftMarker(speed:Float= 1.0, dir:Int = mdForward, mode:Int = mmStop)
		Local nc:Int = Self.wpList.Count()
#If CONFIG="debug"		
		If nc < 1 Then Error ("~n~nError in file fantomEngine.cftWaypoints, Method ftPath.CreateMarker():~n~nPath has no waypoints!")
#End
		Local marker := New ftMarker
		marker._Init(Self, speed, dir, mode)
		marker.pathNode = Self.markerList.AddLast(marker)
		marker.path = Self
		Return marker
	End
	
	'------------------------------------------
'summery:To find the closest waypoint of a path to a given position, use this method.
	Method FindClosestWP:ftWaypoint(xpos:Float, ypos:Float)
		Local cdist:Float
		Local dist:Float
		Local dX:Float
		Local dY:Float
		Local tmpWP:ftWaypoint = Null
    
		cdist = 999999.9

		For Local waypoint := Eachin wpList
			dX = xpos - waypoint.xPos
			dY = ypos - waypoint.yPos
			dist = Sqrt(dX*dX + dY*dY)
			If dist < cdist Then
				cdist = dist
				tmpWP = waypoint
			Endif    
		Next
		Return tmpWP
	End
	
	'------------------------------------------
'summery:Get a the waypoint with the given index. Index starts with 1.
	Method GetWP:ftWaypoint(index:Int)
		Local ci:Int = 0
		Local cc:Int = Self.wpList.Count()
#If CONFIG="debug"
		If index < 1 Or index > cc Then Error ("~n~nError in file fantomEngine.cftWaypoints, Method ftPath.GetWP():~n~nUsed index ("+index+") is out of bounds (1-"+cc+")")
#End
 		For Local waypoint := Eachin Self.wpList
 			ci = ci + 1
 			If ci = index Then
				Return waypoint
			Endif
		Next
		Return Null
  	End

	'------------------------------------------
'summery:Returns the waypoint count of the path.
	Method GetWPCount:Int()
    	Return Self.wpList.Count()
	End
	
	'------------------------------------------
'summery:Returns the angle of the path.
	Method GetAngle:Float()
    	Return Self.angle
	End
	
	'------------------------------------------
'summery:Returns the position of the path inside an array.
	Method GetPos:Float[]()
		Local p:Float[2]
		p[0] = Self.xPos
	    p[1] = Self.yPos
    	Return p
	End
	
	'------------------------------------------
'summery:Returns the scale factors of the path inside an array.
	Method GetScale:Float[]()
		Local s:Float[2]
		s[0] = Self.scaleX
	    s[1] = Self.scaleY
    	Return s
	End
	
	'------------------------------------------
'summery:Load a path from a string.
	Method LoadFromString:Void(ps:String)
		Local entryCount:Int = 0
		Local nx:Float = 0.0
		Local ny:Float = 0.0

		Local _angle:Float = 0.0
		Local _xp:Float = 0.0
		Local _yp:Float = 0.0

		Local _sx:Float = 0.0
		Local _sy:Float = 0.0

		Local cw:Float=0
		Local ch:Float=0
		
		Self.RemoveAllMarkers()
		Self.RemoveAllWP()
		
		Local lines := ps.Split(String.FromChar(10))
		
		For Local line:= Eachin lines
			If line = "" Then Continue
			If line.StartsWith("waypointCount=") Then
				Local ct$[] = line.Split("=")
				entryCount = Int(ct[1])
			Elseif line.StartsWith("canvasWidth=") Then
				Local ct$[] = line.Split("=")
				cw = Float(ct[1])
			Elseif line.StartsWith("canvasHeight=") Then
				Local ct$[] = line.Split("=")
				ch = Float(ct[1])
			Elseif line.StartsWith("angle=") Then
				Local ct$[] = line.Split("=")
				_angle = Float(ct[1])
			Elseif line.StartsWith("xPos=") Then
				Local ct$[] = line.Split("=")
				_xp = Float(ct[1])
			Elseif line.StartsWith("yPos=") Then
				Local ct$[] = line.Split("=")
				_yp = Float(ct[1])
			Elseif line.StartsWith("scaleX=") Then
				Local ct$[] = line.Split("=")
				_sx = Float(ct[1])
			Elseif line.StartsWith("scaleY=") Then
				Local ct$[] = line.Split("=")
				_sy = Float(ct[1])
			Elseif line.StartsWith("waypoint=") Then 
				Local ct$[] = line.Split("=")
				Local dt$[] = ct[1].Split(";")
				nx = (Float(dt[0])/cw)*engine.GetCanvasWidth()
				ny = (Float(dt[1])/ch)*engine.GetCanvasHeight()
				Self.AddWP(nx, ny) 
			Endif
		Next
		Self.SetPos( (_xp/cw) * engine.GetCanvasWidth(), (_yp/ch) * engine.GetCanvasHeight () )
		Self.SetScale(_sx, _sy)
		Self.SetAngle(_angle)
		'Return 0
	End	
	
	'------------------------------------------
'summery:Remove a path and its content.
	Method Remove:Void()
 		RemoveAllMarkers()
 		RemoveAllWP()
  	End

	'------------------------------------------
'summery:Removes all markers of the path.
	Method RemoveAllMarkers:Void()
 		For Local marker := Eachin Self.markerList.Backwards()
			If marker.isDeleted = false Then marker.Remove()
		Next
  	End

	'------------------------------------------
'summery:Removes all waypoints of the path.
	Method RemoveAllWP:Void()
 		For Local waypoint := Eachin Self.wpList.Backwards()
			waypoint.Remove()
		Next
  	End

	'------------------------------------------
'summery:Returns a waypoint with the given index. Index starts with 1.
	Method RemoveWP:Void(index:Int)
		Local ci:Int = -1
		Local cc:Int = Self.wpList.Count()
#If CONFIG="debug"
		If index < 1 Or index > cc Then Error ("~n~nError in file fantomEngine.cftWaypoints, Method ftPath.RemoveWP(index:Int):~n~nUsed index ("+index+") is out of bounds (1-"+cc+")")
#End
		Local tmpWP:ftWaypoint = Null
		
 		For Local waypoint := Eachin Self.wpList.Backwards()
 			ci = ci + 1
 			If ci = index Then
				waypoint.Remove()
				Exit
			Endif
		Next
  	End
  	
	'------------------------------------------
'changes:Fixed in version 1.55
#Rem
'summery:Render all markers of a path. You can use this for debugging.
A type value of 0 renders a square, any other value renders a circle.
#End
	Method RenderAllMarker:Void(type:Int=0)
		PushMatrix
		Translate(engine.autofitX, engine.autofitY)
		Scale(engine.scaleX, engine.scaleY)
		SetScissor( engine.autofitX, engine.autofitY, engine.canvasWidth*engine.scaleX, engine.canvasHeight*engine.scaleY )
		For Local marker := Eachin Self.markerList
			marker.Render(type)
		Next
		PopMatrix
	End
	
	'------------------------------------------
'changes:Fixed in version 1.55
#Rem
'summery:Render all waypoints of a path. You can use this for debugging.
A type value of 0 renders a square, any other value renders a circle.
#End
	Method RenderAllWP:Void(type:Int=0)
		PushMatrix
		Translate(engine.autofitX, engine.autofitY)
		Scale(engine.scaleX, engine.scaleY)
		SetScissor( engine.autofitX, engine.autofitY, engine.canvasWidth*engine.scaleX, engine.canvasHeight*engine.scaleY )
		For Local waypoint := Eachin Self.wpList
			waypoint.Render(type)
		Next
		PopMatrix
	End
	
	'------------------------------------------
'summery:Save a path to a string.
	Method SaveToString:String()
		Local ps:String
		ps = "waypointCount="+Self.wpList.Count() + String.FromChar(10)
		ps = ps + "canvasWidth=" + engine.GetCanvasWidth() + String.FromChar(10)
		ps = ps + "canvasHeight=" + engine.GetCanvasHeight() + String.FromChar(10)
		ps = ps + "angle=" + Self.angle + String.FromChar(10)
		ps = ps + "xPos=" + Self.xPos + String.FromChar(10)
		ps = ps + "yPos=" + Self.yPos + String.FromChar(10)
		ps = ps + "scaleX=" + Self.scaleX + String.FromChar(10)
		ps = ps + "scaleY=" + Self.scaleY + String.FromChar(10)
		For Local waypoint := Eachin Self.wpList
			ps = ps + "waypoint="+waypoint.xDist + ";" + waypoint.yDist + String.FromChar(10)
		Next
		Return ps
	End
	
	'------------------------------------------
'summery:Sets the angle of a path and position its waypoints regarding the angle.
	Method SetAngle:Void(a:Float, relative:Bool = False)
		Local waypointDist:Float = 0.0
		Local distX:Float = 0.0
		Local distY:Float = 0.0
		Local waypointAngle:Float = 0.0
		If relative = True Then
			Self.angle += a
		Else
			Self.angle = a
		Endif
		For Local waypoint := Eachin Self.wpList
			distX = waypoint.xDist * Self.scaleX
			distY = waypoint.yDist * Self.scaleY
			' WP distance to path center
		    waypointDist = Sqrt(distX * distX + distY * distY)
			' WP angle to path center
		    waypointAngle = ATan2(distY, distX) + 90.0
		    waypointAngle += Self.angle
			If waypointAngle < 0 Then 
				waypointAngle += 360.0
			Elseif waypointAngle > 360.0 Then 
				waypointAngle -= 360.0
			Endif
			' Calculate new position of the waypoint
			waypoint.xPos = (Sin(waypointAngle) * waypointDist) + Self.xPos
			waypoint.yPos = (-Cos(waypointAngle) * waypointDist) + Self.yPos
		Next
	End
	'------------------------------------------
'summery:Sets the position of a path and its waypoints.
	Method SetPos:Void(x:Float, y:Float, relative:Bool = False)
		If relative = True Then
			Self.xPos += x
			Self.yPos += y
		Else
			Self.xPos = x
			Self.yPos = y
		Endif
		For Local waypoint := Eachin Self.wpList
			waypoint.xPos = waypoint.xDist + Self.xPos
			waypoint.yPos = waypoint.yDist + Self.yPos
		Next
		'Scale and rotate all waypoints accordning to the scale factors and the angle of the path
		Self.SetScale(0.0, 0.0, True)
		Self.SetAngle(0.0, True)
	End
	
	'------------------------------------------
'summery:Sets the X position of a path and its waypoints.
	Method SetPosX:Void(x:Float, relative:Bool = False)
		If relative = True Then
			Self.xPos += x
		Else
			Self.xPos = x
		Endif
		For Local waypoint := Eachin Self.wpList
			waypoint.xPos = waypoint.xDist + Self.xPos
		Next
		'Scale and rotate all waypoints accordning to the scale factors and the angle of the path
		Self.SetScale(0.0, 0.0, True)
		Self.SetAngle(0.0, True)
	End
	
	'------------------------------------------
'summery:Sets the Y position of a path and its waypoints.
	Method SetPosY:Void(y:Float, relative:Bool = False)
		If relative = True Then
			Self.yPos += y
		Else
			Self.yPos = y
		Endif
		For Local waypoint := Eachin Self.wpList
			waypoint.yPos = waypoint.yDist + Self.yPos
		Next
		'Scale and rotate all waypoints accordning to the scale factors and the angle of the path
		Self.SetScale(0.0, 0.0, True)
		Self.SetAngle(0.0, True)
	End
	
	'------------------------------------------
'summery:Sets the scale of a path and position its waypoints regarding the angle.
	Method SetScale:Void(x:Float, y:Float, relative:Bool = False)
		If relative = True Then
			Self.scaleX += x
			Self.scaleY += y
		Else
			Self.scaleX = x
			Self.scaleY = y
		Endif
		For Local waypoint := Eachin Self.wpList
			waypoint.xPos = (waypoint.xDist * Self.scaleX) + Self.xPos
			waypoint.yPos = (waypoint.yDist * Self.scaleY) + Self.yPos
		Next
		'Rotate all waypoints according to the angle of the path
		Self.SetAngle(0.0, True)
	End


	'------------------------------------------
#Rem
'summery:Updates all markers of a path.
#End
	Method UpdateAllMarker:Void(speedFactor:Float = 1.0)
		Self.inUpdate = True
		For Local marker := Eachin Self.markerList
			If marker.isDeleted = false Then marker.Update(speedFactor)
		Next
		CleanupLists()
		Self.inUpdate = False
	End
End

'***************************************
'summery:The ftMarker class defines a marker that runs along a path. 
Class ftMarker
'#DOCOFF#
    Field objList:= New List<ftObject>
    'Field obj:ftObject = Null
    'Field objPathUpdAngle:Bool=True
    Field speed:Float = 1.0
    Field sensivity:Float = 0.1

    Field currDist:Float = 0.0
    Field currAngle:Float = 0.0
    
    Field currXpos:Float = 0.0
    Field currYpos:Float = 0.0

    Field prevIndex:Int = -1
    Field srcIndex:Int = -1
    Field destIndex:Int = -1
    Field nextIndex:Int = -1
 
    Field prevWP:ftWaypoint = Null
    Field srcWP:ftWaypoint = Null
    Field destWP:ftWaypoint = Null
    Field nextWP:ftWaypoint = Null

    Field destXpos:Float = 0.0
    Field destYpos:Float = 0.0
    Field sourceXpos:Float = 0.0
    Field sourceYpos:Float = 0.0

    Field diffX:Float = 0.0
    Field diffY:Float = 0.0

    Field distance:Float = 0.0

	Field pathNode:list.Node<ftMarker> = Null
	Field path:ftPath = Null

    Field direction:Int = ftPath.mdForward
    Field mode:Int = 0
    Field _final:Bool = False
    Field ipMode:Int = ftPath.imLinear
	Field cmPos:ftVec2D = Null
	Field cmP1:ftVec2D  = Null
	Field cmP2:ftVec2D  = Null
	Field cmP3:ftVec2D  = Null
	Field cmP4:ftVec2D  = Null
	
	Field isDeleted:Bool = False

	'------------------------------------------
	Method _Calc:Void()

		Self.prevWP = Self.path.GetWP(Self.prevIndex)
		Self.srcWP = Self.path.GetWP(Self.srcIndex)
		Self.destWP = Self.path.GetWP(Self.destIndex)
		Self.nextWP = Self.path.GetWP(Self.nextIndex)

		Self.diffX = Self.destWP.xPos - Self.srcWP.xPos
		Self.diffY = Self.destWP.yPos - Self.srcWP.yPos
		
		Self.currXpos = Self.srcWP.xPos
		Self.currYpos = Self.srcWP.yPos

		Self.sourceXpos = Self.srcWP.xPos
		Self.sourceYpos = Self.srcWP.yPos

		Self.destXpos = Self.destWP.xPos
		Self.destYpos = Self.destWP.yPos

		Self.distance = Sqrt(Self.diffX * Self.diffX + Self.diffY * Self.diffY)
		Self.currDist = Self.distance
		Self.currAngle = ATan2( Self.diffY, Self.diffX )+90.0

		While Self.currAngle < 0 
			Self.currAngle += 360.0
		End
		_UpdateObjects()
	End
	'------------------------------------------
	Method _OnMarkerBounce:Void()
		For Local tmpObj := Eachin Self.objList
			Self.path.engine.OnMarkerBounce(Self, tmpObj)
		Next
	End
	'------------------------------------------
	Method _OnMarkerCircle:Void()
		For Local tmpObj := Eachin Self.objList
			Self.path.engine.OnMarkerCircle(Self, tmpObj)
		Next
	end
	'------------------------------------------
	Method _OnMarkerWP:Void()
		For Local tmpObj := Eachin Self.objList
			Self.path.engine.OnMarkerWP(Self, tmpObj)
		Next
	end
	'------------------------------------------
	Method _OnMarkerStop:Void()
		For Local tmpObj := Eachin Self.objList
			Self.path.engine.OnMarkerStop(Self, tmpObj)
		Next
	End
	'------------------------------------------
	Method _OnMarkerWarp:Void()
		For Local tmpObj := Eachin Self.objList
			Self.path.engine.OnMarkerWarp(Self, tmpObj)
		Next
	End
	'------------------------------------------
	Method _GetIndex:Int(si:Int, off:Int)
		Local ret:Int
		ret = si
		Local nCount:Int = Self.path.GetWPCount()
			ret = ret + off
		If off > 0 Then
			If ret > nCount Then ret = ret - nCount
		Endif
		If off < 0 Then
			If ret < 1 Then ret = ret + nCount
		Endif

		Return ret
	End
	
	'------------------------------------------
	Method _NextWP:Void()
		Local nCount:Int = Self.path.GetWPCount()
		If Self.direction = ftPath.mdForward Then
			Select Self.mode
				Case ftPath.mmStop
					If Self.destIndex = nCount Then
						_OnMarkerStop()
						Self._final = True
					Else
						Self.srcIndex  = Self.destIndex
						Self.destIndex = Min(Self.srcIndex + 1, nCount)
						Self.nextIndex = Min(Self.destIndex + 1, nCount)
						Self.prevIndex = Max(Self.srcIndex - 1, 1)
					Endif
				Case ftPath.mmBounce
					If Self.destIndex = nCount Then
						_OnMarkerBounce()
						Self.direction = ftPath.mdBackwards
						
						Self.srcIndex  = nCount
						Self.destIndex = Max(Self.destIndex - 1, 1)
						Self.nextIndex = Max(Self.destIndex - 1, 1)
						Self.prevIndex = Self.srcIndex
					Else					
						Self.srcIndex  = Self.destIndex
						Self.destIndex = Min(Self.srcIndex + 1, nCount)
						Self.nextIndex = Min(Self.destIndex + 1, nCount)
						Self.prevIndex = Max(Self.srcIndex - 1, 1)
					Endif
					
				Case ftPath.mmWarp
					If Self.destIndex = nCount Then
						_OnMarkerWarp()
						Self.srcIndex  = 1
						Self.destIndex = Min(Self.srcIndex + 1, nCount)
						Self.nextIndex = Min(Self.destIndex + 1, nCount)
						Self.prevIndex = Self.srcIndex
					Else
						Self.srcIndex  = Self.destIndex
						Self.destIndex = Min(Self.srcIndex + 1, nCount)
						Self.nextIndex = Min(Self.destIndex + 1, nCount)
						Self.prevIndex = Max(Self.srcIndex - 1, 1)
					Endif
				Case ftPath.mmCircle
					If Self.destIndex = nCount Then
						_OnMarkerCircle()
					Endif
					Self.prevIndex = Self.srcIndex
					Self.srcIndex  = Self._GetIndex(Self.srcIndex, 1)
					Self.destIndex = Self._GetIndex(Self.srcIndex, 1)
					Self.nextIndex = Self._GetIndex(Self.destIndex, 1)
			End
		Else    'direction = Backwards
			Select Self.mode
				Case ftPath.mmStop
					If Self.destIndex = 1 Then
						_OnMarkerStop()
						Self._final = True
					Else
						Self.srcIndex  = Self.srcIndex - 1
						Self.destIndex = Max(Self.srcIndex - 1, 1)
						Self.nextIndex = Max(Self.destIndex - 1, 1)
						Self.prevIndex = Min(Self.srcIndex + 1, nCount)
					Endif
				Case ftPath.mmBounce
					If Self.destIndex = 1 Then
						_OnMarkerBounce()
						Self.direction = ftPath.mdForward
						
						Self.srcIndex  = 1
						Self.destIndex = Min(Self.srcIndex + 1, nCount)
						Self.nextIndex = Min(Self.destIndex + 1, nCount)
						Self.prevIndex = Self.srcIndex
					Else					
						Self.srcIndex  = Self.srcIndex - 1
						Self.destIndex = Max(Self.srcIndex - 1, 1)
						Self.nextIndex = Max(Self.destIndex - 1, 1)
						Self.prevIndex = Min(Self.srcIndex + 1, nCount)
					Endif
					
				Case ftPath.mmWarp
					If Self.destIndex = 1 Then
						_OnMarkerWarp()
						Self.srcIndex  = nCount
						Self.destIndex = Max(Self.srcIndex - 1, 1)
						Self.nextIndex = Max(Self.destIndex - 1, 1)
						Self.prevIndex = Self.srcIndex
					Else
						Self.srcIndex  = Self.destIndex
						Self.destIndex = Max(Self.srcIndex - 1, 1)
						Self.nextIndex = Max(Self.destIndex - 1, 1)
						Self.prevIndex = Min(Self.srcIndex + 1, nCount)
					Endif
				Case ftPath.mmCircle
					If Self.destIndex = 1 Then
						_OnMarkerCircle()
					Endif
					Self.prevIndex = Self.srcIndex
					Self.srcIndex  = Self._GetIndex(Self.srcIndex,-1)
					Self.destIndex = Self._GetIndex(Self.srcIndex,-1)
					Self.nextIndex = Self._GetIndex(Self.destIndex,-1)
			End
		Endif
		
		If Self._final <> True Then Self._Calc()
	End

	'------------------------------------------
	Method _UpdateObjects:Void(obj:ftObject = Null)
		If obj= Null Then
			For Local tmpObj := Eachin Self.objList
				If tmpObj.deleted = False Then
					tmpObj.SetPos(Self.currXpos, Self.currYpos)
					If tmpObj.objPathUpdAngle = True Then tmpObj.SetAngle(Self.currAngle)
				Endif
			Next
		Else
				If obj.deleted = False Then 
					obj.SetPos(Self.currXpos, Self.currYpos)
					If obj.objPathUpdAngle = True Then obj.SetAngle(Self.currAngle)
				Endif
		Endif
	End
	'------------------------------------------
	Method _Init:Void(path:ftPath, speed:Float = 1.0, dir:Int = ftPath.mdForward, mode:Int = ftPath.mmStop)
		Self.path = path
		Self.direction = dir
		Self.mode = mode
		Self.speed = speed
		
		Local nCount:Int = path.GetWPCount()
		
		If dir = ftPath.mdForward Then
			Self.prevIndex = 1
			Self.srcIndex = 1
			Self.destIndex = Min(2,nCount)
			Self.nextIndex = Min(3,nCount)
		Else
			Self.prevIndex = nCount
			Self.srcIndex = nCount
			Self.destIndex = Max(0,nCount-1)
			Self.nextIndex = Max(0,nCount-2)
		Endif
		Self._Calc()
		
		Self._final = False
	End
'#DOCON#

	'------------------------------------------
'summery:Connects an object to an existing marker	.
	Method ConnectObj:Void(obj:ftObject, flag:Bool = True)
		obj.markerNode = Self.objList.AddLast(obj)
		obj.marker = Self
		obj.objPathUpdAngle = flag
		_UpdateObjects(obj)
	End

	'------------------------------------------
'summery:Returns the current angle of a marker in degree.	
	Method GetCurrAngle:Float()
		Return Self.currAngle
	End

	'------------------------------------------
'summery:Returns the current destination waypoint.	
	Method GetCurrDestWP:ftWaypoint()
		Return Self.destWP
	End

	'------------------------------------------
'summery:Returns the current destination waypoint X/Y/Z position.	
	Method GetCurrDestPos:Float[]()
		Local pos:Float[2]
		pos[0] = Self.destWP.xPos
		pos[1] = Self.destWP.yPos

		Return pos
	End

	'------------------------------------------
'summery:Returns the current distance of the marker.	
	Method GetCurrDist:Float()
		Return Self.currDist
	End

	'------------------------------------------
'summery:Returns the current X/Y/Z position of the marker.	
	Method GetCurrPos:Float[]()
		Local pos:Float[2]
		pos[0] = Self.currXpos
		pos[1] = Self.currYpos
		Return pos
	End
	
	'------------------------------------------
'summery:Returns the source destination waypoint.	
	Method GetCurrSrcWP:ftWaypoint()
		Return Self.srcWP
	End
	
	'------------------------------------------
'summery:Returns if the marker reached the end of a path.	
	Method GetFinal:Bool()
		Return Self._final
	End

	'------------------------------------------
'summery:Moves a marker to a waypoint with a given index. Index starts with 1.	
	Method MoveToWP:Void(index:Int=1)
		Local nCount:Int = Self.path.wpList.Count()
#If CONFIG="debug"
		If index < 1 Or index > nCount Then Error ("~n~nError in file fantomEngine.cftWaypoints, Method ftMarker.MoveTpWP(index:Int):~n~nUsed index ("+index+") is out of bounds (1-"+nCount+")")
#End		
		Self.srcIndex = index		
		Select Self.mode
			Case ftPath.mmCircle
				If Self.direction = ftPath.mdForward
					'If Self.srcIndex = nCount Then Self.srcIndex = 1
					Self.destIndex = Self._GetIndex(Self.srcIndex, 1)
					Self.nextIndex = Self._GetIndex(Self.destIndex, 1)
					Self.prevIndex = Self._GetIndex(Self.srcIndex, -1)
				Else
					'If Self.srcIndex = 1 Then Self.srcIndex = nCount
					Self.destIndex = Self._GetIndex(Self.srcIndex, -1)
					Self.nextIndex = Self._GetIndex(Self.destIndex,-1)
					Self.prevIndex = Self._GetIndex(Self.srcIndex, 1)
				Endif
			Default
				If Self.direction = ftPath.mdForward
					'If Self.srcIndex = nCount Then Self.srcIndex = 1
					Self.destIndex = Min(Self.srcIndex+1, nCount)
					Self.nextIndex = Min(Self.destIndex+1, nCount)
					Self.prevIndex = Max(Self.srcIndex - 1, 1)
				Else
					'If Self.srcIndex = 1 Then Self.srcIndex = nCount
					Self.destIndex = Max(Self.srcIndex-1, 1)
					Self.nextIndex = Max(Self.destIndex-1, 1)
					Self.prevIndex = Min(Self.srcIndex+1, nCount)
				Endif
		End
		Self._Calc()
	End

	'------------------------------------------
'summery:Moves a marker to a specific waypoint.	
	Method MoveToWP:Void(waypoint:ftWaypoint)
		Self.MoveToWP(waypoint.GetIndex())
	End

'#DOCOFF#
	'------------------------------------------
	Method New()
		Self.prevWP = Null
		Self.srcWP = Null
		Self.destWP = Null
		Self.nextWP = Null
		
		Self.diffX = 0.0
		Self.diffY = 0.0
		
		Self.currDist = 0.0
		Self.distance = 0.0
		Self.currAngle = 0.0
		
		Self.prevIndex = -1
		Self.srcIndex = -1
		Self.destIndex = -1
		Self.nextIndex = -1
		Self.cmPos = New ftVec2D(0,0)
		Self.cmP1  = New ftVec2D(0,0)
		Self.cmP2  = New ftVec2D(0,0)
		Self.cmP3  = New ftVec2D(0,0)
		Self.cmP4  = New ftVec2D(0,0)
	End
'#DOCON#	

	'------------------------------------------
'summery:Removes a marker.	
	Method Remove:Void()
		If Self.path.inUpdate = False Then
			Self.pathNode.Remove()
			Self.path = Null
			For Local tmpObj := Eachin Self.objList
				tmpObj.markerNode.Remove() 
				tmpObj.marker = Null			
			Next
		Else
			Self.isDeleted = True
		Endif
	End

	'------------------------------------------
#Rem
'summery:Renders a marker at its current position.	
'A renderType of 0 renders a box, every other value a circle.
#End
	Method Render:Void(renderType:Int=0)
		If renderType = 0 Then
			PushMatrix
			Translate (Self.currXpos, Self.currYpos) 
			Rotate 360.0-Self.currAngle
			DrawRect -5, -10, 10, 20
			PopMatrix
		Else
			DrawCircle Self.currXpos, Self.currYpos, 3
		Endif
	End

	'------------------------------------------
'summery:Sets the direction of a marker.	
	Method SetDirection:Void(dir:Int = ftPath.mdForward)
		Local nCount:Int = Self.path.GetWPCount()
		Self.direction = dir

				
		Select Self.mode
			Case ftPath.mmCircle
				If Self.direction = ftPath.mdForward
					If Self.srcIndex = nCount Then Self.srcIndex = 1
					Self.destIndex = Self._GetIndex(Self.srcIndex, 1)
					Self.nextIndex = Self._GetIndex(Self.destIndex, 1)
					Self.prevIndex = Self._GetIndex(Self.srcIndex, -1)
				Else
					If Self.srcIndex = 1 Then Self.srcIndex = nCount
					Self.destIndex = Self._GetIndex(Self.srcIndex, -1)
					Self.nextIndex = Self._GetIndex(Self.destIndex,-1)
					Self.prevIndex = Self._GetIndex(Self.srcIndex, 1)
				Endif
			Default
				If Self.direction = ftPath.mdForward
					If Self.srcIndex = nCount Then Self.srcIndex = 1
					Self.destIndex = Min(Self.srcIndex+1, nCount)
					Self.nextIndex = Min(Self.destIndex+1, nCount)
					Self.prevIndex = Max(Self.srcIndex - 1, 1)
				Else
					If Self.srcIndex = 1 Then Self.srcIndex = nCount
					Self.destIndex = Max(Self.srcIndex-1, 1)
					Self.nextIndex = Max(Self.destIndex-1, 1)
					Self.prevIndex = Min(Self.srcIndex+1, nCount)
				Endif
			'Case ftPath.mmStop
			'Case ftPath.mmBounce
			'Case ftPath.mmWarp
		End
		Self._Calc()

	End

	'------------------------------------------
'summery:Sets the interpolation mode of a marker.	
	Method SetInterpolationMode:Void(mode:Int = ftPath.imLinear)
		Self.ipMode = mode
	End

	'------------------------------------------
'summery:Sets the move mode of a marker.	
	Method SetMoveMode:Void(mode:Int = ftPath.mmStop)
		Self.mode = mode
	End
	
	'------------------------------------------
#Rem
'summery:Sets the sensivity of a marker.	
'The sensivity controls when a marker reaches its next waypoint. It is the minimum distance in pixel.
#End
	Method SetSensivity:Void(sensivityFactor:Float = 0.1)
		Self.sensivity = sensivityFactor
	End

	'------------------------------------------
'summery:Sets the speed of a marker.
	Method SetSpeed:Void(speedFactor:Float = 1.0)
		Self.speed = speedFactor
	End

	'------------------------------------------
'summery:Updates a marker and a connected object.
	Method Update:Float(speedFactor:Float = 1.0)
		Local diffdist:Float
		Local cmf:Float
		If Self._final = True Then Return 0
		If Self.isDeleted = True Then Return 0
		Select Self.ipMode
			Case ftPath.imLinear
				Self.currDist = Self.currDist - (speed*speedFactor)
				If Self.currDist < Self.sensivity Then
					'Self.path.engine.OnMarkerWP(Self, Self.obj)
					_OnMarkerWP()
					Self._NextWP()
				Endif
				diffdist = Self.distance - Self.currDist 
				If Self._final = False Then
					Self.currXpos = Self.sourceXpos + Self.diffX / Self.distance * diffdist
					Self.currYpos = Self.sourceYpos + Self.diffY / Self.distance * diffdist
				Endif
			Case ftPath.imCatmull
				Self.currDist = Self.currDist - (speed*speedFactor)
				
				If Self.currDist < Self.sensivity Then
					'Self.path.engine.OnMarkerWP(Self, Self.obj)
					_OnMarkerWP()
					Self._NextWP()
				Endif
				
				cmP1.x = Self.prevWP.xPos
				cmP1.y = Self.prevWP.yPos
				
				cmP2.x = Self.srcWP.xPos
				cmP2.y = Self.srcWP.yPos
				
				cmP3.x = Self.destWP.xPos
				cmP3.y = Self.destWP.yPos
				
				cmP4.x = Self.nextWP.xPos
				cmP4.y = Self.nextWP.yPos


				If Self._final = False Then
						cmf = 1.0-(Self.currDist / Self.distance)
						cmPos = _CalculateCatmull(cmf+0.001, cmP1, cmP2, cmP3, cmP4)
						Self.currAngle = ATan2( cmPos.y-Self.currYpos, cmPos.x-Self.currXpos )+90.0
						Self.currXpos = cmPos.x
						Self.currYpos = cmPos.y
				Endif
		End
		While Self.currAngle < 0 
			Self.currAngle = 360.0 + Self.currAngle
		End
		_UpdateObjects()
		Return Self.currDist
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