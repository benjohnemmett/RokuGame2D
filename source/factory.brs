function createTank(playerNumber, isHumanPlayer, x, y, angle, faceRight, tank_type) as object

  g = GetGlobalAA()

  tank = collectiveRotationalPhysObj(x, y, 30, angle)

  If tank_type = "tank" then
    tank.tank_type = tank_type
  else if tank_type = "igloo" then
    tank.tank_type = tank_type
  else
    tank.tank_type = "tank"
  End If

  if tank.tank_type = "tank" then
    if faceRight then
      sTank = g.compositor.NewSprite(x, y, g.rTruck, 2) ' Flip this one'
    else
      sTank = g.compositor.NewSprite(x, y, g.rTruck, 2)
    end if

  else if tank.tank_type = "igloo" then
    if faceRight then
      sTank = g.compositor.NewSprite(x, y, g.rIgloo_right, 2) ' Flip this one'
    else
      sTank = g.compositor.NewSprite(x, y, g.rIgloo_left, 2)
    end if

  end if

  sTurret1 = g.compositor.NewSprite(x, y, g.rCircleGrey8, 1)
  sTurret2 = g.compositor.NewSprite(x, y, g.rCircleGrey8, 1)
  sTurret3 = g.compositor.NewSprite(x, y, g.rCircleGrey8, 1)
  sTurret4 = g.compositor.NewSprite(x, y, g.rCircleGrey8, 1)
  sTurret5 = g.compositor.NewSprite(x, y, g.rCircleGrey8, 1)
  sTurret6 = g.compositor.NewSprite(x, y, g.rCircleGrey8, 1)

  ''
  tank.minX = 0.0
  tank.maxX = g.screen.GetWidth()
  tank.minY = 0.0
  tank.maxY = g.screen.GetHeight()
  tank.wallEnable = Invalid ' TODO Could maybe turn this off
  tank.size_x = 60
  tank.size_y = 60
  tank.vx = 0
  tank.vy = 0
  tank.maxvx = 10
  tank.maxvy = 10
  tank.turret = collectiveRotationalPhysObj(x, y, 0, pi()/6)
  tank.turret.createElement(sTurret1, 0, 21)
  tank.turret.createElement(sTurret2, 0, 24)
  tank.turret.createElement(sTurret3, 0, 27)
  tank.turret.createElement(sTurret4, 0, 30)
  tank.turret.createElement(sTurret5, 0, 33)
  tank.turret.createElement(sTurret6, 0, 36)
  tank.turret_spacing = 3
  tank.tank_turret_angle = pi()/6 ' angle up from front of tank
  tank.faceRight = faceRight
  tank.MIN_TURRET_ANGLE = 0
  tank.MAX_TURRET_ANGLE = pi()
  tank.MAX_TURRET_SPACING = 3
  tank.MIN_TURRET_SPACING = 0

  tank.health = 100
  tank.playerNumber = playerNumber
  tank.isHumanPlayer = isHumanPlayer

  tank.turret.updateDisplay()

  tank.state = "ALIVE"

  tank.createElement(sTank, 0.0, 0.0)

  '''''' Projectile Stuff
  tank.projectile_list = getProjectileList()
  tank.projectile_idx = 0

  tank.projectile_selector = projectileSelector()
  tank.projectile_selector.updateDisplay()
  rProjectileSelector= CreateObject("roRegion", tank.projectile_selector.bm, 0, 0, tank.projectile_selector.width, tank.projectile_selector.height)
  tank.sProjectileSelector = g.compositor.NewSprite(tank.x, tank.y, rProjectileSelector, 4)

  tank.select_projectile = function(idx)
    ?"Swapping projectile from ";m.projectile_list[m.projectile_idx]
    m.projectile_idx = idx mod m.projectile_list.Count()
    m.projectile_selector.setProjectileIdx(m.projectile_idx) ' Update selector'
    ?"-> To projectile ";m.projectile_list[m.projectile_idx]
  end function

  tank.fireProjectile = function(power as double) as object
    ?"Fire!!!!!!!!!!!"
    g = GetGlobalAA()
    vx = cos(m.tank_turret_angle)*power
    vy = -1*sin(m.tank_turret_angle)*power
    if m.faceRight = false then
      vx = -vx
    end if
    proj = createProjectile(m, m.projectile_list[m.projectile_idx], m.x, m.y, vx, vy)
    g.pogProjs.addPhysObj(proj)

    return proj
  end function

