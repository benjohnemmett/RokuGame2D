' A deck defines a deck of cards that can be used for playing a match game.
' It should support basic game play and more complex game play
' - basic game play is selecting two cards & checking for a match
' - complex game play allows for custom events when selecting either the first or second card
'
'
' myDeck = deck("standard")
'
' myDeck.setBackImage(roRegion img)
' myDeck.addCard(string id, roRegion img)
' myDeck.addCard(string id, roRegion img)
' myDeck.addCard(string id, roRegion img)
'
'
' myDeck.setMatchSameIDs(False) ' Do not match cards with the same id unless there is a specific rule to do so'
'
' myDeck.setMatch(id1, id2, int points, callback) ' set id1 & id2 to be matches, award specified points if found, & use callback for custom event (set invalid to disable)'
' myDeck.setMatch(id3, id3, 500, invalid) ' set id3 to match itself (only needed if matchSameIDs is set to false) award 500 points for match & disable custom callback function'
'

function deck(view, backImg) as object

  d = {} ' should this be a game object? Seems to just be holding information, not needing self updates, or display'

  d.backImg = backImg
  d.cardDefinitions = {} ' '
  d.matches = {} '' assocArray of assoc arrays
  d.view = view

  '' Define a card that this deck can produce
  d.defineCard = function(id as string, frontImg) as void
    cd = {}
    cd.id = id
    cd.frontImg = frontImg

    m.cardDefinitions.addReplace(id, cd)
  end function

  ' load an image with an array of card images, each of cWidth & cHeight.
  ' Assume first card image is the deck back.'
  ' Create a card definition for each card'
  d.loadDeckFromImage = function(bm, cardWidth, cardHeight)
    rows = int(bm.getHeight()/cardHeight)
    cols = int(bm.getWidth()/cardWidth)

    m.backImg = CreateObject("roRegion", bm, 0, 0, cardWidth, cardHeight)
    cardNum = 0

    For r=0 to rows-1 step 1
      For c=1 to cols-1 step 1
        ?"Creating card ";cardNum;" From row ";r;" col ";c
        img = CreateObject("roRegion", bm, cardWidth*c, cardHeight*r, cardWidth, cardHeight)
        m.defineCard(cardNum.toStr(), img)

        cardNum += 1
      End For
    End For

  end function


  '' create a card object that can be added to a table
  d.createCardInstance = function(id as string) as object
    cd = m.cardDefinitions.lookup(id)

    if cd <> invalid then
      c = card(cd.id, cd.frontImg, m.backImg)
    else
      ?"Count not find card: ";id
      stop
      c = invalid
    end if

    return c
  end function

  ' Define a match of two card ids'
  d.setMatch = function(id1 as string, id2 as string) as boolean
  'TODO'
  end function

  ' Check that two ids match
  d.checkMatch = function(id1 as string, id2 as string) as boolean
  'TODO'
  end function


  return d

end function


' Object that can be added to a table. Contains front image but is not displayable itself. Use a CardView to display thison a tableView'
function card(id as string, frontImg, backImg) as object

  c = {}

  c.uid = rnd(2^16-1)
  c.id = id
  c.frontImg = frontImg
  c.backImg = backImg
  c.flipped = false
  c.xflipscale = 1.0
  c.dirty = True
  c.state = rg2dStateMachine("IDLE")
  c.state.name = "card"

  c.getShowingSideImage = function()
    if m.flipped then
      return m.frontImg
    else
      return m.backImg
    end if
  end function

  c.flip = function()
    if m.flipped then
      m.flipped = false
    else
      m.flipped = true
    end if
  end function

  c.setXFlipScale = function(xfs)
    m.dirty = true
    m.xflipscale = xfs
  end function

  return c

end function
