' TODO should these all be subs, not returning anything? Any advantage to subs?

' Set global game parameters here.
function rg2dSetGameParameters() as void

    g = GetGlobalAA()

    g.USING_LB_CODE = false
    g.DEBUG = True

    g.highScoreRegister = "GameHighScores"

    g.menuArray = rg2dMenuItemList()
    g.menuArray.addItem("Small Game", "new_small_game")
    g.menuArray.addItem("Big Game", "new_large_game")
    g.menuArray.addItem("Options", "options")
    g.menuArray.addItem("High Scores", "high_scores")
    g.menuArray.addItem("About", "about")
    g.menuBgColor = &hAACCFFFF

end function

'
' Load all Sprites Used in the game
'
function rg2dLoadSprites() as void
    g = GetGlobalAA()

    if(g.DEBUG) then
      ?"Loading Sprites..."
    end if

    bmScore = CreateObject("roBitmap", "pkg:/components/sprites/Numbers_Spritesheet_32.png")

    g.rScore = []
    g.rScore[0] = CreateObject("roRegion", bmScore, 0*32, 0, 32, 32)
    g.rScore[1] = CreateObject("roRegion", bmScore, 1*32, 0, 32, 32)
    g.rScore[2] = CreateObject("roRegion", bmScore, 2*32, 0, 32, 32)
    g.rScore[3] = CreateObject("roRegion", bmScore, 3*32, 0, 32, 32)
    g.rScore[4] = CreateObject("roRegion", bmScore, 4*32, 0, 32, 32)
    g.rScore[5] = CreateObject("roRegion", bmScore, 5*32, 0, 32, 32)
    g.rScore[6] = CreateObject("roRegion", bmScore, 6*32, 0, 32, 32)
    g.rScore[7] = CreateObject("roRegion", bmScore, 7*32, 0, 32, 32)
    g.rScore[8] = CreateObject("roRegion", bmScore, 8*32, 0, 32, 32)
    g.rScore[9] = CreateObject("roRegion", bmScore, 9*32, 0, 32, 32)

    'g.bmBasicDeck = CreateObject("roBitmap", "pkg:/components/sprites/BasicDeck_1x7.png")
    g.bmBasicDeck = CreateObject("roBitmap", "pkg:/components/sprites/BasicDeck_1x13.png")
    g.bmBasicCard = CreateObject("roBitmap", "pkg:/components/sprites/BasicCard_601_400.png")
    g.rBasicCardBack = CreateObject("roRegion", g.bmBasicCard, 0, 0, 300, 400)
    g.rBasicCardFront = CreateObject("roRegion", g.bmBasicCard, 300, 0, 300, 400)

    bmPauseScreen = CreateObject("roBitmap", "pkg:/components/sprites/Pause_Menu_Screen.png")
    g.rPauseScreen = CreateObject("roRegion", bmPauseScreen, 0, 0, 640, 200)

    'bmTruck = CreateObject("roBitmap", "pkg:/components/sprites/texture_brick01_60p.png")
    'g.rTruck = CreateObject("roRegion", bmTruck, 0, 0, 60, 60)
    g.rPlayerArea = rg2dLoadRegion("pkg:/components/sprites/player_area_300_400.png", 0, 0, 300, 400)

    if(g.USING_LB_CODE) then
        LBLoadSprites()
    end if

end function

'
' Load all sounds used in the game
'
function rg2dLoadSounds() as void
    g = GetGlobalAA()

    if(g.DEBUG) then
      ?"Loading Sounds..."
    end if

    g.sounds ={}
    'g.sounds.ship_engines = CreateObject("roAudioResource", "pkg:/assets/ship_engines.wav")
    g.sounds.navSingle = CreateObject("roAudioResource", "navsingle")

    '?"Max Streams ";g.sounds.astroid_blast.maxSimulStreams()
    g.audioStream = 1
    g.maxAudioStreams = 1 'g.sounds.astroid_blast.maxSimulStreams()

end function

function rg2dLoadFonts() as void

end function

'
' Use this to set custom actions when a menu item is selected
'
function rg2dMenuItemSelected() as void

    g = GetGlobalAA()

    if(g.DEBUG) then
      ?"Menu Item Selected ...";
    end if

    selectedMenuOption = g.menuArray.selectedIndex

    shortName = g.menuArray.getSelectedItemShortName()

    if(g.DEBUG) then
      ?"->";shortName
    end if

    if(shortName = "new_small_game") then ' New Game

        stat = rg2dPlayGame(1, 3, 4)

    else if(shortName = "new_large_game") then ' New Game

        stat = rg2dPlayGame(1, 4, 6)

    else if(shortName = "options") then ' Settings
        '?"Going to settings screen"
        'rg2dPlaySound(m.sounds.warp_out)
        stat = rg2dOpenSettingsScreen(m.screen, m.port)
        'rg2dPlaySound(m.sounds.warp_in)

    else if(shortName = "high_scores") then

        'rg2dPlaySound(m.sounds.warp_out)
        stat = rg2dOpenHighScoresScreen(m.screen, m.port)
        'rg2dPlaySound(m.sounds.warp_in)

    else if(shortName = "about") then

        'rg2dPlaySound(m.sounds.warp_out)
        stat = rg2dOpenCreditScreen(m.screen, m.port)
        'rg2dPlaySound(m.sounds.warp_in)
    end if


