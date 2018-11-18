function createTank(x, y, angle, faceRight, tank_type) as object

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
  tank.turret.createElement(sTurret1, 0, 3)
  tank.turret.createElement(sTurret2, 0, 6)
  tank.turret.createElement(sTurret3, 0, 9)
  tank.turret.createElement(sTurret4, 0, 12)
  tank.turret.createElement(sTurret5, 0, 15)
  tank.turret.createElement(sTurret6, 0, 18)
  tank.turret_spacing = 3
  tank.tank_turret_angle = pi()/6 ' angle up from front of tank
  tank.faceRight = faceRight
  tank.MIN_TURRET_ANGLE = 0
  tank.MAX_TURRET_ANGLE = pi()
  tank.MAX_TURRET_SPACING = 4
  tank.MIN_TURRET_SPACING = 0

  tank.turret.updateDisplay()

  tank.state = "ALIVE"

  tank.createElement(sTank, 0.0, 0.0)

  tank.fireProjectile = function() as object
    ?"Fire!!!!!!!!!!!"
    g = GetGlobalAA()
    vx = cos(m.tank_turret_angle)*400
    vy = -1*sin(m.tank_turret_angle)*400
    if m.faceRight = false then
      vx = -vx
    end if
    proj = createProjectile(m.x, m.y, vx, vy)
    g.pogProjs.addPhysObj(proj)

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

  ' Override update display to also update the turret display as well. '
  tank.updateDisplay = function() as void
    m.turret.x = m.x
    m.turret.y = m.y

    for each e in m.turret.elementArray
        e.updatePosition(m.turret.x, m.turret.y, m.turret.angle)
    end for

    m.turret.updateDisplay()
    for each e in m.elementArray
        e.updateDisplay()
    end for
  end function

  'Set Turret Spacing
  tank.set_turret_spacing = function(dist) as void
    m.turret_spacing = maxFloat(minFloat(dist, m.MAX_TURRET_SPACING), m.MIN_TURRET_SPACING)
    rad = dist
    for each e in m.turret.elementArray
      e.radius = rad
      rad += dist
    end for
  end function

  tank.set_turret_angle(tank.tank_turret_angle) ' Update display'

  ' Return our new tank!'
  return tank

end function

function createProjectile(x,y,vx,vy) as object
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
  proj.gy = 200
  proj.maxvx = 1000
  proj.maxvy = 1000

  proj.state = "ALIVE"

  proj.createElement(sCirc, 0.0, 0.0)

  return proj

end function
