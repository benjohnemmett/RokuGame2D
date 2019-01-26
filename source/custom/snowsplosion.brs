function createExplosion(x, y) as object

    g = GetGlobalAA()

    screenWidth = g.sWidth
    screenHeight= g.sHeight

    splode = collectiveRotationalPhysObj(x, y, 15, 0.0)
    splode.minX = 0.0
    splode.maxX = screenWidth
    splode.minY = 0.0
    splode.maxY = screenHeight
    splode.wallEnable = -1 'Wrap screen
    splode.angle = 0
    splode.av = 0
    splode.screen = g.screen

    splode.name = "EXPLOSION"
    splode.state = 0

    splode.sprite = g.pm.compositor.NewSprite(x, y,  g.rSnowsplosion[0], g.layers.snowsplosion)

    splode.createElement(splode.sprite, 0.0, 0.0)

    splode.updateState = function(dt) as void
        g = GetGlobalAA()
        m.state += 1

        if(m.state < 6) then
          m.sprite.setRegion(g.rSnowsplosion[m.state])
        else if(m.state = 6) then
          m.sprite.Remove()
          m.state = "DEAD"
          m.ttl = -0.1
          m.state = 99
        end if

    end function

    return splode

end function
