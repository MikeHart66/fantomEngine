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
'header:The cftBox2D module hosts an optional Box2D integration class. At the moment, not all functionality of Box2D is integrated but you can create objects, joints, do collision detection and even raycasting.
#End

Import fantomEngine

Import box2d.collision
Import box2d.collision.shapes
Import box2d.dynamics.joints
Import box2d.common.math
Import box2d.common
Import box2d.dynamics.contacts
Import box2d.dynamics.controllers
Import box2d.dynamics.joints
Import box2d.dynamics
Import box2d.flash.flashtypes

'#DOCOFF#' 
Class ftContactListener  Extends b2ContactListener
    Field b2D:ftBox2D
	'------------------------------------------
    Method New(b:ftBox2D)
        Self.b2D = b
    End
	'------------------------------------------
	Method BeginContact:Void (contact:b2Contact)
		b2D.OnBeginContact(contact)
	End
	'------------------------------------------
	Method EndContact:Void (contact:b2Contact)
		b2D.OnEndContact(contact)
	End
	'------------------------------------------
	Method PostSolve:Void (contact:b2Contact, impulse:b2ContactImpulse)
		b2D.OnPostSolve(contact, impulse)
	End
	'------------------------------------------
	Method PreSolve : Void (contact:b2Contact, manifold:b2Manifold)
		b2D.OnPreSolve(contact, manifold)
	End
End

'#DOCON#    
'***************************************
#Rem
'summery:The ftBox2D class integrates some functionality of Box2D into your project. With it you can connect ftObjects with Box2D bodies. For feature requests, please contact Michael about what you need.
#End

Class ftBox2D
'#DOCOFF#' 
	Field engine:ftEngine
	
    Const frameRate:Int = 30
    Const physicsRate:Int = 60
    Const physicsFrameMS:Float = 1000.0/physicsRate
    Const physicsFramesPerRender:Float = Float(physicsRate)/frameRate
    
    
    Const btStatic:Int = 0
    Const btKinematic:Int = 1
    Const btBody:Int = 2     'Dynamic body
    
	Field m_physScale:Float = 30
    
    Field nextFrame:Float = 0.0

	Field m_world:b2World
	'// Sprite to draw in to
    Field m_sprite:FlashSprite
'#DOCON#    


	'------------------------------------------
'summery:Adds a polygon shape to an existing polygon physics body.
'The base of this method was provided generously by the Monkey user CalebDev 
	Method AddPolygon:Void(tmpObj:ftObject, vec:Float[] )
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.AddPolygon - body = NULL")
		Local shape:b2PolygonShape = New b2PolygonShape()
		Local xp:Float
		Local yp:Float
		Local vecLen:Float = vec.Length()
		Local vecLenHalf = vecLen/2
		Local v:b2Vec2[vecLen/2]
		For Local vl:Float = 1.0 To vecLenHalf
			v[vl-1] = New b2Vec2
		Next
		For Local i:Float = 1.0 To vecLen Step 2
			xp = vec[i-1]/m_physScale
			yp = vec[i]/m_physScale	
			v[(i-1)/2].x = xp
			v[(i-1)/2].y = yp
		Next
		shape.SetAsArray(v, vecLenHalf)
		body.CreateFixture2(shape)

	End

	'------------------------------------------
'summery:Applies force to the connected body of a ftObject.
	Method ApplyForce:Void(tmpObj:ftObject, forceX:Float, forceY:Float, pointX:Float, pointY:Float)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		Local f:b2Vec2 = New b2Vec2
		Local p:b2Vec2 = New b2Vec2
		If body = Null Then Error("ftBox2D.ApplyForce - body = NULL")
		f.x = forceX
		f.y = forceY
		p.x = pointX/m_physScale
		p.y = pointY/m_physScale
		body.ApplyForce (f, p)
	End
	'------------------------------------------
'summery:Applies torque to the connected body of a ftObject.
	Method ApplyTorque:Void(tmpObj:ftObject, torque:Float, degree:Bool=True)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		'Local i:b2Vec2 = New b2Vec2
		'Local p:b2Vec2 = New b2Vec2
		If body = Null Then Error("ftBox2D.ApplyImpulse - body = NULL")
		If degree = True Then torque = torque * 0.0174533

		body.ApplyTorque (torque)
	End
	'------------------------------------------
'summery:Applies an impulse to the connected body of a ftObject.
	Method ApplyImpulse:Void(tmpObj:ftObject, impulseX:Float, impulseY:Float, pointX:Float, pointY:Float)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		Local i:b2Vec2 = New b2Vec2
		Local p:b2Vec2 = New b2Vec2
		If body = Null Then Error("ftBox2D.ApplyImpulse - body = NULL")
		i.x = impulseX
		i.y = impulseY
		p.x = pointX/m_physScale
		p.y = pointY/m_physScale
		body.ApplyImpulse (i, p)
	End
	'------------------------------------------
'summery:Connects the body to an ftObject.
	Method ConnectBody:Void(tmpObj:ftObject, body:b2Body )
		tmpObj.box2DBody = body
		body.SetUserData(Object(tmpObj))
	End
	'------------------------------------------
'summery:Create a box shaped B2Body object.
	Method CreateBox:b2Body(width:Float,height:Float, xpos:Float, ypos:float )
        Local shape :b2PolygonShape= New b2PolygonShape()
        Local bodyDef :b2BodyDef = New b2BodyDef()
        Local body :b2Body
        
        bodyDef.position.Set( xpos/m_physScale, ypos/m_physScale)
        shape.SetAsBox(width/2/m_physScale, height/2/m_physScale)
        body = m_world.CreateBody(bodyDef)

		'Local massdata:b2MassData = New b2MassData()
		'massdata.center = New b2Vec2(0, 0)
		'massdata.mass = 1.0
		'massdata.I = 0.0

        body.CreateFixture2(shape)
		'body.SetMassData(massdata)
		Return body
	end
	'------------------------------------------
'summery:Create a circle shaped B2Body object.
	Method CreateCircle:b2Body(radius:Float, xpos:Float, ypos:float )
        Local shape :b2CircleShape= New b2CircleShape(radius/m_physScale)
        Local bodyDef :b2BodyDef = New b2BodyDef()
        Local body :b2Body
        
        bodyDef.position.Set( xpos/m_physScale, ypos/m_physScale)
        body = m_world.CreateBody(bodyDef)

		'Local massdata:b2MassData = New b2MassData()
		'massdata.center = New b2Vec2(0, 0)
		'massdata.mass = 1.0
		'massdata.I = 0.0

        body.CreateFixture2(shape)
		'body.SetMassData(massdata)
		Return body
	end

	'------------------------------------------
