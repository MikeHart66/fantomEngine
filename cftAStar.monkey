#rem
	Title:        fantomEngine
	Description:  A 2D game framework for the Monkey programming language
	
	Author:       Michael Hartlef
	Contact:      michaelhartlef@gmail.com
	
	Website:      http://www.fantomgl.com
	
	License:      MIT
#End

#Rem
'nav:<blockquote><nav><b>fantomEngine documentation</b> | <a href="index.html">Home</a> | <a href="classes.html">Classes</a> | <a href="3rdpartytools.html">3rd party tools</a> | <a href="examples.html">Examples</a> | <a href="changes.html">Changes</a></nav></blockquote>
#End
#Rem
'header:The cftAStar module hosts several classes that bring A* pathfinding to fantomEngine. The grid of nodes can be of any size and shape.
#End

Import fantomEngine

'#DOCOFF#
'***************************************
Class ftChildNode
	Field node:ftGridNode = Null
	Field cost:Float = 0.0
	Field parentNode:list.Node<ftChildNode> = Null
	'------------------------------------------
	Method Remove:Void()
		Self.parentNode.Remove()
		Self.parentNode = Null
		Self.node = Null
	End
End	
'#DOCON#

'***************************************
'summery:An instance of the class [b]ftGridNode[/b] represents one node inside a grid. And after you have found a path via [b]ftAStar.FindPath[/b], you get a list of nodes you can travewl along their positions.
Class ftGridNode
'#DOCOFF#
	Field id:Int = 0
	Field x:Float = 0.0
	Field y:Float = 0.0
	Field f:Float = 0.0
	Field g:Float = 0.0
	Field h:Float = 0.0
	Field xDist:Float = 0
	Field yDist:Float = 0
	Field cost:Float = 1.0 
	Field iOpen:Bool = False
	Field iClose:Bool = False
	Field block:Bool = False
	Field gridNode:list.Node<ftGridNode> = Null
	Field openNode:list.Node<ftGridNode> = Null
	Field parent:ftGridNode = Null
	Field grid:ftAStar = Null
	Field childList:= New List<ftChildNode> 
'#DOCON#
	'------------------------------------------
'summery:Returns if the node is blocked.	
	Method GetBlock:Bool()
 		Return Self.block
  	End
	'------------------------------------------
'summery:Returns the child of a node specified by a given index. Index starts at 1.	
	Method GetChild:ftGridNode(index:Int)
		Local ci:Int = 0
		Local cc:Int = Self.childList.Count()
#If CONFIG="debug"
		If index < 1 Or index > cc Then Error ("~n~nError in file fantomEngine.cftAStar, Method ftGridNode.GetChild():~n~nUsed index ("+index+") is out of bounds (1-"+cc+")")
#End
 		For Local child := Eachin Self.childList
 			ci = ci + 1
 			If ci = index Then
				Return child.node
			Endif
		Next
		Return Null
  	End
	'------------------------------------------
'summery:Returns the number of children of a node.	
	Method GetChildCount:Int()
 		Return childList.Count()
  	End
	'------------------------------------------
'summery:Returns the ID of a node.	
	Method GetID:Int()
 		Return Self.id
  	End
	'------------------------------------------
'summery:Get the node index Index starts with 1.
	Method GetIndex:Int()
		Local ci:Int = 0
 		For Local node := Eachin grid.nodeList
 			ci = ci + 1
 			If node = self Then
				Return ci
			Endif
		Next
		Return 0
  	End
	'------------------------------------------
'summery:Returns the X and Y position of a node.	
	Method GetPos:Float[]()
		Local p:Float[2]
		p[0] = Self.x
		p[1] = Self.y
 		Return p
  	End
	'------------------------------------------
'summery:Returns the X position of a node.	
	Method GetPosX:Float()
 		Return Self.x
  	End
	'------------------------------------------
'summery:Returns the Y position of a node.	
	Method GetPosY:Float()
 		Return Self.y
  	End
	'------------------------------------------