'm.turret.angle'
'        ^
'       270
'        |
' <-180--+---360/0->
'        |
'        90
'        V
  tank.set_turret_angle = function(angle) as void
    p = pi()
    m.tank_turret_angle = minFloat(maxFloat( angle ,m.MIN_TURRET_ANGLE),m.MAX_TURRET_ANGLE)
    If m.faceRight then
      m.turret.angle = 2*p - m.tank_turret_angle
    else
      m.turret.angle = p + m.tank_turret_angle
    End If

  end function

  ' Override update display to also update the turret & flag display as well. '
  tank.updateDisplay = function() as void
    m.turret.x = m.x
    m.turret.y = m.y

    for each e in m.turret.elementArray
        e.updatePosition(m.turret.x, m.turret.y, m.turret.angle)
    end for

    m.turret.updateDisplay()

    ' Updated each element's position
    for each e in m.elementArray
        e.updatePosition(m.x, m.y, m.angle)
    end for

    for each e in m.elementArray
        e.updateDisplay()
    end for

    'Flag Update
    desired_flag_position = (m.health/100.0)
    d = desired_flag_position - m.bmFlag.flagHeight
    ' ?"desired_flag_position";desired_flag_position
    ' ?"m.bmFlag.flagHeight";m.bmFlag.flagHeight
    ' ?"d";d

    flag_rate = 0.01 ' Percent per update cycle'
    if( d = 0.0) then
      'Nothing to do '
      ''?"Equal"
    else if (abs(d) < 2*flag_rate ) then
      m.setFlagPosition(desired_flag_position)
      ''?"Close enough"
    else ' slowly move toward desire position'
      new_pos = m.bmFlag.flagHeight + sgn(d)*flag_rate
      m.setFlagPosition(new_pos)
      m.bmFlag.updateDisplay()
      ''?"Moving"
    end if

  end function

  'Set Turret Spacing
  tank.set_turret_spacing = function(dist) as void
    m.turret_spacing = maxFloat(minFloat(dist, m.MAX_TURRET_SPACING), m.MIN_TURRET_SPACING)
    rad = 21
    for each e in m.turret.elementArray
      e.radius = rad
      rad += dist
    end for
  end function

  tank.set_turret_angle(tank.tank_turret_angle) ' Update display'

  'Flag
  if faceRight then
    bmFlag = flag(tank.x-100, tank.y-380, 100, 400, &hDD1111FF)
    bmFlag.flagRight = true
  else
    bmFlag = flag(tank.x, tank.y-380, 100, 400, &hDD1111FF)
    bmFlag.flagRight = false
  end if
  bmFlag.setFlagPosition(0.98)
  bmFlag.updateDisplay()
  rFlag = CreateObject("roRegion", bmFlag.bm, 0, 0, bmFlag.width, bmFlag.height)
  tank.sFlag = g.compositor.NewSprite(bmFlag.x, bmFlag.y, rFlag, 1)

  tank.bmFlag = bmFlag
  tank.setFlagPosition = function(value)
    m.bmFlag.setFlagPosition(value)
  end function

  tank.takeDamage = function(damage_points) as void
    m.health -= damage_points 'TODO set desired flag lower'
    'm.setFlagPosition(m.health/100.0)
    ?"Taking damage ";damage_points
    ?" Health = ";m.health
    ?" Flag = ";m.bmFlag.flagHeight
    'm.bmFlag.updateDisplay()

  end function

  ' Power bar '
  bmPowerBar = uiExtender(30,100)
  bmPowerBar.updateDisplay()
  rPowerBar = CreateObject("roRegion", bmPowerBar.bm, 0, 0, bmPowerBar.width, bmPowerBar.height)
  tank.sPowerBar = g.compositor.NewSprite(tank.x, tank.y+30, rPowerBar, 3)

  tank.bmPowerBar = bmPowerBar
  tank.setPowerBar = function(value)
    m.bmPowerBar.setValue(value)
  end function
  tank.getPowerBarValue = function()
    return m.bmPowerBar.value
  end function

  tank.setPosition = function(x,y) as void
    m.x = x
    m.y = y

    if m.faceRight then
      m.sFlag.MoveTo(m.x-100,m.y-380)
    else
      m.sFlag.MoveTo(m.x,m.y-380)
    end if

    m.sPowerBar.MoveTo(m.x, m.y+30)


    m.sProjectileSelector.MoveTo(m.x-32, m.y+30)

  end function

  ' Implement ProjectileFirer interface '
  tank.projectileNotification = function(obj, x, y, vx, vy)
    ?"Got notice. Hit ";obj
    if obj = invalid then ' Object timed out without hitting anything'
      return invalid
    end if

    if obj.DoesExist("playerNumber") then
      n = obj.playerNumber
      ?"player ";m.playerNumber;" hit player ";n
    end if

  end function

  'argument target is a tank object'
  tank.calculateNextShot = function(target) as object
    shot = {}
    shot.angle = 60 * (pi()/(180 + rnd(3)-2))
    shot.power = 450 + (rnd(100)-50)
    shot.powerBar = ((shot.power-300)/200)

    return shot
  end function

  ' Return our new tank!'
  return tank