'summery:Create a distant joint.
	Method CreateDistantJoint:b2DistanceJoint(bodyA:b2Body, bodyB:b2Body)
		Local dd:b2DistanceJointDef = New b2DistanceJointDef()
		dd.Initialize(bodyA, bodyB, bodyA.GetWorldCenter(), bodyB.GetWorldCenter())
		Local distanceJoint := b2DistanceJoint(m_world.CreateJoint(dd))
		Return distanceJoint
	end
	'------------------------------------------
'summery:Create a mouse joint.
	Method CreateMouseJoint:b2MouseJoint(groundBody:b2Body, targetBody:b2Body, targetX:Float, targetY:Float, maxForce:Float, collideConnect:Bool = True, frequencyHz:Float = 5.0, dampingRatio:Float = 0.7 )
		Local md :b2MouseJointDef = New b2MouseJointDef()
		md.bodyA = groundBody
		md.bodyB = targetBody
		md.target.Set(targetX/m_physScale, targetY/m_physScale)
		md.collideConnected = collideConnect
		md.maxForce = maxForce
		md.frequencyHz = frequencyHz
		md.dampingRatio = dampingRatio
		Local mouseJoint := b2MouseJoint(m_world.CreateJoint(md))
		Return mouseJoint
	end
	'------------------------------------------
'summery:Create a revolute joint.
	Method CreateRevoluteJoint:b2RevoluteJoint(bodyA:b2Body, bodyB:b2Body, startX:Float, startY:Float, lowerAngle:Float, upperAngle:Float, degree:Bool = True)
		Local rd:b2RevoluteJointDef = New b2RevoluteJointDef()
		Local lA:Float = lowerAngle
		Local uA:Float = upperAngle
		If degree = True Then 
			lA = lA * 0.0174533
			uA = uA * 0.0174533
		endif
		rd.enableLimit = True
		rd.lowerAngle = lA
		rd.upperAngle = uA
		
		rd.Initialize(bodyA, bodyB, New b2Vec2((startX/m_physScale), (startY / m_physScale)))
		Local revoluteJoint := b2RevoluteJoint(m_world.CreateJoint(rd))
		Return revoluteJoint
	end
	'------------------------------------------
'summery:Create a rope joint.
	Method CreateRopeJoint:b2RopeJoint(bodyA:b2Body, bodyB:b2Body, maxDistance:Float, collideConnect:Bool = True)
		Local rd:b2RopeJointDef = New b2RopeJointDef()
		'rd.Initialize(bodyA, bodyB, New b2Vec2, New b2Vec2, maxDistance)
		rd.bodyA = bodyA
		rd.bodyB = bodyA
		rd.localAnchorA = New b2Vec2
		rd.localAnchorB = New b2Vec2
		rd.maxLength = maxDistance/m_physScale
		rd.collideConnected = collideConnect
		Local ropeJoint := b2RopeJoint(m_world.CreateJoint(rd))
		Return ropeJoint
	end
	'------------------------------------------
'summery:Create a B2Body object based on a ftObject. It will also connect it to the ftObject.
	Method CreateObject:b2Body(tmpObj:ftObject, btype:Int = b2Body.b2_Body )
		Local shape:b2PolygonShape
		Local shapeC:b2CircleShape
		Local bodyDef:b2BodyDef = New b2BodyDef()
		Local fixtureDef:b2FixtureDef = New b2FixtureDef()
		Local body:b2Body
        
		bodyDef.type = btype
		Select tmpObj.collType
			Case ftEngine.ctCircle	
				shapeC = New b2CircleShape(tmpObj.GetRadius()/m_physScale)
				'shapeC = New b2CircleShape(tmpObj.GetRadius())
				fixtureDef.shape = shapeC
			Default
				shape = New b2PolygonShape()
				shape.SetAsBox(tmpObj.GetWidth()/2/m_physScale,tmpObj.GetHeight()/2/m_physScale)	
				fixtureDef.shape = shape
		End

		
		fixtureDef.density = 0.7
		fixtureDef.friction = 0.1
		fixtureDef.restitution = 0.9
        'bodyDef.angle = (tmpObj.GetAngle())* 0.0174533
        bodyDef.angle = (tmpObj.GetAngle()+90)* 0.0174533
	                
        bodyDef.position.Set( tmpObj.GetPosX()/m_physScale, tmpObj.GetPosY()/m_physScale)
        body = m_world.CreateBody(bodyDef)

		'Local massdata:b2MassData = New b2MassData()
		'massdata.center = New b2Vec2(0, 0)
		'massdata.mass = 1.0
		'massdata.I = 0.0

       	body.CreateFixture(fixtureDef)
		'body.SetMassData(massdata)
		body.SetUserData(Object(tmpObj))
        
		tmpObj.box2DBody = body  
		Return body      
	end
	'------------------------------------------
'summery:Create a polygon shaped B2Body object.
	Method CreatePolygon:b2Body(vec:Float[], xpos:Float, ypos:Float, btype:Int = b2Body.b2_Body )
        Local shape :b2PolygonShape= New b2PolygonShape()
        Local bodyDef :b2BodyDef = New b2BodyDef()
        Local body:b2Body
        Local xp:Float
        Local yp:float
        bodyDef.type = btype
        Local vecLen:Float = vec.Length()
        Local vecLenHalf:Float = vecLen/2
'Local a:Int[][] = New Int[columns][]         
        Local v:b2Vec2[vecLenHalf] 
        For Local vl:Int = 1 To vecLenHalf
        	v[vl-1] = New b2Vec2
        Next
        For Local i:Int = 1 To vecLen Step 2
			xp = vec[i-1]/m_physScale
			yp = vec[i]/m_physScale	
        	v[(i-1)/2].x = xp
        	v[(i-1)/2].y = yp
        Next
        bodyDef.position.Set( xpos/m_physScale, ypos/m_physScale)
        shape.SetAsArray(v, vecLenHalf)
        body = m_world.CreateBody(bodyDef)
        body.CreateFixture2(shape)
		Return body
	end
	'------------------------------------------