'summery:Remove a node.	
	Method Remove:Void()
		Self.RemoveAllChildren()
		Self.gridNode.Remove()
		Self.gridNode = Null
		Self.grid = Null
		If openNode <> Null Then
			Self.openNode.Remove()
			Self.openNode = Null
		Endif
	End
	'------------------------------------------
'summery:Remove all connected children of a node.	
	Method RemoveAllChildren:Void()
 		For Local child := Eachin Self.childList.Backwards()
			child.Remove()
		Next
  	End
	'------------------------------------------
'summery:Sets the block flag of a node
	Method SetBlock:Void(blockFlag:Bool)
 		Self.block = blockFlag
  	End
	'------------------------------------------
'summery:Sets the position of a node inside a grid.
	Method SetPos:Void(xpos:Float, ypos:Float, relative:Bool = False)
		If relative = True Then
			self.xDist = xpos
			self.yDist = ypos
			Self.x = Self.xDist + Self.grid.xPos
			Self.y = Self.yDist + Self.grid.yPos
		Else
			Self.xDist = x - Self.grid.xPos
			self.yDist = y - Self.grid.yPos
		Endif
		'Scale and rotate all waypoints of the path
		If Self.grid.GetScaleX() <> 1.0 Or Self.grid.GetScaleY() <> 1.0 then
			Self.grid.SetScale(0.0, 0.0, True)
		Elseif Self.grid.GetAngle() <> 0.0
			Self.grid.SetAngle(0.0, True)
		Endif
	End
End	


'***************************************
'summery:The class [b]ftAStar[/b] provides A-Star pathfinding functionality for fantomEngine. The calculated paths can be used to set up waypoints for the [b]ftWaypoint[/b] class.
Class ftAStar
'#DOCOFF#
    Field nodeList:= New List<ftGridNode>
    Field openList:= New List<ftGridNode>
    Field pathList:= New List<ftGridNode>
    Field pathTime:Int = 0
    Field engine:ftEngine = Null
	Field xPos:Float = 0
	Field yPos:Float = 0
    Field angle:Float = 0.0
    Field scaleX:Float = 1.0
    Field scaleY:Float = 1.0
	'------------------------------------------
	Method _ClearOpenList:Void()
 		For Local node := Eachin Self.openList
 			node.openNode.Remove()
 			node.openNode = Null
 		Next
	End
	'------------------------------------------
	Method _OpenListAdd:Void(node:ftGridNode)
		node.openNode = Self.openList.AddLast(node)
		node.iOpen = True
	End
	'------------------------------------------
	Method _OpenListRemove:Void(node:ftGridNode)
		node.openNode.Remove()
		node.iClose = True
	End
'#DOCON#
	'------------------------------------------
'summery:Add a node to a grid.
	Method AddNode:ftGridNode(ID:Int, xpos:Float, ypos:Float, relative:Bool = False)
		Local tmpNode := New ftGridNode
		If relative = True Then
			tmpNode.xDist = xpos
			tmpNode.yDist = ypos
			tmpNode.x = tmpNode.xDist + Self.xPos
			tmpNode.y = tmpNode.yDist + Self.yPos
		Else
			tmpNode.x = xpos
			tmpNode.y = ypos
			tmpNode.xDist = xpos - Self.xPos
			tmpNode.yDist = ypos - Self.yPos
		Endif
		tmpNode.id = ID
		tmpNode.gridNode = Self.nodeList.AddLast(tmpNode)
		tmpNode.grid = Self
		If Self.GetScaleX() <> 1.0 Or Self.GetScaleY() <> 1.0 then
			Self.SetScale(0.0, 0.0, True)
		Elseif Self.GetAngle() <> 0.0
			Self.SetAngle(0.0, True)	
		Endif	
		Return tmpNode
	End
	'------------------------------------------
