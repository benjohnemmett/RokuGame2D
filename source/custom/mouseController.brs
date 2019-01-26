' Like other components, this must be created with the level compositor already created beforehand
function mouseController()
  mc = {}

  mc.state = "IDLE"
  mc.sBanner = invalid
  mc.BANNER_WIDTH = 100
  mc.PLANE_WIDTH = 148
  mc.PLANE_HEIGHT = 86

  mc.vx = 170

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

    m.BANNER_WIDTH = font.GetOneLineWidth(msg, 1280) + 16

    m.bmBanner = CreateObject("roBitmap", {width:m.PLANE_WIDTH+m.BANNER_WIDTH, height:m.PLANE_HEIGHT, AlphaEnable:true})
    m.bmBanner.DrawObject(0, 0, g.rMousePlaneStrings)

    m.bmBanner.drawRect(m.PLANE_WIDTH, 20, m.BANNER_WIDTH, 30, &hfefff2FF) ' Draw banner'
    'Write message'
    m.bmBanner.DrawText(msg, m.PLANE_WIDTH+8, 20, &h020c30FF, font)

    m.rBanner = CreateObject("roRegion", m.bmBanner, 0, 0, m.PLANE_WIDTH+m.BANNER_WIDTH, m.PLANE_HEIGHT)

    m.x = g.sWidth + 10
    m.y = 100

    m.sBanner = g.compositor.NewSprite(m.x, m.y, m.rBanner, g.layers.MousePlane)

  end function

  mc.getRandomMessage = function(eventName as string) as string
    g = GetGlobalAA()

    msgArray = g.mouseMessageData.lookup(eventName)
    msg = msgArray[rnd(msgArray.count()-1)]

    return msg

  end function


  return mc

end function

' Messgages are loaded globally'
function loadMouseMessages() as void
  g = GetGlobalAA()

  mouseMessageKey = "mouse_msg"

  mouseMessageStrings = rg2dGetRegistryString(mouseMessageKey)

  if(mouseMessageStrings = "") then
    ?"First time setup mouse messages"
    g.mouseMessageData = {}

    g.mouseMessageData.matchStart = []
    g.mouseMessageData.matchStart[0] = "Go! Go! Go!"
    g.mouseMessageData.matchStart[1] = "Now let's have a nice clean snow battle folks!"
    g.mouseMessageData.matchStart[2] = "Have fun you two!"

    g.mouseMessageData.matchOver = []
    g.mouseMessageData.matchOver[0] = "Move along folks, nothing left to see here!"
    g.mouseMessageData.matchOver[1] = "What a shot, what a play, what a match!"
    g.mouseMessageData.matchOver[2] = "Tune in next time for another Snow Battle Adventure!"


    g.mouseMessageData.test = []
    g.mouseMessageData.test[0] = "Mouse Plane Banner Printalizer is experiencing technical difficulties. Please stand by..."



    ?"Saving local data"
    rg2dSaveRegistryData(mouseMessageKey, g.mouseMessageData)
  else
    ?mouseMessageStrings
    g.mouseMessageData = ParseJSON(mouseMessageStrings)
  end if


end function

function setMouseMessageData(data) as void
  g = GetGlobalAA()

  g.mouseMessageData = data

  ?"Saving local data"
  mouseMessageKey = "mouse_msg"
  rg2dSaveRegistryData(mouseMessageKey, g.mouseMessageData)

end function