end function


' Stuff that needs to be done at the start of each game goes here.
function rg2dGameInit(numPlayers as integer, tableRows as integer, tableCols as integer) as void
    g = GetGlobalAA()

    g.numPlayers = numPlayers
    g.currentPlayer = 0 ' zero based'
    g.cardsFlipped = []
    g.gameState = rg2dStateMachine("START_GAME")
    g.gameState.name = "gameState"

    gameView = g.screenMgr.getView("game")
    gameView.bgColor = &h334455FF

    if(g.DEBUG) then
      ?"rg2dGameInit()..."
    end if

  ''  tableRows = 4
  ''  tableCols = 6

    g.table = CardTable(tableRows,tableCols)

    basicDeck = deck(gameView, invalid)
    basicDeck.loadDeckFromImage(g.bmBasicDeck, 300, 400)

    g.activeDeck = basicDeck

    first = true
    idx = 0

    For i=0 to tableRows-1 step 1
      For j=0 to tableCols-1 step 1
        myCard = basicDeck.createCardInstance(idx.toStr())
        g.table.setCard(i,j,myCard)

        if first then
          first = false
        else
          idx += 1
          first = True
        end if

      End For
    End For

    ' Shuffle cards on table '
    if True then
      For i=0 to tableRows-1 step 1
        For j=0 to tableCols-1 step 1

          g.table.swapCards(i,j, rnd(tableRows)-1,rnd(tableCols)-1)

        End For
      End For
    end if

    g.table.printTable()

    ' Display table'
    WIDTH = 1280
    HEIGHT = 720

    top_margin = 50
    bottom_margin = 100

    player_area_width = 200
    player_area_margin = 30
    table_width = WIDTH - 2*(player_area_width + 2*player_area_margin)
    table_height = HEIGHT - (top_margin + bottom_margin)

    g.tableViewMgr = tableViewController(g.table, gameView, player_area_width + 2*player_area_margin, top_margin, table_width, table_height)

    g.om.addGameObj(g.table) ' TODO does this need to be here?8
    g.om.addGameObj(g.tableViewMgr)

    ' Player area
    g.playerArea_1 = PlayerArea(4,3)
    g.playerAreaViewMgr_1 = tableViewController(g.playerArea_1, gameView, player_area_margin, top_margin, player_area_width, table_height/2-player_area_margin)
    g.om.addGameObj(g.playerAreaViewMgr_1)

    if(g.USING_LB_CODE) then
        LBMakeGroups()
    end if

end function


