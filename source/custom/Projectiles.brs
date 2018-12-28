' Projectile dependencies
'  Created with createProjectile(m, m.projectile_list[m.projectile_idx], m.x, m.y, vx, vy) by tank obj
'   Added to physObj group <<Kinematic?>>
'     -
'   Added to the windMaker <<Pushable>>
'   State checked to trigger game state transition
'   Notify owner of collision/timeout death
'
'   -- Multi shot projectiles
'   PLanA
'     - Transfer logic trigger from projectile to active player. Require active player to keep track of projectiles in flight.
'       - Tanks could have an array of projectiles -> Allows for multi-object shots.
'         - Separating objects could be added to the tank's projectilesInFlight list
'       - Tank provides "hasActiveProjectile()" function.
'       - Each projectile piece would separately notify the owner of it's out impact/timeout
'         ** requeres updates to AI logic, might need to collect impact information first, then update at the end of the turn.
'         - Could start by restricing AI to only use single shot, then update AI later. 

function getProjectileList()
  return ["standard","baked_alaska","snowman_pellet"]
end function

function createProjectile(owner as object, ptype, x, y, vx, vy) as object

  g = GetGlobalAA()

  if (ptype = "baked_alaska") then
    proj = projectile(owner, g.rSnowBallFire, 11, 15, x,y,vx,vy)
  else if (ptype = "snowman_pellet") then
    proj = projectile(owner, g.rSnowBall11, 7, 5, x,y,vx,vy)
  else  ' Standard '
    proj = projectile(owner, g.rSnowBall, 11, 15, x,y,vx,vy)
  end if

  return proj

end function


' Projectile Base Class extends collectiveRotationalPhysObj()'
'  Ballistic object which notifies owner when collision happens'
'   Methods'
'   Implements AIProjectile interface
''      - Method getOwner() returns the tank object that fired this object
'       - Method NotifyOwnerOfCollision()
function projectile(owner as object, region, radius, damage_power, x,y,vx,vy) as object
  g = GetGlobalAA()

  sCirc = g.compositor.NewSprite(x, y, region, 0)

  ''
  proj = collectiveRotationalPhysObj(x, y, radius, 0)
  proj.minX = 0.0
  proj.maxX = g.screen.GetWidth()
  proj.minY = 0.0
  proj.maxY = g.screen.GetHeight()
  proj.wallEnable = Invalid
  proj.size_x = radius
  proj.size_y = radius
  proj.vx = vx
  proj.vy = vy
  proj.gy = getProjectileGY()
  proj.maxvx = 1000
  proj.maxvy = 1000
  proj.ttl = 15 ' If it lives longer than 15 seconds it's probably off the screen floating through empty space.
  proj.damage_power = damage_power

  proj.owner = owner

  proj.state = "ALIVE"

  proj.createElement(sCirc, 0.0, 0.0)

  proj.notifyOwnerOfCollision = function(obj) as void
    ' (what_it_is, proj_x, proj_y, proj_vx, proj_vy)'
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

'''''''' Viewer
function projectileSelector() as object

  PS_WIDTH = 30
  PS_HEIGHT = 30

  pv = {bm : CreateObject("roBitmap", {width:PS_WIDTH, height:PS_HEIGHT, AlphaEnable:true}),
        bgColor: &h111133FF,
        borderColor : &hAA5511FF,
        borderWidth : 2,
        idx : 0,
        width : PS_WIDTH,
        height : PS_HEIGHT,
        projectileList : getProjectileList()
        }

  pv.updateDisplay = function()
    g = GetGlobalAA()

    m.bm.clear(&h00000000)
    m.bm.drawRect(0, 0, m.width, m.height , m.bgColor) 'Draw borders'
    m.bm.drawRect(m.borderWidth, m.borderWidth, m.width-2*m.borderWidth, m.height-2*m.borderWidth, m.borderColor)

    ptype = m.projectileList[m.idx]

    if (ptype = "baked_alaska") then
      '(30-21)/2 ~= 5'
      m.bm.DrawObject(5,5,g.rSnowBallFire)
    else if (ptype = "snowman_pellet") then
      m.bm.DrawObject(11,11,g.rSnowBall11)
    else  ' Standard '
      m.bm.DrawObject(5,5,g.rSnowBall)
    end if

  end function

  pv.setProjectileIdx = function(idx) as void
    m.idx  = idx
    m.updateDisplay()
  end function

  return pv



end function