'summery:Create a polygon shaped B2Body object from a PhysicsEditor compatible json file.
	Method CreatePolygon:b2Body(filename:String, subBodyName:String, xpos:Float, ypos:Float)
		Local bodyDef :b2BodyDef = New b2BodyDef()
		Local body:b2Body = null
		Local xp:Float
		Local yp:Float
		
		Local fileData:String  = LoadString(filename)
				Local jsonData:JSONDataItem = JSONData.ReadJSON(fileData)
		Local jsonObject:JSONObject = JSONObject(jsonData)
    	Local bodyObjects:JSONArray = JSONArray(jsonObject.GetItem("bodies"))
    	
    	For Local bodySet:JSONDataItem = Eachin bodyObjects
        	Local dataBodySet:JSONObject = JSONObject(bodySet)
        	Local bodyName:String = dataBodySet.GetItem("name")
        	
			If bodyName.ToLower() = subBodyName.ToLower() Then
				If dataBodySet.GetItem("isDynamic") = "True" Then
					bodyDef.type = b2Body.b2_Body
				'Else
				'	bodyDef.type = b2Body.b2_staticBody
				Endif
				If dataBodySet.GetItem("isBullet") = "True" Then
					bodyDef.bullet = True
				Endif
				If dataBodySet.GetItem("fixedRotation") = "True" Then
					bodyDef.fixedRotation = True
				Endif
				Local adamp:Float = dataBodySet.GetItem("angularDamping")
				Local ldamp:Float = dataBodySet.GetItem("linearDamping")
				bodyDef.angularDamping = adamp
				bodyDef.linearDamping = ldamp
				
				bodyDef.position.Set( xpos/m_physScale, ypos/m_physScale)
				
				'Read fixtures
				Local fixturesObjects:JSONArray = JSONArray(dataBodySet.GetItem("fixtures"))
				
				body = m_world.CreateBody(bodyDef)
				For Local fixtureSet:JSONDataItem = Eachin fixturesObjects
					Local dataFixtureSet:JSONObject = JSONObject(fixtureSet)

					Local dens:Float = dataFixtureSet.GetItem("density")
					Local fric:Float = dataFixtureSet.GetItem("friction")
					Local res:Float = dataFixtureSet.GetItem("restitution")


					Local shapeObjects:JSONArray = JSONArray(dataFixtureSet.GetItem("shape"))
					
					'How many vertices entries?
					Local soLength:Int=0
					For Local shapeSet:JSONDataItem = Eachin shapeObjects
						soLength=soLength+1
					Next
					Local vec:Float[] = New Float[soLength]
					Local vecLen:Float = vec.Length()
					Local vecLenHalf:Float = vecLen/2
					Local i:Int= 0
					For Local shapeSet:JSONDataItem = Eachin shapeObjects
						Local shapeValue:JSONInteger = JSONInteger(shapeSet)
						Local vi:Int = shapeValue
						vec[i] = vi
						i = i+1

					Next
					
					'Create b2Vec2 array to store the vectices
			        Local v:b2Vec2[soLength/2] 
			        For Local vl:Int = 1 To vecLenHalf
			        	v[vl-1] = New b2Vec2
			        Next
			
			        For Local i:Int = 1 To vecLen Step 2
						xp = vec[i-1]/m_physScale
						yp = vec[i]/m_physScale	
			        	v[(i-1)/2].x = xp
			        	v[(i-1)/2].y = yp
			        Next
					
					Local shape :b2PolygonShape= New b2PolygonShape()
					shape.SetAsArray(v, vecLenHalf)

					Local def :b2FixtureDef = New b2FixtureDef()
					def.shape = shape
					def.density = dens
					def.friction = fric
					def.restitution = res
					
					def.filter.groupIndex= JSONInteger(dataFixtureSet.GetItem("filterGroupIndex"))
					Local filter:JSONObject = JSONObject(dataFixtureSet.GetItem("filter"))
					def.filter.categoryBits = JSONInteger(filter.GetItem("categoryBits"))
					def.filter.maskBits = JSONInteger(filter.GetItem("maskBits"))
					
					If dataFixtureSet.GetItem("isSensor") = "True" Then
						def.isSensor = True
					Endif

					'body.CreateFixture2(shape)
					body.CreateFixture(def)
 		        
				Next
			Endif
		Next    	
       If body = Null Then Error("ftBox2D.CreatePolygon - body = NULL")
		Return body
	end
	'------------------------------------------
'summery:Create a weld joint.
	Method CreateWeldJoint:b2WeldJoint(bodyA:b2Body, bodyB:b2Body)
		Local wd:b2WeldJointDef = New b2WeldJointDef()
		wd.Initialize(bodyA, bodyB, bodyA.GetWorldCenter())
		Local weldJoint := b2WeldJoint(m_world.CreateJoint(wd))
		Return weldJoint
	end
	'------------------------------------------
'summery:Create a B2World object.
	Method CreateWorld:b2World()
		Local worldAABB :b2AABB = New b2AABB()
		worldAABB.lowerBound.Set(-1000.0, -1000.0)
        worldAABB.upperBound.Set(1000.0, 1000.0)
        '// Define the gravity vector
        Local gravity :b2Vec2 = New b2Vec2(0.0, 0.0)
        '// Allow bodies to sleep
        Local doSleep :Bool = True
        '// Construct a world object
        m_world = New b2World(gravity, doSleep)
        m_world.SetWarmStarting(True)
        m_world.SetContactListener(New ftContactListener(Self))
        Return m_world       
	End
	'------------------------------------------
'summery:Disconnects and destroys the connected body of an ftObject.
	Method DestroyBody:Void(tmpObj:ftObject )
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.DestroyBody - body = NULL")
		tmpObj.box2DBody = Null
		body.SetUserData(Null)
		m_world.DestroyBody(body)
	End
	'------------------------------------------
'summery:Destroys a joint.
	Method DestroyJoint:Void(joint:b2Joint )
		If joint = Null Then Error("ftBox2D.DestroyJoint - joint = NULL")
		m_world.DestroyJoint(joint)
	End
	'------------------------------------------
'summery:Returns the angle of the connected body.
	Method GetAngle:Float(tmpObj:ftObject, degree:Bool = True)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		Local ang:Float 
		If body = Null Then Error("ftBox2D.GetAngle - body = NULL")
		ang = body.GetAngle()
		If degree = True Then ang = ang / 0.0174533
		Return ang
	End
	'------------------------------------------