'summery:Connect a child node to its parent node by their node index.
	Method Connect:Void(parentIndex:Int, childIndex:Int, bothSides:Bool = False)
		Local diffX:Float
		Local diffY:Float
		Local dist:Float
		Local cost:Float
		Local parent:ftGridNode=Null
		Local child:ftGridNode=Null
		
		parent = Self.GetNode(parentIndex)
#If CONFIG="debug"
		If parent = Null Then Error ("~n~nError in file fantomEngine.cftAStar, Method ftAStar.Connect():~n~nparentIndex ("+parentIndex+") is not valid.")
#End
		child = Self.GetNode(childIndex)
#If CONFIG="debug"
		If child = Null Then Error ("~n~nError in file fantomEngine.cftAStar, Method ftAStar.Connect():~n~nchildIndex ("+childIndex+") is not valid.")
#End
		diffX = child.x - parent.x
		diffY = child.y - parent.y
		dist = Sqrt(diffX * diffX + diffY * diffY)
		cost = dist
		Local childNode := New ftChildNode
		childNode.node = child
		childNode.cost = cost
		childNode.parentNode = parent.childList.AddLast(childNode)
		If bothSides = True Then
			Local childNode2 := New ftChildNode
			childNode2.node = parent
			childNode2.cost = cost
			childNode2.parentNode = child.childList.AddLast(childNode2)
		Endif
	End

	'------------------------------------------
'summery:Connect a child node to its parent node by their ID values.
	Method ConnectByID:Void(parentID:Int, childID:Int, bothSides:Bool = False)
		Local diffX:Float
		Local diffY:Float
		Local dist:Float
		Local cost:Float
		Local parent:ftGridNode=Null
		Local child:ftGridNode=Null
		
		parent = Self.GetNodeByID(parentID)
#If CONFIG="debug"
		If parent = Null Then Error ("~n~nError in file fantomEngine.cftAStar, Method ftAStar.ConnectByID():~n~nparentID ("+parentID+") is not valid.")
#End
		child = Self.GetNodeByID(childID)
#If CONFIG="debug"
		If child = Null Then Error ("~n~nError in file fantomEngine.cftAStar, Method ftAStar.ConnectByID():~n~nchildID ("+childID+") is not valid.")
#End
		diffX = child.x - parent.x
		diffY = child.y - parent.y
		dist = Sqrt(diffX * diffX + diffY * diffY)
		cost = dist
		Local childNode := New ftChildNode
		childNode.node = child
		childNode.cost = cost
		childNode.parentNode = parent.childList.AddLast(childNode)
		If bothSides = True Then
			Local childNode2 := New ftChildNode
			childNode2.node = parent
			childNode2.cost = cost
			childNode2.parentNode = child.childList.AddLast(childNode2)
		Endif
	End

	'------------------------------------------
'summery:To find the closest node of a grid to a given position, use this method.
	Method FindClosestNode:ftGridNode(xpos:Float, ypos:Float)
		Local cdist:Float
		Local dist:Float
		Local dX:Float
		Local dY:Float
		Local tmpNode:ftGridNode = Null
    
		cdist = 999999.9

		For Local node := Eachin Self.nodeList
			If node.GetBlock() = True Then Continue
			dX = xpos - node.x
			dY = ypos - node.y
			dist = Sqrt(dX*dX + dY*dY)
			If dist < cdist Then
				cdist = dist
				tmpNode = node
			Endif    
		Next
		Return tmpNode
	End
	
	'------------------------------------------
