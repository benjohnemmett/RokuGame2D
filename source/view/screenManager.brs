'
' sm = screenManager()
' screen = sm.initScreen()
' mainView = createView() ' each view has it's own sprite which is part of the mainView & compositor which draws to it's own sprite
'
' mainView.addSprite()' Just like compositor call
' mainView.redraw()'
function ScreenManager() as Object

  g = GetGlobalAA()

  sm = {}
  sm.screenWidth = 1280
  sm.screenHeight = 720
  sm.menuBgColor = g.menuBgColor ' Defined in rg2dSetGameParameters'
  sm.screen = invalid
  sm.compositor = invalid
  sm.viewList = {}

  ' Create the screen object & compositor'
  sm.getMainScreen = function() as object
    if m.screen = invalid then
      m.screen = CreateObject("roScreen", true, m.screenWidth, m.screenHeight)
      m.screen.SetAlphaEnable(true)
      m.compositor = CreateObject("roCompositor")
      m.compositor.SetDrawTo(m.screen, m.menuBgColor)
    end if

    return m.screen
  end function

  sm.createView = function(name as string) as object
    sv = screenView(m, 0, 0, m.screenWidth, m.screenHeight)
    m.viewList.addReplace(name, sv)

    return sv
  end function

  sm.getScreen = function() as object
    return m.screen
  end function

  sm.getCompositor = function() as object
    return m.compositor
  end function

  sm.redraw = function() as void
    m.compositor.DrawAll()
    m.screen.swapBuffers()
  end function

  ' hide all views except the one named '
  ' if named view not found, do nothing & return false'
  sm.switchToView = function(name as String) as Boolean
    if m.viewList.DoesExist(name) = False then
      return false
    end if

    keys = m.viewList.keys()
    For each k in keys
      view = m.viewList.Lookup(k)
      if( k = name ) then
        view.show()
      else
        view.hide()
      end if
    End For

    return True
  end function

  return sm

end function

' Create a screenView object that will be drawn to the the provided compositor with the supplied size & location.'
function screenView(parent, x, y, width, height) as object
  g = GetGlobalAA()

  sv = {}

  sv.parent = parent
  sv.parentComp = parent.getCompositor()
  sv.myComp = CreateObject("roCompositor")

  sv.bmView = CreateObject("roBitmap", {width:width, height:height, AlphaEnable:True})
  sv.rgView = CreateObject("roRegion", sv.bmView, 0, 0, width, height)
  sv.spView = sv.parentComp.NewSprite(x, y, sv.rgView, 1)

  sv.myComp.SetDrawTo(sv.bmView, 0)
  sv.bgColor = &h332211FF

  '' Clear & redraw all sprites in this view & swap main screen buffer
  sv.redraw = function() as void
    m.bmView.clear(m.bgColor)
    m.myComp.DrawAll()
    m.parent.redraw() ' # TODO maybe should be a request to redraw here instead of command'
  end function

  '' Redraw all sprites in this view & swap main screen buffer. without clearing first
  sv.drawOver = function() as void
    m.myComp.DrawAll()
    m.parent.redraw() ' # TODO maybe should be a request to redraw here instead of command'
  end function

  '' Create a new sprite & add it to this view
  sv.NewSprite = function(x, y, reg, layer) as Object
    sp = m.myComp.NewSprite(x, y, reg, layer)
    return sp
  end function

  sv.hide = function() as void
    m.spView.SetDrawableFlag(False)
  end function

  sv.show = function() as void
    m.spView.SetDrawableFlag(True)
  end function


  return sv

end function