'summery:Returns the angular damping of a connected body.
	Method GetAngularDamping:Float(tmpObj:ftObject)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		Local damp:Float 
		If body = Null Then Error("ftBox2D.GetAngularDamping - body = NULL")
		damp = body.GetAngularDamping()
		Return damp
	End
	'------------------------------------------
'summery:Returns the angular velocity of a connected body.
	Method GetAngularVelocity:Float(tmpObj:ftObject, degree:Bool = True)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		Local vel:Float 
		If body = Null Then Error("ftBox2D.GetAngularVelocity - body = NULL")
		vel = body.GetAngularVelocity()
		If degree = True Then vel = vel / 0.0174533
		Return vel
	End
	'------------------------------------------
'summery:Returns the connected body of a ftObject.
	Method GetBody:b2Body(tmpObj:ftObject )
		Return b2Body(tmpObj.box2DBody)
	End
	'------------------------------------------
'summery:Returns the density of the fixture with the given index.
	Method GetDensity:Float(tmpObj:ftObject, fIndex:Int = 1)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.GetDensity - body = NULL")
		Local cc:Int = Self.GetFixtureCount(tmpObj)
		If fIndex < 1 Or fIndex > cc Then Error ("~n~nError in file fantomEngine.cftBox2D, Method ftBox2D.GetDensity():~n~nUsed index ("+fIndex+") is out of bounds (1-"+cc+")")
		
		Local nf:Int=0
		Local tmpFix:b2Fixture = body.GetFixtureList()
		If tmpFix <> Null Then
			nf = nf + 1
			If nf = fIndex Then Return tmpFix.GetDensity()
			While tmpFix.GetNext() <> Null
				nf = nf + 1
				If nf = fIndex Then Return tmpFix.GetDensity()
				tmpFix = tmpFix.GetNext()
			Wend
		Endif
		Return 0.0
	End
	'------------------------------------------
'summery:Returns the filter category bits of the fixture with the given index.
	Method GetFilterCategoryBits:Int(tmpObj:ftObject, fIndex:Int = 1)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		Local filterData:b2FilterData
		If body = Null Then Error("ftBox2D.GetFilterCategoryBits - body = NULL")
		Local cc:Int = Self.GetFixtureCount(tmpObj)
		If fIndex < 1 Or fIndex > cc Then Error ("~n~nError in file fantomEngine.cftBox2D, Method ftBox2D.GetFilterCategoryBits():~n~nUsed index ("+fIndex+") is out of bounds (1-"+cc+")")
		
		Local nf:Int=0
		Local tmpFix:b2Fixture = body.GetFixtureList()
		If tmpFix <> Null Then
			nf = nf + 1
			If nf = fIndex Then 
				filterData = tmpFix.GetFilterData()
				Return filterData.categoryBits
			Endif
			While tmpFix.GetNext() <> Null
				nf = nf + 1
				If nf = fIndex Then 
					filterData = tmpFix.GetFilterData()
					Return filterData.categoryBits
				Endif
				tmpFix = tmpFix.GetNext()
			Wend
		Endif
		Return 0.0
	End
	'------------------------------------------
'summery:Returns the filter mask bits of the fixture with the given index.
	Method GetFilterMaskBits:Int(tmpObj:ftObject, fIndex:Int = 1)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		Local filterData:b2FilterData
		If body = Null Then Error("ftBox2D.GetFilterMaskBits - body = NULL")
		Local cc:Int = Self.GetFixtureCount(tmpObj)
		If fIndex < 1 Or fIndex > cc Then Error ("~n~nError in file fantomEngine.cftBox2D, Method ftBox2D.GetFilterMaskBits():~n~nUsed index ("+fIndex+") is out of bounds (1-"+cc+")")
		
		Local nf:Int=0
		Local tmpFix:b2Fixture = body.GetFixtureList()
		If tmpFix <> Null Then
			nf = nf + 1
			If nf = fIndex Then 
				filterData = tmpFix.GetFilterData()
				Return filterData.maskBits
			Endif
			While tmpFix.GetNext() <> Null
				nf = nf + 1
				If nf = fIndex Then 
					filterData = tmpFix.GetFilterData()
					Return filterData.maskBits
				Endif
				tmpFix = tmpFix.GetNext()
			Wend
		Endif
		Return 0
	End
	'------------------------------------------
'summery:Returns the filter mask bits of the fixture with the given index.
	Method GetFilterGroupIndex:Int(tmpObj:ftObject, fIndex:Int = 1)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		Local filterData:b2FilterData
		If body = Null Then Error("ftBox2D.GetFilterGroupIndex - body = NULL")
		Local cc:Int = Self.GetFixtureCount(tmpObj)
		If fIndex < 1 Or fIndex > cc Then Error ("~n~nError in file fantomEngine.cftBox2D, Method ftBox2D.GetFilterGroupIndex():~n~nUsed index ("+fIndex+") is out of bounds (1-"+cc+")")
		
		Local nf:Int=0
		Local tmpFix:b2Fixture = body.GetFixtureList()
		If tmpFix <> Null Then
			nf = nf + 1
			If nf = fIndex Then 
				filterData = tmpFix.GetFilterData()
				Return filterData.groupIndex
			Endif
			While tmpFix.GetNext() <> Null
				nf = nf + 1
				If nf = fIndex Then 
					filterData = tmpFix.GetFilterData()
					Return filterData.groupIndex
				Endif
				tmpFix = tmpFix.GetNext()
			Wend
		Endif
		Return 0
	End
	'------------------------------------------
'summery:Returns the fixture of a objects connected body with the given index.
	Method GetFixture:b2Fixture(tmpObj:ftObject, fIndex:Int = 1)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.GetFixture - body = NULL")
		Local cc:Int = Self.GetFixtureCount(tmpObj)
		If fIndex < 1 Or fIndex > cc Then Error ("~n~nError in file fantomEngine.cftBox2D, Method ftBox2D.GetFixture():~n~nUsed index ("+fIndex+") is out of bounds (1-"+cc+")")
		
		Local nf:Int=0
		Local tmpFix:b2Fixture = body.GetFixtureList()
		If tmpFix <> Null Then
			nf = nf + 1
			If nf = fIndex Then Return tmpFix
			While tmpFix.GetNext() <> Null
				nf = nf + 1
				If nf = fIndex Then Return tmpFix
				tmpFix = tmpFix.GetNext()
			Wend
		Endif
		Return Null
	End
	'------------------------------------------
