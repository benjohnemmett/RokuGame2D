function rg2dPlayGame() as object
    g = GetGlobalAA()
    
    ?"Play Ball!"
    
    screen = g.screen
    port = g.port
    compositor = g.compositor
    
    ' TODO Are these used? m.sWidth is set in main...
    g.screenWidth  = screen.GetWidth()
    g.screenHeight = screen.GetHeight()
    
    'Load screen
    screen.clear(0)
    g.font_registry = CreateObject("roFontRegistry")
    font = g.font_registry.GetDefaultFont() 
    screen.DrawText("Loading...",300, 300, &hFFFFFFFF, font)
    screen.SwapBuffers()
    
    ' Score, (wave) level
    gs = rg2dGameStats(0, 1)
 
    level_state = "Normal"
    g.game_sore = 0
    
    game_paused = false
    'sPauseMenu = compositor.NewSprite(300, 200, g.rPauseScreen, 50)
    'sPauseMenu.SetDrawableFlag(false)
    
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
    
    'g.pm = physModel(compositor)
    
    '''''''''''''' Header stuff
    header_level = 50
    
    scoreTopIndent = 20
    scoreLeftIndent = 80
    scoreSpaces = 7
    

    rg2dGameInit()
    ''''''''''''''''''''''''''''''''''''''''''''''
    ' Main Game Loop
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
                        
                        compositor.DrawAll()
                        'playGameAddPauseMenu(screen) ' TODO, Not sure what this was doing, determine if something is needed here
                        screen.SwapBuffers()
                    
                    end while
                    
                end if
            
            end if
            
            ticks = clock.TotalMilliseconds()
        
            if (ticks > refreshPeriod)
        
                ' Do Controls

                rg2dInnerGameLoopUpdate(button)
                
                dt = ticks/1000
                '?dt
        
                ' Update game state
                'ship.updateState(dt)
                g.pm.runphysics(dt)
                
                ' Update game display
                screen.clear(0)
                
                g.pm.updateDisplay()
                
                compositor.AnimationTick(ticks)
                compositor.DrawAll()
                'updateScore(screen)
                
                screen.SwapBuffers()
                clock.Mark()
                
                
            end if  ' if time, Refresh
        
        end while   ' While True
                
    end while       ' while g.ships_left > 0
    
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


