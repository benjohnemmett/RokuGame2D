''' Wind model
function windMaker() as object

  w = {}

  w.effectedObjects = [] ' ** Must have ax & ay fields' TODO what interfaces are those? Phys obj?
                          ' Must also have a state field that goes to "DEAD" when object is dead'
  w.ax = 0.0
  w.ay = 0.0

  w.setWindAcc = function(ax, ay) as void

    dx = ax - m.ax
    dy = ay - m.ay

    For each obj in m.effectedObjects
      obj.ax += dx
      obj.ay += ay
    End For

    m.ax = ax
    m.ay = ay

  end function

  w.offsetWind = function(dax, day) as void
    ax = m.ax + dax
    ay = m.ay + day
    m.setWindAcc(ax, ay)
  end function

  w.addObject = function(obj) as void
    ?"Adding object to wind"
    obj.ax += m.ax
    obj.ay += m.ay

    m.effectedObjects.push(obj)
  end function

  w.clearDead = function() as void
    i = 0
    while i < m.effectedObjects.count()
        if(m.effectedObjects[i].state = "DEAD") then
          ?"Removing object from wind"
          m.effectedObjects.Delete(i)
        else
          i += 1
        end if
    end while

  end function

  return w

end function

'' Wind viewer
function windicator(wind, x, y) as object

  DEF_WIDTH = 200
  DEF_HEIGHT = 100

  wv = {
    width : DEF_WIDTH,
    height : DEF_HEIGHT,
    x : x,
    y : y,
    wind : wind,
    bm : CreateObject("roBitmap", {width:DEF_WIDTH, height:DEF_HEIGHT, AlphaEnable:true}),
    updateDisplay : function() as void

      if m.wind <> invalid then
        g = GetGlobalAA()

        wind_strengths = [-20, -10, -5, 5, 10, 20]

        m.bm.clear(&h00000000) ' Transparent background, alpha = 0'

        m.bm.DrawObject(42,5,g.rWindometerText)

        x_ = 40
        For each val in wind_strengths
          if val < 0 then
            if m.wind.ax <= val then
              m.bm.DrawObject(x_, 30, g.rChevronGreenLeft)
            else
              m.bm.DrawObject(x_, 30, g.rChevronGreyLeft)
            end if
          else
            if m.wind.ax >= val then
              m.bm.DrawObject(x_, 30, g.rChevronGreenRight)
            else
              m.bm.DrawObject(x_, 30, g.rChevronGreyRight)
            end if
          end if
          x_ += 20
        End For
        '
        ' if(m.wind.ax <= DEF_STRONG_LEFT) then
        '   m.bm.DrawObject(20, 10, g.rChevronGreyLeft)
        ' else
        ' m.bm.DrawObject(40, 10, g.rChevronGreyLeft)
        ' m.bm.DrawObject(60, 10, g.rChevronGreyLeft)
        ' m.bm.DrawObject(120, 10, g.rChevronGreenRight)
        ' m.bm.DrawObject(140, 10, g.rChevronGreenRight)
        ' m.bm.DrawObject(160, 10, g.rChevronGreyRight)

        m.bm.finish()
      end if

    end function
    }

    g = GetGlobalAA()

    rWindViewer = CreateObject("roRegion", wv.bm, 0, 0, DEF_WIDTH, DEF_HEIGHT)
    g.sWindViewer = g.compositor.NewSprite(x, y, rwindViewer, g.layers.Windometer)

    return wv

end function
