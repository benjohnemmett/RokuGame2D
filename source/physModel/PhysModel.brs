Function physModel() as object
    return {
        addPhysObj : function(obj) as void
            m.physObjList[m.numPhysObj] = obj
            m.numPhysObj = m.physObjList.count()
        End Function,

        createPhysObj : function(x,y,w,h) as object
            'if (m.compositor = invalid) then
            ''    ?"Error in physModel::createPhysObj - No Compositor set in physModel."
            ''    return invalid
            'end if
            'bMap = CreateObject("roBitmap", filepath)
            'rRegion = CreateObject("roRegion", bMap, 0, 0, w, h)
            'sSprite = m.compositor.NewSprite(x,y, rRegion)
            pPhysObj = physObj()
            pPhysObj.size_x = w
            pPhysObj.size_y = h
            pPhysObj.wallEnable = Invalid

            m.addPhysObj(pPhysObj)

            return pPhysObj

        End Function,

        createPhysObjGroup : function() as object
            pgGroup = physObjGroup()
            pgGroup.physModel = m

            m.addPhysObj(pgGroup)

            return pgGroup

        end function,

        '''''''''''''''''''''''''''''''''''''''''''''''''
        addCollisionPair : function(cp) as void
            m.collisionPairList.Push(cp)
            m.numCollisionPairs = m.collisionPairList.Count()
        End Function,

        '''''''''''''''''''''''''''''''''''''''''''''''''
        createCollisionPair : function(obj1,obj2) as object
            cp = collisionPair(obj1,obj2, noCallback ,noCallback)
            m.addCollisionpair(cp)
            return cp
        end function,

        '''''''''''''''''''''''''''''''''''''''''''''''''
        runPhysics : function(dt) as void
            m.runKinematics(m.physObjList, dt)
            m.checkOverlaps()
            m.resolveCollisions(m.openOverlaps)
        End Function,

        '''''''''''''''''''''''''''''''''''''''''''''''''
        runKinematics : function(objList, dt) as void
            for each o in objList
                o.runKinematics(dt)
            End for
        End Function,

''        updateDisplay : function() as void
''            for each o in m.physObjList
''                o.updateDisplay()
''            End for
''        end function,

        '''''''''''''''''''''''''''''''''''''''''''''''''        '''''''''''''''''''''''''''''''''''''''''''''''''
        checkOverlaps : function() as void
            if(m.numCollisionPairs = 0) then
                return
            end if

            for each cp in m.collisionPairList

               ' ?cp.obj1
                '?cp.obj2
                if cp.obj1.isPhysObjGroup() then
                    if cp.obj2.isPhysObjGroup() then
                        ' Both are groups
                        checkOverlapGroupGroup(cp.obj1, cp.obj2, cp.overlapCallback, m)' TODO Not a big fan of this double function call
                    else
                        ' obj1 group, obj2 single
                        checkOverlapGroupObj(cp.obj1, cp.obj2, cp.overlapCallback, m)
                    endif
                else ' Obj1 is a single object
                    if cp.obj2.isPhysObjGroup() then
                        'obj1 single, obj2 group
                        checkOverlapObjGroup(cp.obj1, cp.obj2, cp.overlapCallback, m)
                    else
                        ' both single
                        checkOverlap(cp.obj1, cp.obj2, cp.overlapCallback, m)
                    endif
                end if
            end for

        End Function,

        'Calls resolveCollision on each object with an open overlap
        resolveCollisions : function(openOverlaps) as void
            for each o in m.openOverlaps
                '?"resolving collision for ";o

                if(o.collisionCallback <> invalid) then
                    stat = o.collisionCallback(obj1,obj2)
                    if (stat <> 0) AND (stat <> invalid) then
                        return
                    end if
                end if

                o.resolveCollision()
            end for
            m.openOverlaps.clear()
        end function,

        ' Add object which is overlapping another objects to the open list
        addOverlapToOpenList : function(os) as void
            m.openOverlaps.push(os)
        end function,

        '''''''''''''''''''''''''''''''''''''''''''''''''

        numPhysObj : 0,
        physObjList : [],
        numCollisionPairs : 0,
        collisionPairList : [],
        openOverlaps: [], 'Array of all the objects with overlaps that need to be resolved. Set during checkOverlaps(), resolved during runCollisions()
''        compositor : compositor

    }
