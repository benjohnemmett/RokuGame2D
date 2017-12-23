''''' Class for holding an object associated with an overlapping area
' obj -> the object overlapping
' area -> the amount of area overlapping
' xDirection -> boolean indicating that x is the dominant direction of the collision
' callback -> callback function to call when resolving the collision
Function overlapState(_obj, _area, _callback) as object
    return {
        obj : _obj,
        area : _area,
        cb : _callback
    }
end function

' Object to hold 
Function collisionPair(o1, o2, olCB, colCB) as object
    return {
        obj1 : o1,
        obj2 : o2,
        overlapCallback : olCB,
        collisionCallback : colCB
    }
End Function

' The first step in collision running
'   Check for overlap, if it exists and the callback returns 0 or invalid then check for object of greatest overlap and store it.
function checkOverlap(obj1, obj2, cb, pm) as void
    ' looking only at obj1, if it is not movable then no need to resolve a collision
    
    b1 = obj1.getBoundaryDefinition()
    b2 = obj2.getBoundaryDefinition()
    
    if (b1.type = "Circular") and (b2.type = "Circular") then
        checkOverlapCircular(obj1, obj2, cb, pm)
    else
        ?"Error: checkOverlap for ";b1.type;" and ";b2.type;" not supported."
        return
    end if
    
end function

function checkOverlapCircular(obj1, obj2, cb, pm) as void
    
    d = sqr(pow(obj1.x - obj2.x,2) + pow(obj1.y - obj2.y,2))
    
    'Check overlap
    if(d >= (obj1.radius + obj2.radius))
        return
    end if
    
    ' Call collision callback function
    '  If callback returns 0 or invalid then continue with collisions as usual.
    '  If callback returns non-zero value then abort normal collisions
    if(cb <> invalid) then
        stat = cb(obj1,obj2)
        if (stat <> 0) AND (stat <> invalid) then
            return
        end if
    end if
    
    r1 = obj1.radius
    r2 = obj2.radius
    
    area = (1/d)*sqr( (-d + r1 - r2) * (-d + r1 - r2) * (-d + r1 + r2) * (d + r1 + r2) )
    
    'add overlap state to normal openOverlaps
    if(obj1.isMovable) then ' TODO Change this to inv Mass later
        if(obj1.overlapState = invalid):
            obj1.overlapState = overlapState(obj2, area, cb)
            pm.addOverlapToOpenList(obj1)
        else if(area > obj1.overlapState.area):
            obj1.overlapState = overlapState(obj2, area, cb)
        end if
    end if
    
    if(obj2.isMovable) then ' TODO Change this to inv Mass later
        if(obj2.overlapState = invalid):
            obj2.overlapState = overlapState(obj1, area, cb)
            pm.addOverlapToOpenList(obj2)
        else if(area > obj2.overlapState.area): 'Replace previous overlap if this one is bigger
            obj2.overlapState = overlapState(obj1, area, cb)
        end if
    end if
    
end function

function checkOverlapGroupObj(group, obj, cb, pm) as void
    for each o in group.physObjList
        checkOverlap(o, obj, cb, pm)
    end for
end function

function checkOverlapObjGroup(obj, group, cb, pm) as void
    for each o in group.physObjList
        checkOverlap(obj, o, cb, pm)
    end for
end function

function checkOverlapGroupGroup(group1, group2, cb, pm) as void
    for each o in group1.physObjList
        checkOverlapObjGroup(o, group2 , cb, pm)
    end for
end function

'TODO pull this into the physObj class
'Checks & resolves collision if necessary
function resolveCollision(obj1) as void

    if (obj1.overlapState <> invalid) then
       
       os = obj1.overlapState
        ' Call collision callback function
        '  If callback returns 0 or invalid then continue with collisions as usual.
        '  If callback returns non-zero value then abort normal collisions
        if(os.cb <> invalid) then
            stat = os.cb(obj1,obj2)
            if (stat <> 0) AND (stat <> invalid) then
            
                obj1.overlapState = invalid ' Set back to invalid after resolution
                return
            end if
        end if
        
        obj2 = os.obj 'Get other object in collision
        
        'Magnitudes of overlap
        xx1 = Abs(obj1.x - (obj2.x + obj2.size_x))
        xx2 = Abs(obj2.x - (obj1.x + obj1.size_x))
        yy1 = Abs(obj1.y - (obj2.y + obj2.size_y))
        yy2 = Abs(obj2.y - (obj1.y + obj1.size_y))
        
        minX = MinFloat(xx1,xx2)
        minY = MinFloat(yy1,yy2)
        
        ' Resolve collision
        if (os.xDir = true) then
        
            if (obj1.isMovable AND obj2.isMovable) then
                'Equal & opposite recoil
    '                ?" - X both movable"
                s = (Abs(obj1.vx) + Abs(obj2.vx))/(obj1.collisionRecoil + obj2.collisionRecoil)
                
                obj1.vx = -sgn(obj1.vx)*s*obj1.collisionRecoil 'Bounce back 
                obj2.vx = -sgn(obj2.vx)*s*obj2.collisionRecoil
            else if (obj1.isMovable AND (obj2.isMovable = false)) then
                '?" - X obj1 movable"
                if(minX = xx1) then ' move object 1 back so it doesn't sink into immovable object 2
                    ' | obj2 |<-| obj1 |
                    obj1.x = obj2.x + obj2.size_x
                    ' Bounce back if elasticity is enough, otherwise take on the x velocity of the collided object
                    bounceVx0 = -obj1.vx*obj1.collisionRecoil
                    ' Remove extra acceleration from traveling through obj2
                    '             v0 +   ~time * acceleration
                    if(bounceVx0 = 0) then
                        bounceVx = bounceVx0
                    else
                        bounceVx = bounceVx0 + abs(minX/bounceVx0)*(obj1.ax + obj1.gx)
                    end if
                    obj1.vx = maxFloat(obj2.vx,bounceVx)
    
                else 
                    ' | obj1 |->| obj2 |
                    obj1.x = obj2.x - obj1.size_x
                    bounceVx0 = -obj1.vx*obj1.collisionRecoil
                    if(bounceVx0 = 0) then
                        bounceVx = bounceVx0
                    else
                        bounceVx = bounceVx0 + abs(minX/bounceVx0)*(obj1.ax + obj1.gx)
                    end if
                    obj1.vx = minFloat(obj2.vx,bounceVx)
    
                end if
            else if ((obj1.isMovable = false) AND obj2.isMovable) then
                '?" - X obj2 movable"
                if(minX = xx1) then ' move object 1 back so it doesn't sink into immovable object 2
                    ' | obj2 |->| obj1 |
                    obj2.x = obj1.x - obj2.size_x
                    bounceVx0 = -obj2.vx*obj2.collisionRecoil
                    if(bounceVx0 = 0) then
                        bounceVx = bounceVx0
                    else
                        bounceVx = bounceVx0 + abs(minX/bounceVx0)*(obj2.ax + obj2.gx)
                    end if
                    obj2.vx = minFloat(obj1.vx,bounceVx)
                else 
                    ' | obj1 |<-| obj2 |
                    obj2.x = obj1.x + obj1.size_x
                    bounceVx0 = -obj2.vx*obj2.collisionRecoil
                    if(bounceVx0 = 0) then
                        bounceVx = bounceVx0
                    else
                        bounceVx = bounceVx0 + abs(minX/bounceVx0)*(obj2.ax + obj2.gx)
                    end if
                    obj2.vx = maxFloat(obj1.vx,bounceVx)
                end if
            end if
        else ' Y dominant
            if (obj1.isMovable AND obj2.isMovable) then
                'Equal & opposite recoil
                'TODO this is  wrong
    '                ?" - Y both movable"
                s = (Abs(obj1.vy) + Abs(obj2.vy))/(obj1.collisionRecoil + obj2.collisionRecoil)
                obj1.vy = -sgn(obj1.vy)*s*obj1.collisionRecoil 'Bounce back 
                obj2.vy = -sgn(obj2.vy)*s*obj2.collisionRecoil
            else if (obj1.isMovable AND (obj2.isMovable = false)) then
    '                ?" - Y obj1 movable"
                if(minY = yy1) then
                    '_
                    'obj2
                    '_
                    'obj1 ^
                    '_
                    obj1.y = obj2.y + obj2.size_y
                    bounceVy0 = -obj1.vy*obj1.collisionRecoil
                    if(bounceVy0 = 0.0) then
                        bounceVy = bounceVy0
                    else
                        bounceVy = bounceVy0 + abs(minY/bounceVy0)*(obj1.ay + obj1.gy)
                    end if
                    obj1.vy = maxFloat(obj2.vy,bounceVy)
                else 
                    '_
                    'obj1 V
                    '_
                    'obj2
                    '_
                    obj1.y = obj2.y - obj1.size_y
                    bounceVy0 = -obj1.vy*obj1.collisionRecoil
                    if(bounceVy0 = 0.0) then
                        bounceVy = bounceVy0
                    else
                        bounceVy = bounceVy0 + abs(minY/bounceVy0)*(obj1.ay + obj1.gy)
                    end if
                    obj1.vy = minFloat(obj2.vy,bounceVy)
                end if
            else if ((obj1.isMovable = false) AND obj2.isMovable) then
    '                ?" - Y obj1 movable"
                if(minY = yy1) then
                    '_
                    'obj2 V
                    '_
                    'obj1 
                    '_
                    obj2.y = obj1.y - obj2.size_y
                    bounceVy0 = -obj2.vy*obj2.collisionRecoil
                    if(bounceVy0 = 0.0) then
                        bounceVy = bounceVy0
                    else
                        bounceVy = bounceVy0 + abs(minY/bounceVy0)*(obj2.ay + obj2.gy)
                    end if
                    obj2.vy = minFloat(obj1.vy,bounceVy)
                else 
                    '_
                    'obj1 
                    '_
                    'obj2 ^
                    '_
                    obj2.y = obj1.y + obj1.size_y
                    bounceVy0 = -obj2.vy*obj2.collisionRecoil
                    if(bounceVy0 = 0.0) then
                        bounceVy = bounceVy0
                    else
                        bounceVy = bounceVy0 + abs(minY/bounceVy0)*(obj2.ay + obj2.gy)
                    end if
                    obj2.vy = maxFloat(obj1.vy,bounceVy)
                end if
            end if
        end if
    
        obj1.overlapState = invalid ' Set back to invalid after resolution
        
    end if

end function

function resolveCollisionGroup(group) as void
    for each o in group.physObjList
        resolveCollision(o)
    end for
end function

