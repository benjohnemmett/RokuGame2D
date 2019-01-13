function rg2dOpenHighScoresScreen(subScreen, subPort) as void
    g = GetGlobalAA()

    rg2dSetupHighScoreScreen(subScreen, false)

    codes = bslUniversalControlEventCodes()

'    myCodes = m.settings.controlCodes

    while true
        event = subPort.GetMessage()

        if (type(event) = "roUniversalControlEvent") then
            id = event.GetInt()
            if(id = codes.BUTTON_INFO_PRESSED) then

                rg2dSetupHighScoreScreen(subScreen, true)

                while true
                    event = subPort.GetMessage()

                    if (type(event) = "roUniversalControlEvent") then
                        id = event.GetInt()
                        if(id = codes.BUTTON_SELECT_PRESSED) then

                            g.scoreBoard.clearScoreBoard()
                            g.scoreBoard.saveScoreBoard()
                            exit while

                        else if(id = codes.BUTTON_BACK_PRESSED)
                            exit while

                        end if

                    end if
                end while

            rg2dSetupHighScoreScreen(subScreen, false)

            else if(id = codes.BUTTON_BACK_PRESSED) or (id = codes.BUTTON_SELECT_PRESSED) or (id = 17) or (id = 18)

                return

            end if
        end if
    end while


end function

function rg2dSetupHighScoreScreen(subScreen, clear) as Integer
    g = GetGlobalAA()

    'Print to debug console
    'g.scoreBoard.printHighScores()

    subScreen.clear(0)

    'Screen stuff
    dfDrawImage(subScreen, "pkg:/assets/Asteroid_Menu_BG.png", 0, 0)
    dfDrawImage(subScreen, "pkg:/assets/Asteroid_Menu_Title_910_187.png", 200, 100)
    
    head_font = g.font_registry.GetDefaultFont(36, true, false)
    font = g.font_registry.GetDefaultFont(26, false, false)

    regColor = &hFFFFFFFF
    selColor = &h0000FFFF

    topIndent = 360
    leftIndent = 500
    vertSpace = font.GetOneLineHeight()

    subScreen.DrawText("High Scores", leftIndent + 25, topIndent - 40, regColor, head_font)

    if(m.scoreBoard.topGames.count() > 0) then

        i = 0
        for each g in m.scoreBoard.topGames

            place = i + 1

            if(place < 10) then
                s = Substitute( "[ {0}]  {1}      {2}", place.tostr(), g.playerName, g.score.tostr() ) 'Not sure why eclipse thinks there is an error here
            else
                s = Substitute( "[{0}]   {1}      {2}", place.tostr(), g.playerName, g.score.tostr() ) 'Not sure why eclipse thinks there is an error here
            end if
            subScreen.DrawText(  s, leftIndent, topIndent + vertSpace*i,regColor, font)
            i += 1
        end for

    else

        subScreen.DrawText(" -- No High Scores Recorded -- ", 460, topIndent + vertSpace,regColor, font)

    end if

    dfDrawImage(subScreen, "pkg:/assets/Astroblast_Clear_High_Score_275_40.png", 880, 600)

    if(clear = true) then

        dfDrawImage(subScreen, "pkg:/assets/Astroblast_Clear_High_Score_Warning.png", 300, 200)

    end if

    subScreen.SwapBuffers()

    return 0

end function