End Function '''' End physModel()

function noCallback(obj1,obj2) as integer
    return 0
end function

'''''' A physical object
' Implements kinematicObject Interface
Function physObj() as Object
    return{

        setGravity: function(gx, gy) as void 'TODO consider separating the constant gravity value from the dynamic ax & ay
            m.gx = gx
            m.gy = gy
        end function,

        runKinematics: function(dt as float) as void

            if (m.isMovable = false) then
              return
            end if

            'https://gamedev.stackexchange.com/questions/15708/how-can-i-implement-gravity
            m.x  = m.x + dt * (m.vx  + dt * (m.ax + m.gx)/2)
            m.y  = m.y + dt * (m.vy  + dt * (m.ay + m.gy)/2)

            'Update Velocity
            m.vx = m.vx + (m.ax + m.gx) * dt
            m.vy = m.vy + (m.ay + m.gy) * dt

            ' Apply Max velocities
            m.vx = sgn(m.vx)*minFloat(abs(m.vx),m.maxVx)
            m.vy = sgn(m.vy)*minFloat(abs(m.vy),m.maxVy)

            if(m.wallEnable <> invalid)

                if(m.wallEnable < 0) then

                    if(m.y > (m.maxY - m.size_y))
                        m.y = (m.y - m.maxY) + m.minY
                    else if (m.y < m.minY) then
                        m.y = (m.y - m.minY) + m.maxY
                    end if

                    if(m.x > (m.maxX - m.size_x))
                        m.x = (m.x - m.maxX) + m.minX
                    else if (m.x < m.minx) then
                        m.x = (m.x - m.minX) + m.maxX
                    end if

                else ' Collide with walls

                    If((m.y > (m.maxY - m.size_y)) OR (m.y < m.minY))
                        m.y = MaxFloat(m.minY + 1, MinFloat(m.maxY - m.size_y - 1, m.y)) 'Make sure that sheep is above bottom limit
                        m.vy = -m.wallEnable*m.vy
                    End If

                    If((m.x > (m.maxX - m.size_x)) OR (m.x < m.minX ))
                        m.x = MaxFloat(m.minX + 1, MinFloat(m.maxX - m.size_x - 1, m.x)) 'Make sure that sheep is above bottom limit
                        m.vx = -m.wallEnable*m.vx
                    End If

                end if

            end if

        end function,

        resolveCollision : function() as void

            if(m.overlapState = invalid) then
                return
            end if

               os = m.overlapState

                obj2 = os.obj 'Get other object in collision

                'Magnitudes of overlap
                xx1 = Abs(m.x - (obj2.x + obj2.size_x))
                xx2 = Abs(obj2.x - (m.x + m.size_x))
                yy1 = Abs(m.y - (obj2.y + obj2.size_y))
                yy2 = Abs(obj2.y - (m.y + m.size_y))

                minX = MinFloat(xx1,xx2)
                minY = MinFloat(yy1,yy2)

                ' Check that objects are converging, and get dominant direction
                conv_x = (m.x - obj2.x) * (m.vx - obj2.vx)
                conv_y = (m.y - obj2.y) * (m.vy - obj2.vy)

                if((conv_x < 0) AND (conv_y < 0)) then 'Both directions converging
                    if(minX <= minY) then
                        isXDirection = true ' x dominant
                    else
                        isXDirection = false ' y dominant
                    end if
                else if(conv_x < 0) then 'Just x converging
                    isXDirection = true ' x dominant
                else if(conv_y < 0) 'Just y converging
                    isXDirection = false ' x dominant
                end if

                ' Resolve collision
                if (isXDirection = true) then

                    if (m.isMovable AND obj2.isMovable) then
                        'Equal & opposite recoil
            '                ?" - X both movable"
                        s = (Abs(m.vx) + Abs(obj2.vx))/(m.collisionRecoil + obj2.collisionRecoil)

                        m.vx = -sgn(m.vx)*s*m.collisionRecoil 'Bounce back
                        'obj2.vx = -sgn(obj2.vx)*s*obj2.collisionRecoil
                    else if (m.isMovable AND (obj2.isMovable = false)) then
                        '?" - X obj1 movable"
                        if(minX = xx1) then ' move object 1 back so it doesn't sink into immovable object 2
                            ' | obj2 |<-| obj1 |
                            m.x = obj2.x + obj2.size_x
                            ' Bounce back if elasticity is enough, otherwise take on the x velocity of the collided object
                            bounceVx0 = -m.vx*m.collisionRecoil
                            ' Remove extra acceleration from traveling through obj2
                            '             v0 +   ~time * acceleration
                            if(bounceVx0 = 0) then
                                bounceVx = bounceVx0
                            else
                                bounceVx = bounceVx0 + abs(minX/bounceVx0)*(m.ax + m.gx)
                            end if
                            m.vx = maxFloat(obj2.vx,bounceVx)

                        else
                            ' | obj1 |->| obj2 |
                            m.x = obj2.x - m.size_x
                            bounceVx0 = -m.vx*m.collisionRecoil
                            if(bounceVx0 = 0) then
                                bounceVx = bounceVx0
                            else
                                bounceVx = bounceVx0 + abs(minX/bounceVx0)*(m.ax + m.gx)
                            end if
                            m.vx = minFloat(obj2.vx,bounceVx)

                        end if
                    else if ((m.isMovable = false) AND obj2.isMovable) then
                        '?" - X obj2 movable"
                        if(minX = xx1) then ' move object 1 back so it doesn't sink into immovable object 2
                            ' | obj2 |->| obj1 |
                            'obj2.x = m.x - obj2.size_x
                            bounceVx0 = -obj2.vx*obj2.collisionRecoil
                            if(bounceVx0 = 0) then
                                bounceVx = bounceVx0
                            else
                                bounceVx = bounceVx0 + abs(minX/bounceVx0)*(obj2.ax + obj2.gx)
                            end if
                            'obj2.vx = minFloat(m.vx,bounceVx)
                        else
                            ' | obj1 |<-| obj2 |
                            'obj2.x = m.x + m.size_x
                            bounceVx0 = -obj2.vx*obj2.collisionRecoil
                            if(bounceVx0 = 0) then
                                bounceVx = bounceVx0
                            else
                                bounceVx = bounceVx0 + abs(minX/bounceVx0)*(obj2.ax + obj2.gx)
                            end if
                            'obj2.vx = maxFloat(m.vx,bounceVx)
                        end if
                    end if
                else ' Y dominant
                    if (m.isMovable AND obj2.isMovable) then
                        'Equal & opposite recoil
                        'TODO this is  wrong
            '                ?" - Y both movable"
                        s = (Abs(m.vy) + Abs(obj2.vy))/(m.collisionRecoil + obj2.collisionRecoil)
                        m.vy = -sgn(m.vy)*s*m.collisionRecoil 'Bounce back
                        obj2.vy = -sgn(obj2.vy)*s*obj2.collisionRecoil
                    else if (m.isMovable AND (obj2.isMovable = false)) then
            '                ?" - Y obj1 movable"
                        if(minY = yy1) then
                            '_
                            'obj2
                            '_
                            'obj1 ^
                            '_
                            m.y = obj2.y + obj2.size_y
                            bounceVy0 = -m.vy*m.collisionRecoil
                            if(bounceVy0 = 0.0) then
                                bounceVy = bounceVy0
                            else
                                bounceVy = bounceVy0 + abs(minY/bounceVy0)*(m.ay + m.gy)
                            end if
                            m.vy = maxFloat(obj2.vy,bounceVy)
                        else
                            '_
                            'obj1 V
                            '_
                            'obj2
                            '_
                            m.y = obj2.y - m.size_y
                            bounceVy0 = -m.vy*m.collisionRecoil
                            if(bounceVy0 = 0.0) then
                                bounceVy = bounceVy0
                            else
                                bounceVy = bounceVy0 + abs(minY/bounceVy0)*(m.ay + m.gy)
                            end if
                            m.vy = minFloat(obj2.vy,bounceVy)
                        end if
                    else if ((m.isMovable = false) AND obj2.isMovable) then
            '                ?" - Y obj1 movable"
                        if(minY = yy1) then
                            '_
                            'obj2 V
                            '_
                            'obj1
                            '_
                            'obj2.y = m.y - obj2.size_y
                            bounceVy0 = -obj2.vy*obj2.collisionRecoil
                            if(bounceVy0 = 0.0) then
                                bounceVy = bounceVy0
                            else
                                bounceVy = bounceVy0 + abs(minY/bounceVy0)*(obj2.ay + obj2.gy)
                            end if
                            'obj2.vy = minFloat(m.vy,bounceVy)
                        else
                            '_
                            'obj1
                            '_
                            'obj2 ^
                            '_
                            'obj2.y = m.y + m.size_y
                            bounceVy0 = -obj2.vy*obj2.collisionRecoil
                            if(bounceVy0 = 0.0) then
                                bounceVy = bounceVy0
                            else
                                bounceVy = bounceVy0 + abs(minY/bounceVy0)*(obj2.ay + obj2.gy)
                            end if
                            'obj2.vy = maxFloat(m.vy,bounceVy)
                        end if
                    end if
                end if

                m.overlapState = invalid ' Set back to invalid after resolution

        end function,

        '' From the collidable interface
        getBoundaryDefinition : function() as object
            '?"BoundsDef call ";m
            return boundaryAABB(m.x, m.y, m.size_x, m.size_y)
        end function,

        isPhysObjGroup : function() as boolean
            return false
        end function,

        vx: 0.0,
        vy: 0.0,
        ax: 0.0,
        ay: 0.0,
        gx: 0.0,
        gy: 0.0,
        minX: 0.0,
        maxX: invalid,
        minY: 0.0,
        maxY: invalid,
        maxVx: 1000,    'Velocity magnitude which cannot be exceeded
        maxVy: 1000,
        zeroVx: 1.0,     'Velocity magnitude under which, velocity is rounded to 0.0
        zeroVy: 1.0,
        wallEnable: invalid, ' -1 no walls, 0 inelastic walls, 1 perfectly elastic walls, (0 to 1 is in between)
        isMovable: false, 'Option to consider this object movable in the context of collisions (i.e. is not massive/fixed in place compared to other objects)
        collisionRecoil: 0.5, 'Amount of "bounce" #TODO verify correct terminology here
        overlapState: invalid, 'Overlapping state to hold the overlap of greatest area
        ttl : invalid ' Default to infinite ttl (invalid)
    }
End Function'''' End physObj()