'summery:Returns the number of fixtures of a connected body.
	Method GetFixtureCount:Int(tmpObj:ftObject)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.GetFixtureCount - body = NULL")
		Local nf:Int=0
		Local tmpFix:b2Fixture = body.GetFixtureList()
		If tmpFix <> Null Then
			nf = nf + 1
			While tmpFix.GetNext() <> Null
				nf = nf + 1
				tmpFix = tmpFix.GetNext()
			Wend
		Endif
		Return nf
	End
	'------------------------------------------
'summery:Returns the postion of the last raycast hit.
	Method GetLastRayCastHit:Float[]()
		Local pos:Float[2]
		pos[0] = 0.0
		pos[1] = 0.0
		Return pos
	End
	'------------------------------------------
'summery:Returns the friction of the fixture with the given index.
	Method GetFriction:Float(tmpObj:ftObject, fIndex:Int = 1)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.GetFriction - body = NULL")
		Local cc:Int = Self.GetFixtureCount(tmpObj)
		If fIndex < 1 Or fIndex > cc Then Error ("~n~nError in file fantomEngine.cftBox2D, Method ftBox2D.GetFriction():~n~nUsed index ("+fIndex+") is out of bounds (1-"+cc+")")
		
		Local nf:Int=0
		Local tmpFix:b2Fixture = body.GetFixtureList()
		If tmpFix <> Null Then
			nf = nf + 1
			If nf = fIndex Then Return tmpFix.GetFriction()
			While tmpFix.GetNext() <> Null
				nf = nf + 1
				If nf = fIndex Then Return tmpFix.GetFriction()
				tmpFix = tmpFix.GetNext()
			Wend
		Endif
		Return 0.0
	End
	'------------------------------------------
'summery:Returns the linear damping of a connected body.
	Method GetLinearDamping:Float(tmpObj:ftObject)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.GetLinearDamping - body = NULL")
		Return body.GetLinearDamping()
	End
	'------------------------------------------
'summery:Returns the linear velocity of a connected body.
	Method GetLinearVelocity:float[](tmpObj:ftObject)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		Local v:Float[2]
		If body = Null Then Error("ftBox2D.GetLinearVelocity - body = NULL")
		Local vel:b2Vec2 = body.GetLinearVelocity()
		v[0] = vel.x
		v[1] = vel.y
		Return v
	End
	'------------------------------------------
#Rem
'summery:Returns the mass data of a connected body.
'It will return an array with the following float values
[list][*]index #0 -> mass
[*]index #1 -> centerX
[*]index #2 -> centerY
[*]index #3 -> I
[/list]
#End
	Method GetMassData:Float[](tmpObj:ftObject)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.GetMassData - body = NULL")
		Local massdata:b2MassData = New b2MassData
		body.GetMassData(massdata)
		Local ret:Float[4]
		ret[0] = massdata.mass
		ret[1] = massdata.center.x
		ret[2] = massdata.center.y
		ret[3] = massdata.I
		Return ret
	End
	'------------------------------------------
'summery:Returns the postion of a connected body.
	Method GetPosition:Float[](tmpObj:ftObject)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		Local p:b2Vec2 = New b2Vec2
		Local pos:Float[2]
		If body = Null Then Error("ftBox2D.GetPosition - body = NULL")
		p = body.GetPosition()
		pos[0] = p.x*m_physScale
		pos[1] = p.y*m_physScale
		Return pos
	End
	'------------------------------------------
'summery:Returns the restitution of the fixture with the given index.
	Method GetRestitution:Float(tmpObj:ftObject, fIndex:Int = 1)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.GetRestitution - body = NULL")
		Local cc:Int = Self.GetFixtureCount(tmpObj)
		If fIndex < 1 Or fIndex > cc Then Error ("~n~nError in file fantomEngine.cftBox2D, Method ftBox2D.GetRestitution():~n~nUsed index ("+fIndex+") is out of bounds (1-"+cc+")")
		
		Local nf:Int=0
		Local tmpFix:b2Fixture = body.GetFixtureList()
		If tmpFix <> Null Then
			nf = nf + 1
			If nf = fIndex Then Return tmpFix.GetRestitution()
			While tmpFix.GetNext() <> Null
				nf = nf + 1
				If nf = fIndex Then Return tmpFix.GetRestitution()
				tmpFix = tmpFix.GetNext()
			Wend
		Endif
		Return 0.0
	End
	'------------------------------------------
'summery:Returns the sensor flag of the fixture with the given index.
	Method GetSensor:bool(tmpObj:ftObject, fIndex:Int = 1)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.GetSensor - body = NULL")
		Local cc:Int = Self.GetFixtureCount(tmpObj)
		If fIndex < 1 Or fIndex > cc Then Error ("~n~nError in file fantomEngine.cftBox2D, Method ftBox2D.GetSensor():~n~nUsed index ("+fIndex+") is out of bounds (1-"+cc+")")
		
		Local nf:Int=0
		Local tmpFix:b2Fixture = body.GetFixtureList()
		If tmpFix <> Null Then
			nf = nf + 1
			If nf = fIndex Then Return tmpFix.IsSensor()
			While tmpFix.GetNext() <> Null
				nf = nf + 1
				If nf = fIndex Then Return tmpFix.IsSensor()
				tmpFix = tmpFix.GetNext()
			Wend
		Endif
		Return False
	End
	'------------------------------------------
'summery:Returns the type of a connected body.
	Method GetType:Int(tmpObj:ftObject)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.GetType - body = NULL")
		Return body.GetType()
	End
	'------------------------------------------
#Rem
'summery:This method initialized the debug drawing of box2D. 
'To actually draw it, use the RenderDebugDraw method.
#End
	Method InitDebugDraw:Void()
        Local dbgDraw :b2DebugDraw = New b2DebugDraw()
        dbgDraw.SetSprite(m_sprite)
        dbgDraw.SetDrawScale(m_physScale*Min(engine.GetScaleX(),engine.GetScaleY()))
        dbgDraw.SetFillAlpha(0.3)
        dbgDraw.SetLineThickness(1.0)
        dbgDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit)'| b2DebugDraw.e_pairBit)
        m_world.SetDebugDraw(dbgDraw)
	End
	'------------------------------------------