'''''''''' OUTER LOOP STUFF
' Stuff to be done at the start of each level goes here.
function rg2dLoadLevel(level as integer) as void
    g = GetGlobalAA()
    if(g.DEBUG) then
      ?"rg2dLoadLevel()..."
    end if
    if(g.USING_LB_CODE) then
        LBLoadLevel(level)
    end if

end function

' Stuff to be done at the start of each update loop goes here.
function rg2dInnerGameLoopUpdate(dt as float, button, holdTime) as object
    g = GetGlobalAA()
    if(g.DEBUG) AND dt > 0.04 then
      ?"rg2dInnerGameLoopUpdate long frame ";dt;"..."
    end if

    g.gameState.tick(dt)

    status = rg2dStatus()
    theCard = invalid

    ''''''''''''''''''''''''''''''''''''''''''
    ''''''''''''''''''''''''''''''''''''''''''
    ' Control
    ''''''''''''''''''''''''''''''''''''''''''
    ''''''''''''''''''''''''''''''''''''''''''
    if(button.bUp) then
        ''?"Trucking Up ";button.thisPress
        if button.thisPress <> invalid then
          ?"Move it"
          g.table.selectOffset(-1,0)
        end if

    else if(button.bDown) then
        ''?"Trucking Down ";button.thisPress
        if button.thisPress <> invalid then
          ?"Move it"
          g.table.selectOffset(1,0)
        end if

    else if(button.bRight) then
        ''?"Trucking Left ";button.thisPress
        if button.thisPress <> invalid then
          ?"Move it"
          g.table.selectOffset(0,1)
        end if

    else if(button.bLeft) then
        ''?"Trucking Right ";button.thisPress
        if button.thisPress <> invalid then
          ?"Move it"
          g.table.selectOffset(0,-1)
        end if

    else if(button.bSelect1) then

      if button.thisPress <> invalid then

        ' Card selected'
        if g.gameState.equals("START_TURN") OR g.gameState.equals("ONE_FLIPPED") then
          theCard = g.table.getSelectedCard()

          ' Check that there is a card in this spot'
          if theCard = invalid:
            ?"Selected invalid card -> Skipping"
            Goto SKIP_THIS_CARD
          end if

          ' Check that this card is not already selected'
          cardAlreadySelected = false
          For each c in g.cardsFlipped
            if c.uid = theCard.uid then
              cardAlreadySelected = true
              ?"Selected Card already selected -> Skipping card"
              theCard = invalid
              Goto SKIP_THIS_CARD
            end if
          end for

          ' Check that this card is in play'
          if (theCard.inPlay = false)  then
           ?"Selected Card not in play -> Skipping card"
           theCard = invalid
           Goto SKIP_THIS_CARD
          end if

          ?"Let's flip this guy!"
          ' TODO prevent from selecting the same card twice on a single turn'
          an = Animation()
          an.state = rg2dStateMachine("ENTER")
          an.target = theCard
          an.target.state.setState("ANIM")
          an.maxTime = 1
          an.UpdateAnimation = theCard.animFlipFunc

          g.am.addAnimation(an)

SKIP_THIS_CARD:

        end if ' Game state start turn or one_flipped'
      end if  ' this press '

    else ' button select'
      'g.truck.ax = 0
      'g.truck.ay = 0
      'g.truck.vx = 'g.truck.vx*truck_v_df
      'g.truck.vy = g.truck.vy*truck_v_df

    end if

    ''''''''''''''''''''''''''''''''''''''''''
    ''''''''''''''''''''''''''''''''''''''''''
    ' State Logic
    ''''''''''''''''''''''''''''''''''''''''''
    ''''''''''''''''''''''''''''''''''''''''''

    if g.gameState.equals("START_GAME") then
      g.gameState.setState("START_TURN")

    else if g.gameState.equals("START_TURN") then
      if(theCard <> invalid) then
        g.gameState.setState("ONE_FLIPPED")
        g.cardsFlipped.push(theCard)
      end if

    else if g.gameState.equals("ONE_FLIPPED") then
      if(theCard <> invalid) then
        g.gameState.setState("TWO_FLIPPED")
        g.cardsFlipped.push(theCard)
      end if

    else if g.gameState.equals("TWO_FLIPPED") then
      For each c in g.cardsFlipped
        ?"Flipped ";c.id
      End For

      if g.cardsFlipped[0].id = g.cardsFlipped[1].id then
        ?"MATCH!!"
        g.gameState.setState("MATCH_FOUND")
      else
        g.gameState.setState("NO_MATCH")
      end if

    else if g.gameState.equals("MATCH_FOUND") then

      ' Match was found wait for animation to complete
      if g.gameState.subState = "ENTRY" then

        doneWithFirstFlipAnim = True
        For each c in g.cardsFlipped
          if c.state.equals("ANIM") then
            doneWithFirstFlipAnim = false
          end if
        end for

        if (g.gameState.timeInSubState > 0.5) AND doneWithFirstFlipAnim then
          g.gameState.setSubState("SHOW_MATCH")
        end if

      else if g.gameState.subState = "SHOW_MATCH" then

        g.gameState.setSubState("ANIMATE_MATCH")

      else if g.gameState.subState = "ANIMATE_MATCH" then
        ' Show the match moving over to the player area'
        For each c in g.cardsFlipped
          c.inPlay = false
          c.dirty = true
        End For
        ' TODO  move cards to PLayer match pile
        c = g.cardsFlipped[0]
        matchCard = g.activeDeck.createCardInstance(c.id)
        matchCard.flipped = True
        g.playerArea_1.setCardToNextSpot(matchCard)

        g.cardsFlipped.clear()

        g.gameState.setState("TURN_OVER")

      end if

      ' TODO check for game over '

    else if g.gameState.equals("NO_MATCH") then

      if g.gameState.subState = "ENTRY" then
      ''?"time in no_match entry ";g.gameState.timeInSubState
        doneWithFirstFlipAnim = True
        For each c in g.cardsFlipped
          if c.state.equals("ANIM") then
            doneWithFirstFlipAnim = false
          end if
        end for


        if (g.gameState.timeInSubState > 0.5) AND doneWithFirstFlipAnim then
          g.gameState.setSubState("FLIP_BACK")
        end if
      else if g.gameState.subState = "FLIP_BACK" then
        g.currentPlayer = (g.currentPlayer + 1) MOD g.numPlayers

        For each c in g.cardsFlipped
          an = Animation()
          an.state = rg2dStateMachine("ENTER")
          an.target = c
          an.target.state.setState("ANIM")
          an.maxTime = 1
          an.UpdateAnimation = c.animFlipFunc

          g.am.addAnimation(an)
        End For

        g.cardsFlipped.clear()
        g.gameState.setState("TURN_OVER")

      end if ' NO_MATCH substate logic'

    else if g.gameState.equals("TURN_OVER") then
      ?"TODO Implement next player turn logic here"

      ?" Check for game over"

      g.gameState.setState("START_TURN")

    else if g.gameState.equals("GAME_OVER") then
      ?"TODO Implement game over logic here"
    end if ''State logic


    return status

end function