end function ' End Tank Class'


'''''''' Create an AI tank that shoots randomly
function AITankRandy(playerNumber, x, y, angle, faceRight, tank_type)
  isHumanPlayer = false

  randy = createTank(playerNumber, isHumanPlayer, x, y, angle, faceRight, tank_type)

  randy.projectileNotification = function(obj, x, y, vx, vy)
    ?"Got notice. Hit ";obj
    if obj = invalid then ' Object timed out without hitting anything'
      return invalid
    end if
    if obj.DoesExist("playerNumber") then
      n = obj.playerNumber
      ?"Randy (";m.playerNumber;") hit player ";n
    end if

  end function

  randy.calculateNextShot = function() as object
    shot = {}
    shot.angle = 60 * (pi()/(180 + rnd(3)-2))
    shot.power = 450 + (rnd(100)-50)
    shot.powerBar = ((shot.power-300)/200)

    return shot
  end function

  return randy

end function


'''''''' Create an AI tank that shoots based on range to target
function AITankRanger(playerNumber, x, y, angle, faceRight, tank_type)
  isHumanPlayer = false

  ranger = createTank(playerNumber, isHumanPlayer, x, y, angle, faceRight, tank_type)

  ranger.projectileNotification = function(obj, x, y, vx, vy)
    ?"Got notice. Hit ";obj
    if m.last_shot_target <> invalid then ' we can calulate miss distance'
      if(m.faceRight) then
        m.last_shot_miss_distance = x - m.last_shot_target.x
      else
        m.last_shot_miss_distance = m.last_shot_target.x - x
      end if
      ?"last_shot_miss_distance ";m.last_shot_miss_distance
    end if

    if obj = invalid then ' Object timed out without hitting anything'
      return invalid
    end if

    if obj.DoesExist("playerNumber") then
      n = obj.playerNumber
      ?"Randy (";m.playerNumber;") hit player ";n
      m.last_shot_hit = true
    else
      m.last_shot_hit = false
    end if

  end function

  ranger.badness = .5 ' TODO make this setable'

  ranger.last_shot = invalid
  ranger.last_shot_hit = false
  ranger.last_shot_miss_distance = invalid ' projectile_ground_range - target_ground_range'
  ranger.last_shot_target = invalid

  ranger.calculateNextShot = function(target) as object
    shot = {}

    m.last_shot_target = target

    if m.last_shot = invalid then
      shot.angle = 45 * (pi()/180)' Choose high loft to avoid terrain'

      R = abs(m.x - target.x) ' pixels'
      Gy = getProjectileGY() 'pixels /sec^2 ?????'
      D = sin(2 * shot.angle ) ''

      vel = sqr( (R * Gy)/D )

      ?"**** Aiming at something ";R;" pixels away. Power = ";vel

      shot.power = vel ' Yeah... bad variable naming, sorry physicists.'
      shot.powerBar = ((shot.power-300)/200)

    else
      shot = m.last_shot
      ?"**** Last Shot Power";shot.power
      if(m.last_shot_hit) then
        'Nothing to do here now '
      else
        if m.last_shot_miss_distance > 0 then ' Too far'
          shot.power -= 10
        else ' Not far enough'
          shot.power += 10
        end if
      end if
    end if
    ''Shake things up a bit
    shot.power += m.badness * (rnd(50)-25) ' Max +/- 25 vel error'
    shot.angle += m.badness * (5*rnd(0) - 2.5) * (pi()/180) ' Max +/- 5 deg angle error'

    ?"**** Shot Power";shot.power
    m.last_shot = shot

    return shot
  end function

  return ranger

end function