'summery:This method creates a new box2D instance and connects it with the given ftEngine
	Method New(eng:ftEngine)
		Self.engine = eng
	End
	'------------------------------------------
'summery:This callback method is called when a collision contact has begun.
	Method OnBeginContact:Void (contact:b2Contact)
	End
	'------------------------------------------
'summery:This callback method is called when a collision contact has ended.
	Method OnEndContact:Void (contact:b2Contact)
	End
	'------------------------------------------
'summery:This callback method is called after the collision has been solved.
	Method OnPostSolve:Void (contact:b2Contact, impulse:b2ContactImpulse)
	End
	'------------------------------------------
'summery:This callback method is called before the collision has been solved.
	Method OnPreSolve:Void (contact:b2Contact, manifold:b2Manifold)
		'Local fixtureA:b2Fixture = contact.GetFixtureA()
		'Local fixtureB:b2Fixture = contact.GetFixtureB()
		'Local bodyA:b2Body = contact.GetFixtureA().GetBody()
		'Local bodyB:b2Body = contact.GetFixtureB().GetBody()
	End
	
	'------------------------------------------
'summery:This callback method is called when a raycast was successful.
	Method OnRayCast:Void (rayFraction:Float, rayVec:b2Vec2, hitNormal:b2Vec2, hitPoint:b2Vec2, nextPoint:b2Vec2, fixture:b2Fixture, obj:ftObject)
	End
	
	'------------------------------------------
#Rem
'summery:Cast a ray and returns TRUE if a shape was hit.
'If a body was hit, the OnRayCast method will be called.
#End
	Method RayCast:Bool(x1:Float, y1: Float, x2:Float, y2: Float)
		Local fixture:b2Fixture = Null
		Local body:b2Body = Null
		Local obj:ftObject = Null
		Local ud:Object = Null
		
		Local p1:b2Vec2 = New b2Vec2()
		Local p2:b2Vec2 = New b2Vec2()
		Local rayVec:b2Vec2 = New b2Vec2()
		Local hitPoint:b2Vec2 = New b2Vec2()
		Local remainingRay:b2Vec2 = New b2Vec2()
		Local projectedOntoNormal:b2Vec2 = New b2Vec2()
		Local nextPoint:b2Vec2 = New b2Vec2()
		Local xdiff:Float
		Local ydiff:Float 
		Local dist:Float
		Local ang:Float
		Local dotfac:Float

        p1.x = x1 / m_physScale
        p1.y = y1 / m_physScale
        p2.x = x2 / m_physScale
        p2.y = y2 / m_physScale
        fixture = m_world.RayCastOne(p1, p2)

        If (fixture<>Null)
            Local input :b2RayCastInput = New b2RayCastInput(p1, p2)
            Local output :b2RayCastOutput = New b2RayCastOutput()
            fixture.RayCast(output, input)

        	rayVec.x = x2
        	rayVec.y = y2
        	
			xdiff = x2 - x1
			ydiff = y2 - y1
		    ang = ATan2( ydiff, xdiff )+90.0
			If ang < 0 Then 
				ang = 360.0 + ang
			Endif
			dist = Sqrt(xdiff * xdiff + ydiff * ydiff) * output.fraction
			hitPoint.x = x1 + Sin(ang) * dist
	    	hitPoint.y = y1 - Cos(ang) * dist
        	
        	
        	remainingRay.x = rayVec.x
        	remainingRay.y = rayVec.y
			remainingRay.x -= hitPoint.x
			remainingRay.y -= hitPoint.y

			projectedOntoNormal.x = output.normal.x
			projectedOntoNormal.y = output.normal.y
			dotfac = remainingRay.x * output.normal.x + remainingRay.y * output.normal.y
			projectedOntoNormal.x *= dotfac
			projectedOntoNormal.y *= dotfac

			nextPoint.x = rayVec.x
			nextPoint.y = rayVec.y
			projectedOntoNormal.x *= 2.0
			projectedOntoNormal.y *= 2.0
			nextPoint.x -= projectedOntoNormal.x
			nextPoint.y -= projectedOntoNormal.y
			
        	body = fixture.GetBody()
        	ud = body.GetUserData()
        	If ud <> Null Then obj = ftObject(ud)
        	
        	Self.OnRayCast(output.fraction, rayVec, output.normal, hitPoint, nextPoint, fixture, obj)
        	
            Return True
        End
		Return False
	End
	'------------------------------------------
'summery:Renders the debug information of the box2D world.
	Method RenderDebugDraw:Void()
		m_world.DrawDebugData()
	End	
	'------------------------------------------
'summery:Resets the mass data of a connected body.
	Method ResetMassData:Void(tmpObj:ftObject)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.ResetMassData - body = NULL")
		body.ResetMassData()
	End
	'------------------------------------------
'summery:Set the active flag of a connected body.
	Method SetActive:Void(tmpObj:ftObject, flag:bool )
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.SetActive - body = NULL")
		body.SetActive(flag)
	End
	'------------------------------------------
'summery:Set the angle of a connected body.
	Method SetAngle:Void(tmpObj:ftObject, bodyAngle:Float, degree:Bool=True)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.SetAngle - body = NULL")
		If degree = True Then bodyAngle = bodyAngle * 0.0174533
		body.SetAngle (bodyAngle)
	End
	'------------------------------------------
'summery:Sets the angular damping of a connected body.
	Method SetAngularDamping:Void(tmpObj:ftObject, damping:Float)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.SetAngularDamping - body = NULL")
		body.SetAngularDamping (damping)
	End
	'------------------------------------------
'summery:Set the angular velocity of a connected body.
	Method SetAngularVelocity:Void(tmpObj:ftObject, velocity:Float, degree:Bool=True)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.SetAngularVelocity - body = NULL")
		If degree = True Then velocity = velocity * 0.0174533
		body.SetAngularVelocity (velocity)
	End
	'------------------------------------------
'summery:Set the awake flag of a connected body.
	Method SetAwake:Void(tmpObj:ftObject, flag:bool )
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.SetAwake - body = NULL")
		body.SetAwake(flag)
	End
	'------------------------------------------
