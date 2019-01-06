' Creates & manages snowflake sprites
function snowMaker(wind as object, compositor as object) as object
  g = GetGlobalAA()

  sm = {
    flakeArray : [],
    comp : compositor,
    wind : wind,
    MIN_X : 0,
    MAX_X : g.sWidth,
    MIN_Y : 0,
    MAX_Y : g.sHeight,
    MID_X : (g.sWidth/2)
  }

  '''''''''''''''''''''''''''''''
  ' Run
  '   Propagate each flake & update display. reset flakes which have gone off screen.
  '   dt in seconds'
  sm.run = function(dt) as void

    for each f in m.flakeArray
      ' run Kinematics
      f.runKinematics(dt)

      ' Check for restart ' TODO consider making a fadeout option
      ' No MIN_Y to allow flakes to start above the screen'
      if(f.x < m.MIN_X) or (f.x > m.MAX_X) or (f.y > m.MAX_Y) then ' restart'
        f.y = 0.0
        f.x = minFloat(maxFloat( m.MID_X - (f.x-m.MID_X), m.MIN_X ),  m.MAX_X) 'Swap sides of the sxreen'
      end if

      ' Update sprite position'
      f.updateDisplay()

    end for

  end function


  '''''''''''''''''''''''''''''''
  ' Randomly initialize a specified number of flakes '
  '   Creates random flakes in an area half the size of the screen, immediately above the screen.
  sm.randomInit = function(numFlakes, regionArray) as void
  g = GetGlobalAA()
  ' TODO finish this'
    For i=0 to numFlakes step 1
      ridx = rnd(regionArray.count())-1 'Randomly pick flake sprite image'
      rFlake = regionArray[ridx]

      x = rnd(m.MAX_X) ' Randomly place on screen '
      y = 0.0 - (2*rnd(m.MAX_Y)/3.0)
      vx = 0
      vy = 0
      gx = 0
      gy = 60 + 30*rnd(3)

      fric = 5.0 + (rnd(0) * 0.3)

      newFlake = flake(rFlake, m.comp, x, y, vx, vy, gx, gy, fric)
      newFlake.maxVy = 200 + 100*rnd(3)
      if newFlake.maxVy < 400 then ' Make slow snow be in the back'
        newFlake.sprite.setZ(g.layers.SlowSnow)
      end if
      m.wind.addObject(newFlake)

      m.flakeArray.push(newFlake) ' Add to my flakeArray

    End For

  end function

  return sm

end function

' Class for a single flake
'   Tracks position & velocity
'
'   rFlake - the roRegion of the image to be used for the sprite
'   comp  - COmpositor to create the sprite with
'   x     - initial x position on the screen (top)
'   y     - initial y position on the screen (left)
'   term - Terminal velocity in either x or y direction
'   fric  - value (0.0 to 1.0) for how much the wind effects this flake. 0.0 is free from wind influence.
function flake(rFlake, comp, x as integer, y as integer, vx, vy, gx, gy, fric) as object

  g = GetGlobalAA()

  f = {
    sprite : comp.NewSprite(x, y, rFlake, g.layers.FastSnow),
    x : x,
    y : y,
    vx : vx,
    vy : vy,
    ax : 0, ' This is where wind factors in'
    ay : 0,
    gx : gx, 'constant gravity'
    gy : gy,
    maxVx : 1000
    maxVy : 1000
    fric : fric, ' portion of wind accelleration that goes to flake vel. Bad Physic shortcut
    state : "JUST FLAKIN" ' Added this to allow it to be "owned" by a windMaker
    alpha : 0.9
  }

  '''''''''''''''''''''''''''''''
  f.runKinematics = function(dt) as void
    'https://gamedev.stackexchange.com/questions/15708/how-can-i-implement-gravity
    m.x  = m.x + dt * (m.vx  + dt * (m.ax*m.fric + m.gx)/2)
    m.y  = m.y + dt * (m.vy  + dt * (m.ay*m.fric + m.gy)/2)

    'Update Velocity
    'm.vx = m.vx + (m.ax*m.fric + m.gx) * dt
    'm.vx = m.vx + (m.ax*m.fric + m.gx) * dt + (m.alpha)*m.ax*m.fric
    'm.vy = (1.0-m.alpha)*m.vy + (m.alpha)*m.ay*m.fric '' Approach fraction of wind speed
    m.vx = (1.0-m.alpha)*m.vx + (m.alpha)*m.ax*m.fric '' Approach fraction of wind speed
    m.vy = m.vy + (m.ay*m.fric + m.gy) * dt

    ' Apply Max velocities
    m.vx = sgn(m.vx)*minFloat(abs(m.vx),m.maxVx)
    m.vy = sgn(m.vy)*minFloat(abs(m.vy),m.maxVy)

  end function

  '''''''''''''''''''''''''''''''
  f.updateDisplay = function() as void
      m.sprite.MoveTo(m.x, m.y)
  end function

  return f

end function
