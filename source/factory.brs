
function createTank(x, y, angle) as object

  g = GetGlobalAA()

  sTruck = g.compositor.NewSprite(x, y, g.rTruck, 0)

  ''
  tank = collectiveRotationalPhysObj(x, y, 30, angle)
  tank.minX = 0.0
  tank.maxX = g.screen.GetWidth()
  tank.minY = 0.0
  tank.maxY = g.screen.GetHeight()
  tank.wallEnable = 0 ' TODO Could maybe turn this off
  tank.size_x = 60
  tank.size_y = 60
  tank.vx = 0
  tank.vy = 0
  tank.maxvx = 10
  tank.maxvy = 10

  tank.state = "ALIVE"

  tank.createElement(sTruck, 0.0, 0.0)

  tank.fireProjectile = function() as object
    ?"Fire!!!!!!!!!!!"
    g = GetGlobalAA()
    proj = createProjectile(m.x, m.y, 300, -300)
    g.pogProjs.addPhysObj(proj)

  end function

  return tank

end function

function createProjectile(x,y,vx,vy) as object
  g = GetGlobalAA()

  sCirc = g.compositor.NewSprite(x, y, g.rCircleFire16, 0)

  ''
  proj = collectiveRotationalPhysObj(x, y, 16, 0)
  proj.minX = 0.0
  proj.maxX = g.screen.GetWidth()
  proj.minY = 0.0
  proj.maxY = g.screen.GetHeight()
  proj.wallEnable = 0 ' TODO Could maybe turn this off
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