'summery:Calculates a path between two grid nodes and return the length of the path in pixel.
	Method FindPath:Float(startIndex:Int, endIndex:Int)
		Local path:ftPath = Null
		Local startNode:ftGridNode = Null
		Local endNode:ftGridNode = Null
		Local nextNode:ftGridNode = Null
		Local childNode:ftGridNode = Null
		
		Local endNodeFound:Bool = False
		
		Local maxF:Int = 0
		Local tempG:Int = 0
		Local h1:Int = 0
		Local h2:Int = 0
		
		startNode = Self.GetNode(startIndex)
		endNode = Self.GetNode(endIndex)
		If startNode = Null Or endNode = Null Then  Return -1.0

		Self.pathList.Clear()
		Self._ClearOpenList()
		
		For Local node := Eachin Self.nodeList
			node.iOpen = False
			node.iClose = False
			node.g = 0
		Next
	    If endNode <> startNode Then
	    	Self.pathTime = Millisecs()
		    'Add the start node to the open list
			startNode.parent = Null

			_OpenListAdd(startNode)

			' Add children of the startNode to the open list
			For Local child := Eachin startNode.childList
				childNode = child.node
				If childNode <> endNode Then
		            If childNode.block = False Then

		                childNode.g = child.cost + startNode.g       
		
		                h1 = Abs(childNode.x - endNode.x)
		                h2 = Abs(childNode.y - endNode.y)
		                childNode.h = h1 + h2
		
		                childNode.f = childNode.g + childNode.h
		                
		                childNode.parent = startNode

		                _OpenListAdd(childNode)
		            End If
				Else
		            childNode.g = child.cost + startNode.g
		            childNode.f = childNode.g + childNode.h
		            childNode.parent = startNode
		            endNodeFound = True
				Endif
	
			Next    
			'startNode.iClose = True

			_OpenListRemove(startNode)
	
		    While ( Self.openList.Count() > 0 And endNodeFound = False )
		        'Check which Item should be looked at next
		        maxF = 999999
				For Local openNode := Eachin Self.openList
		            If openNode.f < maxF Then 
		                nextNode = openNode
		                maxF = openNode.f
		            End If
				Next
	
				For Local nextChild := Eachin nextNode.childList
	
		            childNode = nextChild.node
		
		            If childNode <> endNode Then
		                If childNode.block = False Then
		                    If childNode.iClose = False Then
		                        If childNode.iOpen = False Then
		
		                            childNode.g = nextChild.cost + nextNode.g
		                            
		                            h1 = Abs(childNode.x - endNode.x)
		                            h2 = Abs(childNode.y - endNode.y)
	
		                            childNode.h = h1 + h2
		                            
		                            childNode.f = childNode.g + childNode.h
		                            childNode.parent = nextNode
		                			_OpenListAdd(childNode)
	
		                    	Else
		                            tempG = nextChild.cost + nextNode.g
		                            If tempG < childNode.g Then
		                                childNode.g = tempG
		                                childNode.f = tempG + childNode.h
		                                childNode.parent = nextNode
		                            End If    
		                        End If
		                    End If
		                End If 
		            Else
		                childNode.g = nextChild.cost + nextNode.g
		                childNode.f = childNode.g + childNode.h
		                childNode.parent = nextNode
		
		                endNodeFound = True
		                Exit
		            End If
		        Next

		        _OpenListRemove(nextNode)
		    Wend
	
			' Collecting all nodes of the path
			If endNodeFound = True
				nextNode = endNode
				While nextNode <> startNode
					Self.pathList.AddFirst(nextNode)
					nextNode = nextNode.parent
				Wend
				Self.pathList.AddFirst(nextNode)
	    		Self._ClearOpenList()
	    		Self.pathTime = Millisecs() - Self.pathTime
				Return endNode.g
	      	Else
	    		Self._ClearOpenList()
	    		Self.pathTime = -1
			Endif
		Endif
		Return 0
	End
	'------------------------------------------
'summery:Returns the angle of the grid.
	Method GetAngle:Float()
		Return Self.angle	
	End
	'------------------------------------------
'summery:Returns the block flag of a grid node.
	Method GetBlock:bool(index:Int)
		Local ci:Int = 0
		Local cc:Int = Self.nodeList.Count()
#If CONFIG="debug"
		If index < 1 Or index > cc Then Error ("~n~nError in file fantomEngine.cftAStar, Method ftAStar.GetBlock():~n~nUsed index ("+index+") is out of bounds (1-"+cc+")")