'summery:Sets the bullet flag of a connected body.
	Method SetBullet:Void(tmpObj:ftObject, flag:bool )
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.SetBullet - body = NULL")
		body.SetBullet(flag)
	End
	'------------------------------------------
'summery:Sets the density of the fixture with the given index.
	Method SetDensity:Void(tmpObj:ftObject, density:Float, fIndex:Int = 1)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.SetDensity - body = NULL")
		Local cc:Int = Self.GetFixtureCount(tmpObj)
		If fIndex < 1 Or fIndex > cc Then Error ("~n~nError in file fantomEngine.cftBox2D, Method ftBox2D.SetDensity():~n~nUsed index ("+fIndex+") is out of bounds (1-"+cc+")")
		
		Local nf:Int=0
		Local tmpFix:b2Fixture = body.GetFixtureList()
		If tmpFix <> Null Then
			nf = nf + 1
			If nf = fIndex Then 
				tmpFix.SetDensity(density)
				Return
			Endif
			While tmpFix.GetNext() <> Null
				nf = nf + 1
				If nf = fIndex Then
					tmpFix.SetDensity(density)
					Exit
				Endif
				tmpFix = tmpFix.GetNext()
			Wend
		Endif
	End
	'------------------------------------------
'summery:This method connects it with the given ftEngine
	Method SetEngine(eng:ftEngine)
		Self.engine = eng
	End
	'------------------------------------------
'summery:Sets the filter category bits of the fixture with the given index.
	Method SetFilterCategoryBits:Void(tmpObj:ftObject, categorybits:Int, fIndex:Int = 1)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		Local filterData:b2FilterData
		If body = Null Then Error("ftBox2D.SetFilterCategoryBits - body = NULL")
		Local cc:Int = Self.GetFixtureCount(tmpObj)
		If fIndex < 1 Or fIndex > cc Then Error ("~n~nError in file fantomEngine.cftBox2D, Method ftBox2D.SetFilterCategoryBits():~n~nUsed index ("+fIndex+") is out of bounds (1-"+cc+")")
		
		Local nf:Int=0
		Local tmpFix:b2Fixture = body.GetFixtureList()
		If tmpFix <> Null Then
			nf = nf + 1
			If nf = fIndex Then
				filterData = tmpFix.GetFilterData() 
				filterData.categoryBits = categorybits
				Return
			Endif
			While tmpFix.GetNext() <> Null
				nf = nf + 1
				If nf = fIndex Then
					filterData = tmpFix.GetFilterData() 
					filterData.categoryBits = categorybits
					Exit
				Endif
				tmpFix = tmpFix.GetNext()
			Wend
		Endif
	End
	'------------------------------------------
'summery:Sets the filter group index of the fixture with the given index.
	Method SetFilterGroupIndex:Void(tmpObj:ftObject, groupIndex:Int, fIndex:Int = 1)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		Local filterData:b2FilterData
		If body = Null Then Error("ftBox2D.SetFilterGroupIndex - body = NULL")
		Local cc:Int = Self.GetFixtureCount(tmpObj)
		If fIndex < 1 Or fIndex > cc Then Error ("~n~nError in file fantomEngine.cftBox2D, Method ftBox2D.SetFilterGroupIndex():~n~nUsed index ("+fIndex+") is out of bounds (1-"+cc+")")
		
		Local nf:Int=0
		Local tmpFix:b2Fixture = body.GetFixtureList()
		If tmpFix <> Null Then
			nf = nf + 1
			If nf = fIndex Then 
				filterData = tmpFix.GetFilterData()
				filterData.groupIndex = groupIndex
				Return
			Endif
			While tmpFix.GetNext() <> Null
				nf = nf + 1
				If nf = fIndex Then
					filterData = tmpFix.GetFilterData()
					filterData.groupIndex = groupIndex
					Exit
				Endif
				tmpFix = tmpFix.GetNext()
			Wend
		Endif
	End
	'------------------------------------------
'summery:Sets the filter mask bits of the fixture with the given index.
	Method SetFilterMaskBits:Void(tmpObj:ftObject, maskbits:Int, fIndex:Int = 1)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		Local filterData:b2FilterData
		If body = Null Then Error("ftBox2D.SetFilterMaskBits - body = NULL")
		Local cc:Int = Self.GetFixtureCount(tmpObj)
		If fIndex < 1 Or fIndex > cc Then Error ("~n~nError in file fantomEngine.cftBox2D, Method ftBox2D.SetFilterMaskBits():~n~nUsed index ("+fIndex+") is out of bounds (1-"+cc+")")
		
		Local nf:Int=0
		Local tmpFix:b2Fixture = body.GetFixtureList()
		If tmpFix <> Null Then
			nf = nf + 1
			If nf = fIndex Then 
				filterData = tmpFix.GetFilterData()
				filterData.maskBits = maskbits
				Return
			Endif
			While tmpFix.GetNext() <> Null
				nf = nf + 1
				If nf = fIndex Then
					filterData = tmpFix.GetFilterData()
					filterData.maskBits = maskbits
					Exit
				Endif
				tmpFix = tmpFix.GetNext()
			Wend
		Endif
	End
	'------------------------------------------
'summery:Sets the fixed rotation flag of a connected body.
	Method SetFixedRotation:Void(tmpObj:ftObject, flag:bool )
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.SetFixedRotation - body = NULL")
		body.SetFixedRotation(flag)
	End
	'------------------------------------------
'summery:Sets the friction of the fixture with the given index.
	Method SetFriction:Void(tmpObj:ftObject, friction:Float, fIndex:Int = 1)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.SetFriction - body = NULL")
		Local cc:Int = Self.GetFixtureCount(tmpObj)
		If fIndex < 1 Or fIndex > cc Then Error ("~n~nError in file fantomEngine.cftBox2D, Method ftBox2D.SetFriction():~n~nUsed index ("+fIndex+") is out of bounds (1-"+cc+")")
		
		Local nf:Int=0
		Local tmpFix:b2Fixture = body.GetFixtureList()
		If tmpFix <> Null Then
			nf = nf + 1
			If nf = fIndex Then 
				tmpFix.SetFriction(friction)
				Return
			Endif
			While tmpFix.GetNext() <> Null
				nf = nf + 1
				If nf = fIndex Then
					tmpFix.SetFriction(friction)
					Exit
				Endif
				tmpFix = tmpFix.GetNext()
			Wend
		Endif
	End
	'------------------------------------------
