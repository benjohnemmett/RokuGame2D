function planeTimer() as object

  g = GetGlobalAA()

  gt = {}
  gt.sprite = invalid
  gt.time = invalid
  gt.totalTime = invalid
  gt.xFinal = g.sWidth
  gt.y = 100
  gt.x0 = 0
  gt.gameTimer = invalid

  gt.startTimer = function(time) as void
    g = GetGlobalAA()

    m.gameTimer = g.gametimer

    m.time = 0
    m.totalTime = time
    m.sprite = g.compositor.NewSprite(m.x0, m.y, g.rMiniPlane, g.layers.miniPlane)

  end function

  gt.update = function(dt) as void
    time_ms = m.gameTimer.TotalMilliseconds()

    pcnt_time = (time_ms/(m.totalTime*1000))
    x = pcnt_time * m.xFinal

    m.sprite.moveto(x,m.y)

  end function

  return gt

end function