#End
 		For Local node := Eachin Self.nodeList
 			ci = ci + 1
 			If ci = index Then
				Return node.GetBlock()
			Endif
		Next
		Return False	
	End
	'------------------------------------------
'summery:Returns the the child grid node of a parent grid node specified both by index. Index start at 1.
	Method GetChild:ftGridNode(parentIndex:Int, childIndex:Int)
		Local ci:Int = 0
		Local cc:Int = Self.nodeList.Count()
#If CONFIG="debug"
		If parentIndex < 1 Or parentIndex > cc Then Error ("~n~nError in file fantomEngine.cftAStar, Method ftAStar.GetChild():~n~nUsed index ("+parentIndex+") is out of bounds (1-"+cc+")")
#End
 		For Local node := Eachin Self.nodeList
 			ci = ci + 1
 			If ci = parentIndex Then
				Return node.GetChild(childIndex)
			Endif
		Next
		Return Null
  	End
	
	'------------------------------------------
'summery:Returns the number of child nodes of a child node.
	Method GetChildCount:Int(index:Int)
		Local ci:Int = 0
		Local cc:Int = Self.nodeList.Count()
#If CONFIG="debug"
		If index < 1 Or index > cc Then Error ("~n~nError in file fantomEngine.cftAStar, Method ftAStar.GetChildCount():~n~nUsed index ("+index+") is out of bounds (1-"+cc+")")
#End
 		For Local node := Eachin Self.nodeList
 			ci = ci + 1
 			If ci = index Then
				Return node.GetChildCount()
			Endif
		Next
		Return 0	
	End
	
	
	'------------------------------------------
'summery:Get the node ID with the given index. Index starts with 1.
	Method GetNodeID:Int(index:Int)
		Local ci:Int = 0
 		For Local node := Eachin Self.nodeList
 			ci = ci + 1
 			If ci = index Then
				Return node.id
			Endif
		Next
		Return 0
  	End
	'------------------------------------------
'summery:Get the node index with the given ID. Index starts with 1.
	Method GetNodeIndex:Int(id:Int)
		Local ci:Int = 0
 		For Local node := Eachin Self.nodeList
 			ci = ci + 1
 			If node.id = id Then
				Return ci
			Endif
		Next
		Return 0
  	End
	'------------------------------------------
'summery:Get the node with the given index. Index starts with 1.
	Method GetNode:ftGridNode(index:Int)
		Local ci:Int = 0
		Local cc:Int = Self.nodeList.Count()
#If CONFIG="debug"
		If index < 1 Or index > cc Then Error ("~n~nError in file fantomEngine.cftAStar, Method ftAStar.GetNodeByIndex():~n~nUsed index ("+index+") is out of bounds (1-"+cc+")")
#End
 		For Local node := Eachin Self.nodeList
 			ci = ci + 1
 			If ci = index Then
				Return node
			Endif
		Next
		Return Null
  	End
	'------------------------------------------
'summery:Get the node with the given ID.
	Method GetNodeByID:ftGridNode(id:Int)
		Local tmpNode:ftGridNode = Null
 		For Local node := Eachin Self.nodeList
 			If node.id = id Then
				tmpNode = node
				Return tmpNode
			Endif
		Next
		Return Null
  	End
	'------------------------------------------
'summery:Returns the grid node count.
	Method GetNodeCount:Int()
		Return Self.nodeList.Count()
	End
	'------------------------------------------
'summery:Returns the path node count of the last calculated path.
	Method GetPathNodeCount:Int()
		Return pathList.Count()
	End
	'------------------------------------------
'summery:Get the grid node with the given index. Index starts with 1.
	Method GetPathNode:ftGridNode(index:Int)
		Local ci:Int = 0
		Local cc:Int = Self.pathList.Count()
#If CONFIG="debug"
		If index < 1 Or index > cc Then Error ("~n~nError in file fantomEngine.cftAStar, Method ftAStar.GetPathNode():~n~nUsed index ("+index+") is out of bounds (1-"+cc+")")
