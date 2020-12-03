function DisplayManager(view as object) as object
  dm = {}

  dm.DisplayObjList = []
  dm.view = view

  dm.addDisplayObj = function(do as object) as void
    m.DisplayObjList.push(do)
  end function

  dm.updateDisplays = function(dt as float)
    i = 0
    while i < m.DisplayObjList.count()
        a = m.DisplayObjList[i]

        a.updateDisplay(dt) 'Update Display
        i += 1

    end while
  end function

  dm.reset = function() as void
    For each o in m.DisplayObjList
      o.reset()
    End For

    m.DisplayObjList.clear()

  end function


  return dm

end function

' Component to be added to gameObjects'
'  Requires object to have these fields:
'   x : x position
'   y : y position
function DisplayComp(sprite as object) as object
  dc = {}

  dc.compType = "DisplayComp"

  dc.sprite = sprite
  dc.region = sprite.GetRegion()
  dc.region.SetWrap(True)

  dc.animate = False
  dc.animationOffsetX = 0
  dc.animationOffsetY = 0
  dc.animationOffsetWidth = 0
  dc.animationOffsetHeight = 0
  dc.timeSinceLastAnimation = 0
  dc.framePeriod = 0.033

  dc.updateDisplay = function(dt) as void
    if(m.sprite <> invalid) then
      m.sprite.MoveTo(m.x, m.y) ' Requires x & y from gameObj. This component will not stand on it's own

      if(m.animate) then
        m.timeSinceLastAnimation += dt
        if (m.timeSinceLastAnimation > m.framePeriod) then
          m.timeSinceLastAnimation = 0
          m.sprite.OffsetRegion(m.animationOffsetX, m.animationOffsetY, m.animationOffsetWidth, m.animationOffsetHeight)
        end if
      end if
    else
        ?"Warning: Display object has no sprite."
    end if
  end function

  dc.reset = function() as void

    ?" - DisplayComp Reset "
    if m.sprite <> invalid then
      m.sprite.remove()
    end if

  end function


  return dc

end function
