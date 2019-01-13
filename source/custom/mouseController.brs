' Like other components, this must be created with the level compositor already created beforehand
function mouseController()
  mc = {}

  mc.state = "IDLE"
  mc.sBanner = invalid
  mc.BANNER_WIDTH = 100
  mc.PLANE_WIDTH = 148
  mc.PLANE_HEIGHT = 86

  mc.vx = 150

  ' dt seconds since last update in seconds'
  mc.update = function(dt)
    if m.state = "IDLE" then

    else if m.state = "FLYING" then

      m.x -= dt * m.vx
      m.y += dt * (rnd(7) - 4)
      m.sBanner.moveto(m.x, m.y)

      if( m.x < ( 0 - (m.BANNER_WIDTH + m.PLANE_WIDTH) ) ) then ' Off screen'
        m.state = "IDLE"
        m.sBanner.remove()
        m.sBanner = invalid
      end if
    end if

  end function

  mc.startPlaneBanner = function(msg as string)
    m.createMousePlaneBanner(msg)
    m.state = "FLYING"
  end function

  mc.createMousePlaneBanner = function(msg as string)
    g = GetGlobalAA()
    font = g.font_registry.GetFont("HannaHandwriting",20, True, false)
    'font = g.font_registry.GetFont("Almonte Snow", 56, false, false)

    m.BANNER_WIDTH = font.GetOneLineWidth(msg, 1280) + 8

    m.bmBanner = CreateObject("roBitmap", {width:m.PLANE_WIDTH+m.BANNER_WIDTH, height:m.PLANE_HEIGHT, AlphaEnable:true})
    m.bmBanner.DrawObject(0, 0, g.rMousePlaneStrings)

    m.bmBanner.drawRect(m.PLANE_WIDTH, 20, m.BANNER_WIDTH, 30, &hfefff2FF) ' Draw banner'
    'Write message'
    m.bmBanner.DrawText(msg, m.PLANE_WIDTH+2, 20, &h020c30FF, font)

    m.rBanner = CreateObject("roRegion", m.bmBanner, 0, 0, m.PLANE_WIDTH+m.BANNER_WIDTH, m.PLANE_HEIGHT)

    m.x = g.sWidth + 10
    m.y = 100

    m.sBanner = g.compositor.NewSprite(m.x, m.y, m.rBanner, g.layers.MousePlane)

  end function


  return mc

end function