' Object to create a group of Physics objects
'' Implements kinematicObject Interface
Function physObjGroup() as Object
    return {
        addPhysObj : function(obj)
            m.physObjList.push(obj)
            m.numPhysObj  = m.physObjList.count()
        End Function,

        removePhysObj : function(obj) as boolean

            for i = 0 to m.physObjList.count()
                if(m.physObjList[i] = obj) then
                    m.physObjList.Delete(i)
                    exit for
                end if

            end for

        end function,

        createPhysObj : function(x,y,w,h) as object
            if (m.physModel = invalid) then
                ?"Error in physModel::physObjGroup::createPhysObj - No physModel set in physObjGroup."
                return invalid
            end if

            pPhysObj = physObj(x,y)
            pPhysObj.size_x = w
            pPhysObj.size_y = h

            m.addPhysObj(pPhysObj)

            return pPhysObj

        End Function,

        '' From kinematic interface
        runKinematics : function(dt) as void
            i = 0
            while i < m.physObjList.count()
                o = m.physObjList[i]
                del = false
                if(o.ttl <> invalid) then
                    o.ttl -= dt
                    if(o.ttl <= 0) then
                        del = true
                    end if
                end if

                if del = true then
                    if o.DoesExist("dyingWish") then
                      o.dyingWish()
                    end if
                    o.clear()
                    m.physObjList.delete(i) ' remove object
                else
                    o.runKinematics(dt) 'Run Kinematics
                    i += 1
                end if

            end while
        end function,

        isPhysObjGroup : Function() as boolean 'TODO I don't think this is used
            return true
        End Function,

        numPhysObj : 0,
        physObjList : [],
        enableBody : false, 'TODO I don't think this is used
        physModel : invalid 'TODO I don't think this is used
    }
