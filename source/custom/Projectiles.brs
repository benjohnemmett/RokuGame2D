' Projectile Base Class extends collectiveRotationalPhysObj()'
'  Ballistic object which notifies owner when collision happens'
'   Methods'
'   Implements AIProjectile interface
''      - Method getOwner() returns the tank object that fired this object
'       - Method NotifyOwnerOfCollision()
function createProjectile(owner as object, x,y,vx,vy) as object
  g = GetGlobalAA()

  sCirc = g.compositor.NewSprite(x, y, g.rSnowBall, 0)

  ''
  proj = collectiveRotationalPhysObj(x, y, 16, 0)
  proj.minX = 0.0
  proj.maxX = g.screen.GetWidth()
  proj.minY = 0.0
  proj.maxY = g.screen.GetHeight()
  proj.wallEnable = Invalid ' TODO Could maybe turn this off
  proj.size_x = 60
  proj.size_y = 60
  proj.vx = vx
  proj.vy = vy
  proj.gy = getProjectileGY()
  proj.maxvx = 1000
  proj.maxvy = 1000
  proj.ttl = 15 ' If it lives longer than 15 seconds it's probably off the screen floating through empty space.

  proj.owner = owner

  proj.state = "ALIVE"

  proj.createElement(sCirc, 0.0, 0.0)

  proj.notifyOwnerOfCollision = function(obj) as void
    ' (what_it_it, proj_x, proj_y, proj_vx, proj_vy)'
    m.owner.projectileNotification(obj, m.x, m.y, m.vx, m.vy)
  end function
  proj.getOwner = function() as object
    return m.owner
  end function

  ' This is here in case the object has not collided but is about to time out'
  proj.dyingWish = function() as void
  ?"Projectile dying wish"
    if(m.state = "ALIVE") then
      ?"I was alive"
      m.owner.projectileNotification(invalid, m.x, m.y, m.vx, m.vy)
      m.state = "DEAD"
    end if
  end function


  return proj

end function

function getProjectileGY() as float
  return 200
end function