#End
 		For Local node := Eachin Self.pathList
 			ci = ci + 1
 			If ci = index Then
				Return node
			Endif
		Next
		Return Null
  	End
	'------------------------------------------
'summery:Returns the X and Y position of a grid node.
	Method GetPos:Float[](index:Int)
		Local retPos:Float[2]
		Local ci:Int = 0
		Local cc:Int = Self.nodeList.Count()
#If CONFIG="debug"
		If index < 1 Or index > cc Then Error ("~n~nError in file fantomEngine.cftAStar, Method ftAStar.GetPos():~n~nUsed index ("+index+") is out of bounds (1-"+cc+")")
#End
 		For Local node := Eachin Self.nodeList
 			ci = ci + 1
 			If ci = index Then
 				retPos = node.GetPos()
				Return retPos
			Endif
		Next
		Return retPos
  	End
	'------------------------------------------
'summery:Returns the X position of a grid node.
	Method GetPosX:Float(index:Int)
		Local ret:Float = 0.0
		Local ci:Int = 0
		Local cc:Int = Self.nodeList.Count()
#If CONFIG="debug"
		If index < 1 Or index > cc Then Error ("~n~nError in file fantomEngine.cftAStar, Method ftAStar.GetPosX():~n~nUsed index ("+index+") is out of bounds (1-"+cc+")")
#End
 		For Local node := Eachin Self.nodeList
 			ci = ci + 1
 			If ci = index Then
				Return node.GetPosX()
			Endif
		Next
		Return ret
  	End
	'------------------------------------------
'summery:Returns the Y position of a grid node.
	Method GetPosY:Float(index:Int)
		Local ret:Float = 0.0
		Local ci:Int = 0
		Local cc:Int = Self.nodeList.Count()
#If CONFIG="debug"
		If index < 1 Or index > cc Then Error ("~n~nError in file fantomEngine.cftAStar, Method ftAStar.GetPosY():~n~nUsed index ("+index+") is out of bounds (1-"+cc+")")
#End
 		For Local node := Eachin Self.nodeList
 			ci = ci + 1
 			If ci = index Then
				Return node.GetPosY()
			Endif
		Next
		Return ret
  	End
	'------------------------------------------
'summery:Returns the X scale factor of the grid.
	Method GetScaleX:Float()
		Return Self.scaleX	
	End
	'------------------------------------------
'summery:Returns the Y scale factor of the grid.
	Method GetScaleY:Float()
		Return Self.scaleY	
	End
	'------------------------------------------
'summery:Load a grid from a string.
	Method LoadFromString:Void(ps:String)
		Local entryCount:Int = 0
		Local nx:Float = 0.0
		Local ny:Float = 0.0

		Local _angle:Float = 0.0
		Local _xp:Float = 0.0
		Local _yp:Float = 0.0

		Local _sx:Float = 0.0
		Local _sy:Float = 0.0
		
		
		Local _id:Int = 0
		Local _blocked:Int = False
		Local _cc:Int = 0
		Local _cid:Int = 0

		Local cw:Float=0
		Local ch:Float=0
		
		Self.RemoveAllNodes()
		
		Local lines := ps.Split(String.FromChar(10))		
		For Local line:= Eachin lines
	
			If line = "" Then Continue
			If line.StartsWith("nodeCount=") Then
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
			Elseif line.StartsWith("node=") Then 
				Local ct$[] = line.Split("=")
				Local dt$[] = ct[1].Split(";")
				'ps = ps + "node="+node.id + ";" + node.x + ";" + node.y + ";" + node.GetBlock()
				_id = Int(dt[0])
				nx = (Float(dt[1])/cw)*engine.GetCanvasWidth()
				ny = (Float(dt[2])/ch)*engine.GetCanvasHeight()
				_blocked = Int(dt[3])
				Local node := Self.AddNode(_id, nx, ny) 
				If _blocked = 1 Then node.SetBlock(True)
			Elseif line.StartsWith("children=") Then 
				Local ct$[] = line.Split("=")
				Local dt$[] = ct[1].Split(";")
				_id = Int(dt[0])
				_cc = Int(dt[1])
				For Local ci := 1 To _cc
					_cid = Int(dt[1+ci])
					Self.ConnectByID(_id, _cid)
				Next
				
			Endif
		Next
		'Self.SetPos( (_xp/cw) * engine.GetCanvasWidth(), (_yp/ch) * engine.GetCanvasHeight () )
		'Self.SetScale(_sx, _sy)
		'Self.SetAngle(_angle)
	End	
	'------------------------------------------