End Function '''' End physObjGroup()


''' Implements kinematic Interface and displayable interface
function collectiveRotationalPhysObj(x, y, radius, angle) as object
    return {

        setGravity: function(gx, gy) as void
            m.gx = gx
            m.gy = gy
        end function,

        runKinematics: function(dt as float) as void

            'https://gamedev.stackexchange.com/questions/15708/how-can-i-implement-gravity
            m.x  = m.x + dt * (m.vx  + dt * (m.ax + m.gx)/2)
            m.y  = m.y + dt * (m.vy  + dt * (m.ay + m.gy)/2)

            'Update Velocity
            m.vx = m.vx + (m.ax + m.gx) * dt
            m.vy = m.vy + (m.ay + m.gy) * dt

            ' Apply Max velocities
            m.vx = sgn(m.vx)*minFloat(abs(m.vx),m.maxVx)
            m.vy = sgn(m.vy)*minFloat(abs(m.vy),m.maxVy)

            if(m.wallEnable <> invalid)

                if(m.wallEnable < 0) then 'Wrap around

                    if(m.y > (m.maxY))
                        m.y = (m.y - m.maxY) + m.minY
                    else if (m.y < m.minY) then
                        m.y = (m.y - m.minY) + m.maxY
                    end if

                    if(m.x > (m.maxX))
                        m.x = (m.x - m.maxX) + m.minX
                    else if (m.x < m.minx) then
                        m.x = (m.x - m.minX) + m.maxX
                    end if

                else ' Collide with walls

                    if((m.y > (m.maxY - m.size_y)) OR (m.y < m.minY))
                        m.y = MaxFloat(m.minY + 1, MinFloat(m.maxY - m.size_y - 1, m.y)) 'Make sure that sheep is above bottom limit
                        m.vy = -m.wallEnable*m.vy
                    end If

                    if((m.x > (m.maxX - m.size_x)) OR (m.x < m.minX ))
                        m.x = MaxFloat(m.minX + 1, MinFloat(m.maxX - m.size_x - 1, m.x)) 'Make sure that sheep is above bottom limit
                        m.vx = -m.wallEnable*m.vx
                    end If
                end if
            end if

            ' Apply angular velocity
            m.angle += (m.av*dt)

            ' Updated each element's position
            for each e in m.elementArray
                e.updatePosition(m.x, m.y, m.angle)
            end for

        end function,

        resolveCollision : function() as void

            if(m.overlapState = invalid) then
                return
            end if

            ' If this object is immovable then we are done here'
            if (m.isMovable = false) then
              m.overlapState = invalid
              return
            end if

            os  = m.overlapState

            obj2 = os.obj
            bd = obj2.getBoundaryDefinition()

            if(bd.type = "Circular") then
              ' http://ericleong.me/research/circle-circle/#static-circle-collision
              Nx = m.x - os.obj.x
              Ny = m.y - os.obj.y
              N = sqr(Nx*Nx + Ny*Ny)
              Nx /= N ' normalized normal vector x
              Ny /= N ' normalized normal vector y

              p = ((os.obj.vx*Nx + os.obj.vy*Ny)  - (m.vx*Nx + m.vy*Ny)) ' Assuming mass of 1

              m.vx += p*Nx
              m.vy += p*Ny

            else if (bd.type = "AABB") then
              'Reflect off of box
              ?"Circular object hit AABB!"

              ' TODO, move this to overlap check & flag diminant direction of overlap
              'Magnitudes of overlap
              xx1 = Abs((m.x - m.radius) - (obj2.x + obj2.size_x))
              xx2 = Abs(obj2.x - (m.x + m.radius))
              yy1 = Abs((m.y - m.radius) - (obj2.y + obj2.size_y))
              yy2 = Abs(obj2.y - (m.y + m.radius)) '' DB expect this to be smallest

              minX = MinFloat(xx1,xx2)
              minY = MinFloat(yy1,yy2) '' DB Expect yy2 value here

              ' Check that objects are converging, and get dominant direction
              conv_x = ((m.x - m.radius) - obj2.x) * (m.vx - obj2.vx) '' DB Expect positive. (L-S) * (L-0) = P*P = P
              conv_y = ((m.y - m.radius) - obj2.y) * (m.vy - obj2.vy) ''DB expect  (S-L)* (P-0) = N*P = N

              if(conv_x < 0 ) OR (conv_y < 0) then ' Is converging, otherwise let it go'

                if((conv_x < 0) AND (conv_y < 0)) then 'Both directions converging
                    if(minX <= minY) then
                        isXDirection = true ' x dominant
                    else
                        isXDirection = false ' y dominant
                    end if
                else if(conv_x < 0) then 'Just x converging
                    isXDirection = true ' x dominant
                else if(conv_y < 0) 'Just y converging
                    isXDirection = false ' x dominant
                end if

                ' TODO factor in energy transfer to other object'
                if(isXDirection) then
                  m.vx = -(m.vx * m.collisionRecoil)
                else
                  m.vy = -(m.vy * m.collisionRecoil)
                end if

              end if 'is converging


            else
              ?"Warning: collectiveRotationalPhysObj resolveCollision with ";bd.type;" not supported."
            end if

            'Reset
            m.overlapState = invalid

        end function,

        '' From the collidable interface
        getBoundaryDefinition : function() as object
            return boundaryCircular(m.x, m.y, m.radius)
        end function,

        createElement : function(angle, radius) as object
            el = physObjFixedRadialElement(angle, radius)
            m.addElement(el)
        end function,

        addElement : function(element) as void
            m.elementArray.Push(element)
            element.updatePosition(m.x, m.y, m.angle)
        end function,

        clear : function() as void
            for each e in m.elementArray
                e.clear()   'Clear each element
            end for
            m.elementArray.Clear() 'CLear array
        end function,

        isPhysObjGroup : function() as boolean
            return false
        end function,

        angle: angle,
        av: 0,
        x: x,
        y: y,
        vx: 0.0,
        vy: 0.0,
        ax: 0.0,
        ay: 0.0,
        gx: 0.0,
        gy: 0.0,
        minX: 0.0,
        maxX: invalid,
        minY: 0.0,
        maxY: invalid,
        maxVx: 1000,    'Velocity magnitude which cannot be exceeded
        maxVy: 1000,
        maxAv: 100*pi(), 'default max 50 RPS
        zeroVx: 1.0,     'Velocity magnitude under which, velocity is rounded to 0.0
        zeroVy: 1.0,
        wallEnable: 0.0, ' -1 no walls, 0 inelastic walls, 1 perfectly elastic walls, (0 to 1 is in between)
        size_x: invalid,
        size_y: invalid,
        radius : radius
        isMovable: true, 'Option to consider this object movable in the context of collisions (i.e. is not massive/fixed in place compared to other objects)
        collisionRecoil : 0.5, 'Amount of "bounce" #TODO verify correct terminology here
        overlapState : invalid, 'Overlapping state to hold the overlap of greatest area
        elementArray : [],
        ttl : invalid ' Default to infinite ttl (invalid)
    }

