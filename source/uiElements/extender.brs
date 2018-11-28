function uiExtender(width as Integer, height as Integer) as object
 return {
  bm : CreateObject("roBitmap", {width:width, height:height, AlphaEnable:true}),
  width : width,
  height : height,
  borderColor : &hAA5511FF,
  bgColor : &h111111FF,
  fgColor : &h111100FF,
  value : 0.75, ' Between 0 & 1.0'
  borderWidth :  5, ' pixels'
  barHeight : height - 2*5,

  updateDisplay : function() as void
    m.bm.clear(&h00000000)
    m.bm.drawRect(0, 0, m.width, m.height , m.borderColor) 'Draw borders'

    fgYStart = Cint((1.0-m.value) * m.barHeight) 'Round to nearest int'

    cShift = int(m.value * &hEE) << 24


    m.bm.drawRect(m.borderWidth, m.borderWidth, m.width-m.borderWidth*2, m.height-m.borderWidth*2, m.bgColor) 'Draw background'
    m.bm.drawRect(m.borderWidth, m.borderWidth + fgYStart, m.width-m.borderWidth*2, m.height-m.borderWidth*2-fgYStart, m.fgColor + cShift) 'Draw fg'

    m.bm.finish()
  end function,

  setBorderWidth : function(bw)
    m.borderWidth = bw
    m.barHeight =  m.height - 2*bw
    m.updateDisplay()
  end function,

  setValue : function(val) as void
    m.value  = minFloat( maxFloat(val,0.0), 1.0)
    m.updateDisplay()
  end function

 }
 ' TODO add this to the compositor somehow'
end function