'summery:Removes the complete grid.
	Method Remove:Void()
		Self._ClearOpenList()
		Self.RemoveAllNodes()
	End
	'------------------------------------------
'summery:Removes all grid nodes.
	Method RemoveAllNodes:Void()
 		For Local node := Eachin Self.nodeList
 			node.Remove()
 		Next
	End
	'------------------------------------------
#Rem
'summery:Render the grid.
#End
	Method Render:Void(size:Int=20)
		For Local node := Eachin Self.nodeList
			If node.GetBlock() Then Continue
			DrawRect(node.GetPosX()-size/2,node.GetPosY()-size/2,size,size)
			Local cc:Int = node.GetChildCount()
			For Local i:= 1 To cc
				Local childNode:= node.GetChild(i)
				If childNode.GetBlock() Then Continue
				DrawLine( node.GetPosX(),node.GetPosY(), childNode.GetPosX(),childNode.GetPosY() )
			Next
		Next
	End
	'------------------------------------------
'summery:Save a path to a string.
	Method SaveToString:String()
		Local ps:String
		Local cc:Int = 0
		Local ci:Int = 0
		ps = "nodeCount="+Self.nodeList.Count() + String.FromChar(10)
		ps = ps + "canvasWidth=" + engine.GetCanvasWidth() + String.FromChar(10)
		ps = ps + "canvasHeight=" + engine.GetCanvasHeight() + String.FromChar(10)
		ps = ps + "angle=" + Self.angle + String.FromChar(10)
		ps = ps + "xPos=" + Self.xPos + String.FromChar(10)
		ps = ps + "yPos=" + Self.yPos + String.FromChar(10)
		ps = ps + "scaleX=" + Self.scaleX + String.FromChar(10)
		ps = ps + "scaleY=" + Self.scaleY + String.FromChar(10)
		For Local node := Eachin Self.nodeList
			ps = ps + "node="+node.id + ";" + node.x + ";" + node.y + ";" + Int(node.GetBlock()) + String.FromChar(10)
		Next
		For Local nodeC := Eachin Self.nodeList
			cc = nodeC.GetChildCount()
			If cc > 0 Then
				ps = ps + "children="+nodeC.id + ";" + cc
				For ci = 1 To cc
				Local childNode:= nodeC.GetChild(ci)
					ps = ps + ";" + childNode.GetID()
				Next
				ps = ps + String.FromChar(10)
			Endif
		Next
		Return ps
	End
	
	'------------------------------------------
'summery:Sets the angle of a grid and position its nodes regarding the angle.
	Method SetAngle:Void(a:Float, relative:Bool = False)
		Local nodeDist:Float = 0.0
		Local distX:Float = 0.0
		Local distY:Float = 0.0
		Local nodeAngle:Float = 0.0
		If relative = True Then
			Self.angle += a
		Else
			Self.angle = a
		Endif
		For Local node := Eachin Self.nodeList
			distX = node.xDist * Self.scaleX
			distY = node.yDist * Self.scaleY
			' WP distance to path center
		    nodeDist = Sqrt(distX * distX + distY * distY)
			' WP angle to path center
		    nodeAngle = ATan2(distY, distX) + 90.0
		    nodeAngle += Self.angle
			If nodeAngle < 0 Then 
				nodeAngle += 360.0
			Elseif nodeAngle > 360.0 Then 
				nodeAngle -= 360.0
			Endif
			' Calculate new position of the node
			node.x = (Sin(nodeAngle) * nodeDist) + Self.xPos
			node.y = (-Cos(nodeAngle) * nodeDist) + Self.yPos
		Next
	End

	'------------------------------------------
