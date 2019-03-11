function CardTable(rows, cols) as object
  ct = gameObject(0, 0)

  ct.rows = rows
  ct.cols = cols

  ct.selRow = 0
  ct.selCol = 0

  dim idTable[ct.rows, ct.cols]

  ct.idTable = idTable
  For r=0 to ct.rows-1 step 1
    For c=0 to ct.cols-1 step 1
      ct.idTable[r,c] = invalid
    End For
  End For

  ' ?? TODO Maybe add option to create new sprite or just move the other one'
  ct.setCard = function(r, c, theCard) as void
    if (r < 0) OR (r >= m.rows ) OR (c < 0) OR (c >= m.cols) then
      ?"Error: setting card out of bounds requested."
      return
    end if

    m.idTable[r, c] = theCard
  end function

  ct.getCard = function(r, c) as object
    return m.idTable[r, c]
  end function

  ct.getSelectedCard = function() as object
    return m.idTable[m.selRow, m.selCol]
  end function

  ' Apply offset to currently selected card'
  ct.selectOffset = function(drow as integer, dcol as integer) as void
    ''?"deltas ";drow;" ";dcol
    ''?"selected ";m.selRow;" ";m.selCol

    mycard = m.idTable[m.selRow, m.selCol]

    mycard.dirty = true

    m.selRow += drow
    m.selCol += dcol

    if m.selRow < 0 then
      m.selRow += m.rows
    else if m.selRow >= m.rows then
      m.selRow -= m.rows
    end if

    if m.selCol < 0 then
      m.selCol += m.cols
    else if m.selCol >= m.cols then
      m.selCol -= m.cols
    end if
    ''?"Selected ";m.selRow;" ";m.selCol

    mycard = m.idTable[m.selRow, m.selCol]
    mycard.dirty = true
  end function

  ct.printTable = function() as void
      For r=0 to m.rows-1 step 1
        str = "[" + r.toStr() + "] "
        For c=0 to m.cols-1 step 1
          str = str + "( " + m.idTable[r,c].id + ", " + m.idTable[r,c].flipped.toStr() + ") "
        End For
        ?str
      End For
    end function

  ' Swap positions of two cards'
  ct.swapCards = function(r1, c1, r2, c2) as void
    card1 = m.getCard(r1,c1)
    card2 = m.getCard(r2,c2)

    m.setCard(r2,c2,card1)
    m.setCard(r1,c1,card2)

    card1.dirty = true
    card2.dirty = true
  end function


    return ct

end function


' Not a displayable object but a manager that sets sprites in the appropriate place according to the talbe'
function tableViewController(table, view, x, y, width, height)

  tvc = gameObject(x,y)
  tvc.table = table
  tvc.view = view
  ' tvc.x = x' Top left'
  ' tvc.y = y ' Top left'

  tvc.xSpace = int(width/table.cols)
  tvc.ySpace = int(height/table.rows)

  tvc.margin = 5

  tvc.cardWidth = tvc.xSpace - tvc.margin
  tvc.cardHeight = tvc.ySpace - tvc.margin

  dim cardMatrix[tvc.table.rows, tvc.table.cols]
  tvc.cardMatrix = cardMatrix

  ' create an array of sprites, one for each card spot on the table'
  tvc.setupCardMatrix = function() as void
    g = GetGlobalAA()

    For r=0 to m.table.rows-1 step 1
      For c=0 to m.table.cols-1 step 1

            theCard = DisplayComp(invalid)

            theCard.x = m.x + c*m.xSpace
            theCard.y = m.y + r*m.ySpace

            theCard.bm = CreateObject("roBitmap", {width:m.cardWidth, height:m.cardHeight, AlphaEnable:true})
            theCard.bm.clear(&h00000055 + 4095*theCard.x)
            theCard.region = CreateObject("roRegion", theCard.bm, 0, 0, m.cardWidth, m.cardHeight)
            theCard.sprite = m.view.NewSprite(theCard.x, theCard.y, theCard.region, 1)


            g.dm.addDisplayObj(theCard) ' Add sprite to dm so that it will be updated '

            m.cardMatrix[r,c] = theCard
      End For
    End For

  end function

  '' Draw the cards on there
  tvc.drawCards = function() as void
    srow = m.table.selRow
    scol = m.table.selCol

    For r=0 to m.table.rows-1 step 1
      For c=0 to m.table.cols-1 step 1

        tableCard = m.table.getCard(r,c)


        if tableCard = invalid then
          ''?" Found invalid card at ";r;" ";c
        else
          if tableCard.dirty then
            theCardView = m.cardMatrix[r,c]
            if(srow = r) and (scol = c) then
              theCardView.bm.clear(&hCCCC33FF)
            else
              theCardView.bm.clear(&h00000000)
            end if

            xsf_ = m.cardWidth/tableCard.frontImg.getWidth()
            ysf_ = m.cardHeight/tableCard.frontImg.getHeight()
            sf = minFloat(xsf_, ysf_)

            xsf = sf*tableCard.xflipscale
            dx = int((m.cardWidth - (tableCard.frontImg.getWidth()*xsf))/2)

            theCardView.bm.DrawScaledObject(dx, 0, xsf, sf, tableCard.getShowingSideImage())

            tableCard.dirty = false
          end if

        end if
      End For
    End For



  end function

  tvc.setupCardMatrix()
  tvc.drawCards()

  tvc.update = function(dt)
    m.drawCards()
  end function

  return tvc

end function