end function '''' end collectiveRotationalPhysObj

function physObjFixedRadialElement(angle, radius) as object
    return {
        angle : angle,
        radius : radius,
        visible : true,
        x: invalid, ' Should not me modified direclty
        y: invalid,
        size_x: 2*radius,
        size_y: 2*radius,
        hx : radius,
        hy : radius,

        updatePosition : function(objX, objY, objAngle) as void
            'get absolute angle
            absAngle = boundAngle(m.angle + objAngle)

            'calculate x & y of element
             m.x = objx + m.radius*cos(absAngle)
             m.y = objy + m.radius*sin(absAngle)

        end function,
    }

end function ''' end physObjFixedRadialElement()



' A collidable object
'  Not movable or displayable on it's own
' Good for an invisible box defining a goal to be reached or an invisible boundary.'
'
' NOTE: Use the setBox() method to change the size after creation. If size/location parameters are updated directory, the boundary definition will not match.
function fixedBoxCollider(x,y,w,h) as object
  return {
    x: x,
    y: y,
    size_x: w,
    size_y: h,
    vx : 0, ' To comply with collidable interface'
    vy : 0, ' To comply with collidable interface
    isMovable: false,
    boundaryDefinition: boundaryAABB(x, y, w, h),
    isPhysObjGroup: function()
      return false
    end function,

  '' From the collidable interface
  ' Note that '
  getBoundaryDefinition : function() as object
      return m.boundaryDefinition
  end function,

  setBox : function(x,y,w,h)
    m.x = x
    m.y = y
    m.size_x = w
    m.size_y = h
    m.boundaryDefinition = boundaryAABB(x, y, w, h)
  end function,

  runKinematics : function(dt) ' TODO This is called when the collider is part of a phys obj group. Find a way to not need this...'
  'Nothing to do here'
  end function,

  }

end Function
