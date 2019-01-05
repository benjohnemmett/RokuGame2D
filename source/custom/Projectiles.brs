' Projectile dependencies
'  Created with createProjectile(m, m.projectile_list[m.projectile_idx], m.x, m.y, vx, vy) by tank obj
'   Added to physObj group <<Kinematic?>>
'     -
'   Added to the windMaker <<Pushable>>
'   Notify owner of collision/timeout death


function getProjectileList()
  return ["standard","baked_alaska","snowman_pellet"]
end function

function getShotTypeList()
  return ["standard_1","standard_3p","standard_5p","standard_3s","standard_5s",
          "pellet_1","pellet_3p","pellet_5p","pellet_3s","pellet_5s",
          "baked_alaska_1"]
  ' return ["baked_alaska_1"]
  ' return ["baked_alaska_1","pellet_5s"]
end function

''' Creates an array of oneShots
function createShot(owner, sType, x, y, power, angle, faceRight)
  g = GetGlobalAA()

  shotArray = []

  PELLET_RAD = 5
  PELLET_DMG = 4
  STD_RAD = 11
  STD_DMG = 8
  BA_RAD = 11
  BA_DMG = 25

  ?" Creating Shot ";sType
  if(sType = "standard_1") then
    shotArray = subCreateShot(owner, g.SB.standard_1, 1, true, STD_RAD, STD_DMG, x, y, power, angle, faceRight)

  else if(sType = "standard_3p") then
    shotArray = subCreateShot(owner, g.SB.standard_1, 3, false, STD_RAD, STD_DMG, x, y, power, angle, faceRight)

  else if(sType = "standard_5p") then
    shotArray = subCreateShot(owner, g.SB.standard_1, 5, false, STD_RAD, STD_DMG, x, y, power, angle, faceRight)

  else if(sType = "standard_3s") then
    shotArray = subCreateShot(owner, g.SB.standard_1, 3, true, STD_RAD, STD_DMG, x, y, power, angle, faceRight)

  else if(sType = "standard_5s") then
    shotArray = subCreateShot(owner, g.SB.standard_1, 5, true, STD_RAD, STD_DMG, x, y, power, angle, faceRight)

  else if(sType = "pellet_1") then
    shotArray = subCreateShot(owner, g.SB.pellet_1, 1, true, PELLET_RAD, PELLET_DMG, x, y, power, angle, faceRight)

  else if(sType = "pellet_3p") then
    shotArray = subCreateShot(owner, g.SB.pellet_1, 3, false, PELLET_RAD, PELLET_DMG, x, y, power, angle, faceRight)

  else if(sType = "pellet_5p") then
    shotArray = subCreateShot(owner, g.SB.pellet_1, 5, false, PELLET_RAD, PELLET_DMG, x, y, power, angle, faceRight)

  else if(sType = "pellet_3s") then
    shotArray = subCreateShot(owner, g.SB.pellet_1, 3, true, PELLET_RAD, PELLET_DMG, x, y, power, angle, faceRight)

  else if(sType = "pellet_5s") then
    shotArray = subCreateShot(owner, g.SB.pellet_1, 5, true, PELLET_RAD, PELLET_DMG, x, y, power, angle, faceRight)

  else if(sType = "baked_alaska_1") then
    shotArray = subCreateShot(owner, g.SB.baked_alaska_1, 1, true, BA_RAD, BA_DMG, x, y, power, angle, faceRight)

  else
      ?"*** Warning *** Unhandled shotType requested ";sType

  end if

  return shotArray

end function

function subCreateShot(owner, region, number, isSerial, radius, damage_power, x, y, power, angle, faceRight)

  shotArray = []
  deg5 = 0.0872664626

  if(isSerial) then
    For i=0 to (number-1) step 1
      proj = projectile_ap(owner, region, radius, damage_power, x, y, angle, power, faceRight)
      s = oneShot(proj, 0.1 * i)
      shotArray.push(s)
    End For
  else
    fromHere = -1*(number-1)/2
    toHere = (number-1)/2
    For i=fromHere to toHere step 1
      proj = projectile_ap(owner, region, radius, damage_power, x, y, angle + i*deg5, power, faceRight)
      s = oneShot(proj, 0.0)
      shotArray.push(s)
    End For
  end if

  return shotArray

end function


'Wrapper to hold future shots until a certain time'
function oneShot(proj, time)
  return {proj : proj, time : time}
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
    m.owner.projectileNotification(m, obj)
  end function

  proj.getOwner = function() as object
    return m.owner
  end function

  ' This is here in case the object has not collided but is about to time out'
  proj.dyingWish = function() as void
  ?"Projectile dying wish"
    if(m.state = "ALIVE") then
      ?"I was alive"
      m.owner.projectileNotification(m, invalid)
      m.state = "DEAD"
    end if
  end function


  return proj

end function

''' Helper function to create projectile from angle & power
function projectile_ap(owner as object, region, radius, damage_power, x, y, angle, power, faceRight) as object

  vx = cos(angle)*power
  vy = -1*sin(angle)*power
  if faceRight = false then
    vx = -vx
  end if

  proj = projectile(owner, region, radius, damage_power, x, y, vx, vy)

  return proj

end function

function getProjectileGY() as float
  return 200
end function


function shotSelector()

  PS_WIDTH = 30
  PS_HEIGHT = 30

  pv = {bm : CreateObject("roBitmap", {width:PS_WIDTH, height:PS_HEIGHT, AlphaEnable:true}),
        bgColor: &hAAAAFFFF,
        borderColor : &h111111FF,
        borderWidth : 2,
        idx : 0,
        width : PS_WIDTH,
        height : PS_HEIGHT,
        shotTypeList : getShotTypeList()
        }

  pv.updateDisplay = function()
    g = GetGlobalAA()

    m.bm.clear(&h00000000)
    m.bm.drawRect(0, 0, m.width, m.height , m.borderColor) 'Draw borders'
    m.bm.drawRect(m.borderWidth, m.borderWidth, m.width-2*m.borderWidth, m.height-2*m.borderWidth, m.bgColor)

    sType = m.shotTypeList[m.idx]

    ' Draw selection icon'
    m.bm.DrawObject(0,0,g.SB.Lookup(sType))

  end function

  pv.setShotTypeIdx = function(idx) as void
    m.idx  = idx
    m.updateDisplay()
  end function

  return pv

end function
