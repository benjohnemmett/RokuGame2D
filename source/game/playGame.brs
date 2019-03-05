function rg2dPlayGame() as object
    g = GetGlobalAA()

    ?"Play Ball!"
    'screen = g.screen
    port = g.port
    'compositor = g.compositor

    g.gameView = g.screenMgr.createView("game")
    g.screenMgr.switchToView("game")

    'Load screen
    'screen.clear(0)
    g.gameView.bmView.clear(&h000000FF) ' TODO encapsulate this -> gameView.clear(0)'
    g.gameView.redraw()
    g.font_registry = CreateObject("roFontRegistry")
    font = g.font_registry.GetDefaultFont()
    g.gameView.bmView.DrawText("Loading...",300, 300, &hFFFFFFFF, font)
    g.gameView.redraw()

    g.dm = DisplayManager(g.gameView)
    g.am = AnimationManager()
    g.om = GameObjectManager() ' Anything that needs to run update'
    g.pm = physModel()

    ' Score, (wave) level
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
    button.thisPress = invalid
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

        rg2dLoadLevel(gs.wave)


        ''''''''''''''''''''''''''''''''''''''''''''''
        ' Enter inner run loop
        ''''''''''''''''''''''''''''''''''''''''''''''
        while true


            'Check for button events
            event = port.GetMessage()
            if (type(event) = "roUniversalControlEvent") then
                id = event.GetInt()

                button.thisPress = id

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
                            'TODO add a confirmation message here
                                sPauseMenu.SetDrawableFlag(false)
                                gs.score = g.game_score
                                gs.wave = g.game_wave
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

                        'compositor.DrawAll()
                        'playGameAddPauseMenu(screen) ' TODO, Not sure what this was doing, determine if something is needed here
                        'screen.SwapBuffers()
                        g.gameView.redraw()
                    end while ' game paused'

                end if 'back pressed'

            end if ' control event'

            ticks = clock.TotalMilliseconds()

            if (ticks >= refreshPeriod)

                dt = ticks/1000

                holdTime = holdButtonClock.TotalMilliseconds()
                status = rg2dInnerGameLoopUpdate(dt, button, holdTime)

                if status.level_complete then
                  ?"Level complete"
                  exit while ' Exit the inner game loop'
                end if

                g.om.update(dt)  ' run update() on all objects '
                g.pm.runphysics(dt) ' run physics on physics objects'
                g.am.updateAnimations(dt) ' Update animations '
                g.dm.updateDisplays(dt) ' Update display'

                g.gameView.redraw()

                clock.Mark()

                button.thisPress = invalid ' reset

            end if  ' if time, Refresh

        end while   ' end inner game loop

        if status.game_complete then
          exit while 'exit level loop & return'
        end if

    end while       ' end level loop

    gs.score = g.game_score
    gs.wave = g.game_wave
    return gs

end function


''''''''''''''''' Level Gen
function rg2dSetupLevel(waveNum, screen) as void

    g = GetGlobalAA()



end function

''' Display game stats
function rg2dUpdateScore(screen) as void
    g = GetGlobalAA()

    ' SCORE
    score = g.game_score ' TODO add clever way to handle displaying extremely high scores... "You maniac!" Message or something
    if score > 9999999 then
        score = 9999999
    end if

    place = 1000000
    ip = 6 ' zero-based

    '?"Score Update";score
    while place >= 10

        v = int(score/place)
        g.scoreSprites[ip].setRegion(g.rScore[v])
        score -= v*place

        place = place /10
        ip -= 1

    end while

    v = int(score)
    g.scoreSprites[0].setRegion(g.rScore[v])

    'WAVE
    wave = g.game_wave
    if wave > 99 then
        wave = 99
    end if

    if( wave > 10) then
        v = int(wave/10)
        g.waveSprites[1].setRegion(g.rScore[v])
    end if

    v = int(wave) mod 10
    g.waveSprites[0].setRegion(g.rScore[v])

    'Num Ships
    nShips = g.ships_left + 1
    if nShips > 99 then
        nShips = 99
    end if

    if( nShips > 10) then
        v = int(nShips/10)
        g.numShipSprites[1].setRegion(g.rScore[v])
    end if

    v = int(nShips) mod 10
    g.numShipSprites[0].setRegion(g.rScore[v])


end function
