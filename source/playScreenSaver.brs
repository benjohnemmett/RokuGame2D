function playScreenSaver(gdef) as object
    g = GetGlobalAA()

    ?"Play Screen saver!"

    screen = g.screen
    port = g.port
    'compositor = g.compositor

    ' TODO Are these used? m.sWidth is set in main...
    g.screenWidth  = screen.GetWidth()
    g.screenHeight = screen.GetHeight()

    'Load screen
    screen.clear(0)

    dfDrawImage(g.screen, "pkg:/images/snowbattle_load_screen.jpg", 0, 0)
    screen.SwapBuffers()

    ' Score, (wave) level
    gs = rg2dGameStats(0, 1)

    level_state = "Normal"
    g.game_sore = 0

    game_paused = false


    'Audio
    ' Play Background music
    g.audioManager.stop() ' Stop what was playing'
    ?"Playing ";gdef.songURL
    if gdef.songURL = invalid then
      g.audioManager.playDefaultSong()
    else
      g.audioManager.playsong(gdef.songURL)
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

    'g.pm = physModel(g.compositor) ' Now created in main no in playGame'

    '''''''''''''' Header stuff
    header_level = 50

    scoreTopIndent = 20
    scoreLeftIndent = 80
    scoreSpaces = 7


    rg2dGameInit(gdef)
    ''''''''''''''''''''''''''''''''''''''''''''''
    ' Main Game Loop
    ''''''''''''''''''''''''''''''''''''''''''''''
    while true
        ?"Loading Level ";gs.wave
        g.compositor = invalid

        g.compositor = CreateObject("roCompositor")
        g.compositor.SetDrawTo(g.screen, g.bgColor)

        g.pm.setCompositor(g.compositor)

        sPauseMenu = g.compositor.NewSprite(300, 200, g.rPauseScreen, g.layers.pauseScreen)
        'sPauseMenu = g.compositor.NewSprite(300, 200, g.rPauseScreen, 50)
        sPauseMenu.SetDrawableFlag(false)

        ' Exit when set number of rounds has been played'
        if(gs.wave > gdef.rounds) then
          exit while
        end if

        loadScreenSaver()

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
                        g.audioManager.pause()
                    end if

                    while game_paused

                        event = port.GetMessage()
                        if (type(event) = "roUniversalControlEvent") then
                            id = event.GetInt()
                            if (id = myCodes.BACK_PRESSED) then
                            '   Exit game
                            'TODO add a confirmation message here
                                sPauseMenu.SetDrawableFlag(false)
                                gs.score = g.game_score
                                gs.wave = g.game_wave
                                gs.winningPlayer = -1
                                return gs

                            else if (id = myCodes.PLAY_PRESSED)  then
                                game_paused = false
                                sPauseMenu.SetDrawableFlag(false)

                                if(g.settings.music = "On") then
                                    g.audioManager.resume()
                                end if

                                clock.Mark()

                            end if
                        end if

                        g.compositor.DrawAll()
                        'playGameAddPauseMenu(screen) ' TODO, Not sure what this was doing, determine if something is needed here
                        screen.SwapBuffers()

                    end while

                end if

            end if

            ticks = clock.TotalMilliseconds()

            if (ticks > refreshPeriod)

                ' Do Controls


                dt = ticks/1000

                hold_time = holdButtonClock.TotalMilliseconds()
                'stat = rg2dInnerGameLoopUpdate(dt, button, hold_time)
                g.snowMaker.run(dt)

                'Update Mouse'
                'g.mouseController.update(dt)

                ' Update game state
                'ship.updateState(dt)
                g.pm.runphysics(dt)

                ' Update game display
                screen.clear(g.bgColor)

                g.pm.updateDisplay()

                g.compositor.AnimationTick(ticks)
                g.compositor.DrawAll()
                'updateScore(screen)

                screen.SwapBuffers()
                clock.Mark()


            end if  ' if time, Refresh

        end while   ' While True

    end while       ' while g.ships_left > 0

    return gs

end function
