function flag(_x, _y, width as integer, height as integer, flagColor as integer) as object
  f =  {
    x : _x,
    y : _y,
    width : width,
    height : height,
    bm : CreateObject("roBitmap", {width:width, height:height, AlphaEnable:true}),
    polePos : {x:Cint((width-4)/2), y:0}
    poleSize : {width:8, height:height},
    flagPos : {x:4, y:0},
    flagSize : {width:Cint(((width-8)/2)), height:20},
    flagColor : flagColor,
    poleColor : &hAA5511FF,
    flagHeight : 0.98,
    flagRight : true,
    flagImage : Invalid,

    updateDisplay : function() as void
      m.bm.clear(&h00000000) ' Transparent background, alpha = 0'

      ' Could try to change this simple flag for a bitmap flag using -> DrawObject(x as Integer, y as Integer, src as Object) as Boolean'
      m.bm.drawRect(m.polePos.x, m.polePos.y, m.poleSize.width, m.poleSize.height, m.poleColor) 'Draw Pole'
      if m.flagImage = Invalid then
        m.bm.drawRect(m.flagPos.x, m.flagPos.y, m.flagSize.width, m.flagSize.height, m.flagColor)
      else
        if m.flagRight then
          m.bm.DrawObject(m.flagPos.x-3, m.flagPos.y, m.flagImage)
        else
          m.bm.DrawRotatedObject(m.flagPos.x+48, m.flagPos.y+30, 180, m.flagImage)
        end if
      end if

      m.bm.finish()

    end function,

    setFlagImage : function(image) as void
      m.flagImage = image
      m.updateDisplay()
    end function

    setFlagDirection : function(directionRight) as void
      m.flagRight = directionRight
      m.updateFlagPos()
    end function,

    setFlagPosition : function(percentHeight as float) as void
      m.flagHeight = minFloat(maxFloat(percentHeight,0.1),0.98)
      m.updateFlagPos()
    end function,

    setFlagSize : function(width, height) as void
      m.flagSize.width = width
      m.flagSize.height = height
      m.updateFlagPos()
    end function,

    updateFlagPos : function() as void
      m.flagPos.y = Cint((1.0-m.flagHeight) * m.poleSize.height) 'Round to nearest int'

      if(m.flagRight) then
        m.flagPos.x = m.polePos.x+m.poleSize.width
      else
        m.flagPos.x = m.polePos.x-m.flagSize.width
      end if
    end function

  }

  f.updateDisplay()

  return f

end function