'summery:Sets the gravity of the world.
	Method SetGravity:Void(gravX:Float, gravY:Float)
		Local g:b2Vec2 = New b2Vec2
        If m_world = Null Then Error("ftBox2D.SetGravity - world = NULL")  
		g.x = gravX
		g.y = gravY
        m_world.SetGravity(g)     
	End
	'------------------------------------------
'summery:Sets the linear damping of a connected body.
	Method SetLinearDamping:Void(tmpObj:ftObject, damping:Float)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.SetLinearDamping - body = NULL")
		body.SetLinearDamping (damping)
	End
	'------------------------------------------
'summery:Sets the linear velocity of a connected body.
	Method SetLinearVelocity:Void(tmpObj:ftObject, vx:Float, vy:Float)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		Local v:b2Vec2 = New b2Vec2
		If body = Null Then Error("ftBox2D.SetLinearVelocity - body = NULL")
		v.x = vx
		v.y = vy
		body.SetLinearVelocity (v)
	End
	'------------------------------------------
'summery:Sets the mass data of a connected body.
	Method SetMassData:Void(tmpObj:ftObject, mass:Float, massCenterX:Float, massCenterY:Float, i:Float)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.SetMassData - body = NULL")
		Local massdata:b2MassData = New b2MassData()
		massdata.mass = mass
		massdata.center = New b2Vec2(massCenterX, massCenterY)
		massdata.I = i
		body.ResetMassData()
		body.SetMassData(massdata)
	End
	'------------------------------------------
'summery:Sets the physic scale of the world.
	Method SetPhysicScale:Void(scale:Float = 30.0)
		m_physScale = scale    
	End
	'------------------------------------------
'summery:Sets the position of a connected body and the ftObject itself.
	Method SetPosition:Void(tmpObj:ftObject, xpos:Float, ypos:Float)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		Local p:b2Vec2 = New b2Vec2
		If body = Null Then Error("ftBox2D.SetLinearVelocity - body = NULL")
		p.x = xpos/m_physScale
		p.y = ypos/m_physScale
		body.SetPosition (p)
		tmpObj.SetPos(xpos, ypos)
	End
	'------------------------------------------
'summery:Sets the restitution of the fixture with the given index.
	Method SetRestitution:Void(tmpObj:ftObject, restitution:Float, fIndex:Int = 1)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.SetRestitution - body = NULL")
		Local cc:Int = Self.GetFixtureCount(tmpObj)
		If fIndex < 1 Or fIndex > cc Then Error ("~n~nError in file fantomEngine.cftBox2D, Method ftBox2D.SetRestitution():~n~nUsed index ("+fIndex+") is out of bounds (1-"+cc+")")
		
		Local nf:Int=0
		Local tmpFix:b2Fixture = body.GetFixtureList()
		If tmpFix <> Null Then
			nf = nf + 1
			If nf = fIndex Then 
				tmpFix.SetRestitution(restitution)
				Return
			Endif
			While tmpFix.GetNext() <> Null
				nf = nf + 1
				If nf = fIndex Then
					tmpFix.SetRestitution(restitution)
					Exit
				Endif
				tmpFix = tmpFix.GetNext()
			Wend
		Endif
	End
	'------------------------------------------
'summery:Sets the sensor flag of the fixture with the given index.
	Method SetSensor:Void(tmpObj:ftObject, sensorFlag:Bool, fIndex:Int = 1)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.SetSensor - body = NULL")
		Local cc:Int = Self.GetFixtureCount(tmpObj)
		If fIndex < 1 Or fIndex > cc Then Error ("~n~nError in file fantomEngine.cftBox2D, Method ftBox2D.SetSensor():~n~nUsed index ("+fIndex+") is out of bounds (1-"+cc+")")
		
		Local nf:Int=0
		Local tmpFix:b2Fixture = body.GetFixtureList()
		If tmpFix <> Null Then
			nf = nf + 1
			If nf = fIndex Then 
				tmpFix.SetSensor(sensorFlag)
				Return
			Endif
			While tmpFix.GetNext() <> Null
				nf = nf + 1
				If nf = fIndex Then
					tmpFix.SetSensor(sensorFlag)
					Exit
				Endif
				tmpFix = tmpFix.GetNext()
			Wend
		Endif
	End
	'------------------------------------------
'summery:Sets the sleeping allowed flag of a connected body.
	Method SetSleepingAllowed:Void(tmpObj:ftObject, flag:Bool )
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.SetSleepingAllowed - body = NULL")
		body.SetSleepingAllowed(flag)
	End
	'------------------------------------------
'summery:Sets the type of a connected body.
	Method SetType:Void(tmpObj:ftObject, type:Int)
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.SetType - body = NULL")
		body.SetType (type)
	End
	'------------------------------------------
#Rem
'summery:Updates a ftObject regarding its connected Box2D body. 
'It will update ist position and angle.
#End
	Method UpdateObj:Void(tmpObj:ftObject )
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.UpdateObj - body = NULL")
		
		Local position:b2Vec2 = body.GetPosition()
		tmpObj.SetPos(position.x*m_physScale, position.y*m_physScale)

		Local a:Float = body.GetAngle() / 0.0174533
		tmpObj.SetAngle(a)
	End
	'------------------------------------------
'summery:Updates the angle of a ftObject regarding its connected Box2D body. 
	Method UpdateObjAngle:Void(tmpObj:ftObject )
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.UpdateObjAngle - body = NULL")
		Local a:Float = body.GetAngle() / 0.0174533
		tmpObj.SetAngle(a)
	End
	'------------------------------------------
'summery:Updates the position of a ftObject regarding its connected Box2D body. 
	Method UpdateObjPos:Void(tmpObj:ftObject )
		Local body:b2Body = b2Body(tmpObj.box2DBody)
		If body = Null Then Error("ftBox2D.UpdateObjPos - body = NULL")
		
		Local position:b2Vec2 = body.GetPosition()
		tmpObj.SetPos(position.x*m_physScale, position.y*m_physScale)
	End
	'------------------------------------------
'summery:Updates the physical simulation of the box2D world. 
	Method UpdateWorld:Void(timeStep:Float=1.0/60.0, velocityIterations:Int = 10, positionIterations:Int= 10)
        m_world.TimeStep(timeStep, velocityIterations, positionIterations)
        m_world.ClearForces()
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