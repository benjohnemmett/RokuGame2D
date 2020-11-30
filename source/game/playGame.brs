function rg2dPlayGame() as object
    g = GetGlobalAA()

    ?"Play Ball!"
    port = g.port

    g.gameView = g.screenMgr.createView("game")
    g.screenMgr.switchToView("game")

    'Load screen
    g.gameView.bmView.clear(&h000000FF) ' TODO encapsulate this -> gameView.clear(0)'
    g.gameView.redraw()
    g.font_registry = CreateObject("roFontRegistry")
    font = g.font_registry.GetDefaultFont()
    g.gameView.bmView.DrawText("Loading...",300, 300, &hFFFFFFFF, font)
    g.gameView.redraw()

    g.dm = DisplayManager(g.gameView)
    g.AnimationManager = AnimationManager()
    g.om = GameObjectManager() ' Anything that needs to run update'
    g.pm = physModel()

    ' Score, level
    gs = rg2dGameStats(0, 1)

    level_state = "Normal"
    g.game_sore = 0

    game_paused = false
    sPauseMenu = g.gameView.NewSprite(300, 200, g.rPauseScreen, 50)
    sPauseMenu.SetDrawableFlag(false)

    'Audio
    ' Play Background music
    if(g.settings.music = "On") then
        ?"Play that funky music!!!"
        g.audioplayer.setContentList([{url:"pkg:/components/audio/happy_loop.mp3"}])
        g.audioplayer.setloop(true)
        g.audioPlayer.play()
    else
        g.audioPlayer.Stop()
    end if

    refreshPeriod = 20 ' ms

    'Button Stuff
    button = {}
    button.bUp = false
    button.bDown = false
    button.bLeft = false
    button.bRight = false
    button.bPlay = false
    button.bSelect1 = false
    button.bSelect2 = false
    codes = bslUniversalControlEventCodes()
    myCodes = g.settings.controlCodes

    clock = CreateObject("roTimespan")
    holdButtonClock = CreateObject("roTimespan")

    clock.Mark()


    g.gameView.bmView.clear(&h000000FF) ' TODO encapsulate this -> gameView.clear(0)'
    rg2dGameInit()
    ''''''''''''''''''''''''''''''''''''''''''''''
    ' Level Loop
    ''''''''''''''''''''''''''''''''''''''''''''''
    while true

        rg2dLoadLevel(gs.level)

        ''''''''''''''''''''''''''''''''''''''''''''''
        ' Enter inner run loop
        ''''''''''''''''''''''''''''''''''''''''''''''
        while true

            'Check for button events
            event = port.GetMessage()
            if (type(event) = "roUniversalControlEvent") then
                id = event.GetInt()
                if (id = myCodes.RIGHT_PRESSED) then
                    '?"Right Button Down"
                    button.bRight = true
                    holdButtonClock.Mark()
                else if (id = myCodes.LEFT_PRESSED) then
                    '?"Left Button Down"
                    button.bLeft = true
                    holdButtonClock.Mark()
                else if (id = myCodes.UP_PRESSED) then
                    '?"Up Button Down"
                    button.bUp = true
                    holdButtonClock.Mark()
                else if (id = myCodes.DOWN_PRESSED) then
                    '?"Down Button Down"
                    button.bDown = true
                    holdButtonClock.Mark()
                else if (id = myCodes.SELECT2_PRESSED) then
                    '?"Green Button Down"
                    button.bSelect2 = true
                    holdButtonClock.Mark()
                else if (id = myCodes.SELECT1A_PRESSED) or (id = myCodes.SELECT1B_PRESSED) then
                    '?"Blue Button Down"
                    button.bSelect1 = true
                    holdButtonClock.Mark()
                else if (id = myCodes.RIGHT_RELEASED) then
                    '?"Right Button Released"
                    button.bRight = false
                else if (id = myCodes.LEFT_RELEASED) then
                    '?"Left Button Released"
                    button.bLeft = false
                else if (id = myCodes.UP_RELEASED) then
                    '?"Up Button Released"
                    button.bUp = false
                else if (id = myCodes.DOWN_RELEASED) then
                    '?"Down Button Released"
                    button.bDown = false
                else if (id = myCodes.PLAY_RELEASED) then
                    '?"Play Button Released"
                    button.bPlay = false
                else if (id = myCodes.SELECT2_RELEASED) then
                    '?"Green Button Released"
                    button.bSelect2 = false
                else if (id = myCodes.SELECT1A_RELEASED) or (id = myCodes.SELECT1B_RELEASED)  then
                    '?"Blue Button Released"
                    button.bSelect1 = false
                else if (id = myCodes.BACK_PRESSED) or (id = myCodes.PLAY_PRESSED) then

                    'Pause game
                    game_paused = true
                    sPauseMenu.SetDrawableFlag(true)

                    if(g.settings.music = "On") then
                        g.audioPlayer.pause()
                    end if

                    while game_paused

                        event = port.GetMessage()
                        if (type(event) = "roUniversalControlEvent") then
                            id = event.GetInt()
                            if (id = myCodes.BACK_PRESSED) then
                            '   Exit game
                                sPauseMenu.SetDrawableFlag(false)
                                gs.score = g.gameScore
                                gs.level = g.gameLevel
                                return gs

                            else if (id = myCodes.PLAY_PRESSED)  then
                                game_paused = false
                                sPauseMenu.SetDrawableFlag(false)

                                if(g.settings.music = "On") then
                                    g.audioPlayer.resume()
                                end if

                                clock.Mark()

                            end if
                        end if

                        g.gameView.redraw()
                    end while

                end if

            end if

            ticks = clock.TotalMilliseconds()

            if (ticks >= refreshPeriod)

                dt = ticks/1000

                holdTime = holdButtonClock.TotalMilliseconds()
                status = rg2dInnerGameLoopUpdate(dt, button, holdTime)

                if status.level_complete then
                  ?"Level complete"
                  exit while ' Exit the inner game loop'
                end if

                g.om.update(dt)  ' run update() on all objects
                g.pm.runphysics(dt) ' run physics on physics objects
                g.AnimationManager.updateAnimations(dt) ' Update animations
                g.dm.updateDisplays(dt) ' Update display

                g.gameView.redraw()

                clock.Mark()

            end if  ' if time, Refresh

        end while   ' end inner game loop

        if status.game_complete then
          exit while 'exit level loop & return'
        end if

    end while       ' end level loop

    gs.score = g.gameScore
    gs.level = g.gameLevel
    return gs

end function