#Rem
'summery:Set the block flag of a grid node.
'A blocked grid node won't be visited during the path finding
#End
	Method SetBlock:Void(index:Int, blockFlag:Bool)
		Local ci:Int = 0
		Local cc:Int = Self.nodeList.Count()
#If CONFIG="debug"
		If index < 1 Or index > cc Then Error ("~n~nError in file fantomEngine.cftAStar, Method ftAStar.SetBlock():~n~nUsed index ("+index+") is out of bounds (1-"+cc+")")
#End
 		For Local node := Eachin Self.nodeList
 			ci = ci + 1
 			If ci = index Then
				node.SetBlock(blockFlag)
				Exit
			Endif
		Next	
	End

	'------------------------------------------
'summery:Sets the position of a grid and its nodes.
	Method SetPos:Void(x:Float, y:Float, relative:Bool = False)
		If relative = True Then
			Self.xPos += x
			Self.yPos += y
		Else
			Self.xPos = x
			Self.yPos = y
		Endif
		For Local node := Eachin Self.nodeList
			node.x = node.xDist + Self.xPos
			node.y = node.yDist + Self.yPos
		Next
		'Scale and rotate all nodes accordning to the scale factors and the angle of the grid
		If Self.GetScaleX() <> 1.0 Or Self.GetScaleY() <> 1.0 then
			Self.SetScale(0.0, 0.0, True)
		Elseif Self.GetAngle() <> 0.0
			Self.SetAngle(0.0, True)	
		Endif	
	End

	'------------------------------------------
'summery:Sets the X position of a grid and its nodes.
	Method SetPosX:Void(x:Float, relative:Bool = False)
		If relative = True Then
			Self.xPos += x
		Else
			Self.xPos = x
		Endif
		For Local node := Eachin Self.nodeList
			node.x = node.xDist + Self.xPos
		Next
		'Scale and rotate all nodes accordning to the scale factors and the angle of the grid
		If Self.GetScaleX() <> 1.0 Or Self.GetScaleY() <> 1.0 Then
			Self.SetScale(0.0, 0.0, True)
		Elseif Self.GetAngle() <> 0.0
			Self.SetAngle(0.0, True)	
		Endif	
	End

	'------------------------------------------
'summery:Sets the Y position of a grid and its nodes.
	Method SetPos:Void(y:Float, relative:Bool = False)
		If relative = True Then
			Self.yPos += y
		Else
			Self.yPos = y
		Endif
		For Local node := Eachin Self.nodeList
			node.y = node.yDist + Self.yPos
		Next
		'Scale and rotate all nodes accordning to the scale factors and the angle of the grid
		If Self.GetScaleX() <> 1.0 Or Self.GetScaleY() <> 1.0 Then
			Self.SetScale(0.0, 0.0, True)
		Elseif Self.GetAngle() <> 0.0
			Self.SetAngle(0.0, True)	
		Endif	
	End

	'------------------------------------------
'summery:Sets the scale of a grid and position its nodes regarding the angle.
	Method SetScale:Void(x:Float, y:Float, relative:Bool = False)
		If relative = True Then
			Self.scaleX += x
			Self.scaleY += y
		Else
			Self.scaleX = x
			Self.scaleY = y
		Endif
		For Local node := Eachin Self.nodeList
			node.x = (node.xDist * Self.scaleX) + Self.xPos
			node.y = (node.yDist * Self.scaleY) + Self.yPos
		Next
		'Rotate all nodes according to the angle of the grid
		If Self.GetAngle() <> 0.0 Then 
			Self.SetAngle(0.0, True)
		Endif
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