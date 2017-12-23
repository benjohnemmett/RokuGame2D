Function physModel(compositor) as object
    return {
        addPhysObj : function(obj) as void
            m.physObjList[m.numPhysObj] = obj
            m.numPhysObj = m.physObjList.count()
        End Function,
        
        createPhysObj : function(x,y,w,h,filepath as string) as object
            if (m.compositor = invalid) then
                ?"Error in physModel::createPhysObj - No Compositor set in physModel."
                return invalid
            end if
            bMap = CreateObject("roBitmap", filepath)
            rRegion = CreateObject("roRegion", bMap, 0, 0, w, h)
            sSprite = m.compositor.NewSprite(x,y, rRegion)
            pPhysObj = physObj(sSprite,bMap)
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
            cp = collisionPair(obj1,obj2,invalid,invalid)
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
        
        updateDisplay : function() as void
            for each o in m.physObjList  
                o.updateDisplay() 
            End for
        end function,
        
        '''''''''''''''''''''''''''''''''''''''''''''''''        '''''''''''''''''''''''''''''''''''''''''''''''''
        checkOverlaps : function() as void
            if(m.numCollisionPairs = 0) then
                return
            end if
            
            for each cp in m.collisionPairList
            
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
                        checkOverlapGroupObj(cp.obj1, cp.obj2, cp.overlapCallback, m)
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
        
        addOverlapToOpenList : function(os) as void
            m.openOverlaps.push(os)
        end function,
        
        '''''''''''''''''''''''''''''''''''''''''''''''''
        
        numPhysObj : 0,
        physObjList : [],
        numCollisionPairs : 0,
        collisionPairList : [], 
        openOverlaps: [], 'Array of all the objects with overlaps that need to be resolved. Set during checkOverlaps(), resolved during runCollisions()
        compositor : compositor
    
    }
End Function '''' End physModel()

'''''' A physical object
' Implements kinematicObject Interface
Function physObj(sprite,bmap) as Object
    return{
        
        setGravity: function(gx, gy) as void 'TODO consider separating the constant gravity value from the dynamic ax & ay
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
        
        '' From displayable interface
        updateDisplay : function() as void
            m.sprite.MoveTo(m.x, m.y)
        end function,
        
        isPhysObjGroup : function() as boolean
            return false
        end function,
        
        setSpriteFrame : function(frame) as void
            m.sprite.setRegion(CreateObject("roRegion", m.bmap, m.size_x*frame, 0, m.size_x, m.size_y))            
        end function,
        
        clear : function() as void
            m.sprite.Remove()
        end function,
        
    sprite: sprite,
    bmap: bmap,
    x: sprite.getX(),
    y: sprite.getY(),
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
    wallEnable: 0.0, ' -1 no walls, 0 inelastic walls, 1 perfectly elastic walls, (0 to 1 is in between)
    'wall_x_min: 10,
    'wall_y_min: 10,
    'wall_x_max: 1280,
    'wall_y_max: 720,
    size_x: invalid, 
    size_y: invalid,
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
        
        createPhysObj : function(x,y,w,h,filepath as string) as object
            if (m.physModel = invalid) then
                ?"Error in physModel::physObjGroup::createPhysObj - No physModel set in physObjGroup."
                return invalid
            else if(m.physModel.compositor = invalid) then
                ?"Error in physModel::physObjGroup::createPhysObj - No compositor set in physObjGroup.physModel"
                return invalid
            end if
            bMap = CreateObject("roBitmap", filepath)
            rRegion = CreateObject("roRegion", bMap, 0, 0, w, h)
            sSprite = m.physModel.compositor.NewSprite(x,y, rRegion)
            pPhysObj = physObj(sSprite,bMap)
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
                    o.clear()
                    m.physObjList.delete(i) ' remove object
                else
                    o.runKinematics(dt) 'Run Kinematics
                    i += 1
                end if
                
            end while
        end function,
        
        ''From displayable interface
        updateDisplay : function() as void
            for each o in m.physObjList
                o.updateDisplay()
            end for
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
            
            os  = m.overlapState
            ' http://ericleong.me/research/circle-circle/#static-circle-collision
            Nx = m.x - os.obj.x
            Ny = m.y - os.obj.y
            N = sqr(Nx*Nx + Ny*Ny)
            Nx /= N ' normalized normal vector x
            Ny /= N ' normalized normal vector y
            
            p = ((os.obj.vx*Nx + os.obj.vy*Ny)  - (m.vx*Nx + m.vy*Ny)) ' Assuming mass of 1
            
            m.vx += p*Nx
            m.vy += p*Ny
            
            'Reset
            m.overlapState = invalid
            
        end function,
        
        '' From the collidable interface
        getBoundaryDefinition : function() as object
            return boundaryCircular(m.x, m.y, m.radius)         
        end function,
        
        '' From displayable interface
        updateDisplay : function() as void
            for each e in m.elementArray
                e.updateDisplay()
            end for
        end function,
        
        createElement : function(sprite, angle, radius) as object
            el = physObjFixedRadialElement(sprite, angle, radius)
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
        'wall_x_min: 10,
        'wall_y_min: 10,
        'wall_x_max: 1280,
        'wall_y_max: 720,
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

function physObjFixedRadialElement(sprite, angle, radius) as object
    return {
        sprite : sprite,
        angle : angle,
        radius : radius,
        visible : true,
        x: invalid, ' Should not me modified direclty
        y: invalid,
        region: sprite.getRegion(),
        size_x: sprite.getRegion().getWidth(),
        size_y: sprite.getRegion().getHeight(),
        hx : sprite.getRegion().getWidth()/2,
        hy : sprite.getRegion().getHeight()/2,
        
        updatePosition : function(objX, objY, objAngle) as void
            'get absolute angle
            absAngle = boundAngle(m.angle + objAngle)

            'calculate x & y of element
             m.x = objx + m.radius*cos(absAngle)
             m.y = objy + m.radius*sin(absAngle)
            
        end function,
        
        updateDisplay : function() as void
            m.sprite.MoveTo(m.x - m.hx + 0.5, m.y -m.hy + 0.5)
        end function,
        
        clear : function() as void
            m.sprite.remove()
        end function
    }

end function ''' end physObjFixedRadialElement()
