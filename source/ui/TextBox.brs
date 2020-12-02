function rg2dTextBox(width, height, x, y, view) as Object

  bitMap = CreateObject("roBitmap", {width:width, height:height, AlphaEnable:false, name:"rg2dTextBox"})
  region = CreateObject("roRegion", bitmap, 0, 0, width, height)
  sprite = view.NewSprite(x, y, region, 1)

  g = GetGlobalAA()

  g.fontRegistry = CreateObject("roFontRegistry")
  g.font28 = g.fontRegistry.GetDefaultFont(28, false, false)

  return {
    bitMap : bitMap,
    region : region,
    height : height,
    width : width,
    bgColor : &h0000FFFF,
    textColor : &hFFFFFFFF,
    textSize : 24,
    textBold : false,
    textItalic : false,
    textString : "abcdef",
    textAlignHorizontal : "left",
    font : g.fontRegistry.GetDefaultFont(28, false, false)

    Redraw : function() as void
      m.bitMap.clear(m.bgColor)

      xStart = 0
      yStart = 0

      if m.textAlignHorizontal = "center"
        textWidth = m.font.GetOneLineWidth(m.textString, m.width)
        xStart = (m.width - textWidth)/2
      else if m.textAlignHorizontal = "right"
        textWidth = m.font.GetOneLineWidth(m.textString, m.width)
        xStart = (m.width - textWidth)
      end if

      m.bitMap.DrawText(m.textString, xStart, yStart, m.textColor, m.font)

    end function,

    SetText : function(text) as void
      m.textString = text
      m.Redraw()
    end function,

    SetFontSize : function(size) as void
      m.textSize = size
      g = GetGlobalAA()
      m.font = g.fontRegistry.GetDefaultFont(size, m.textBold, m.textItalic)

      m.Redraw()
    end function,

    SetTextAlignHorizontal : function(alignString) as void
      if alignString = "right"
        m.textAlignHorizontal = "right"
      else if alignString = "center"
        m.textAlignHorizontal = "center"
      else
        m.textAlignHorizontal = "left"
      end if

      m.Redraw()
    end function,

  }

end function
