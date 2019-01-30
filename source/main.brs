Library "v30/bslDefender.brs"

function Main() as void

    '''''''''''''''''''''''''''''''''
    '''' GENERAL SETUP
    m.sWidth = 1280
    m.sHeight = 720

    '''''''''''''''''''''''''''''''''
    'Load up custom game paramters
    rg2dSetGameParameters()

    '''''''''''''''''''''''''''''''''
    ' Create Key Components

    ' Scoreboard, load saved scores if available
    m.scoreBoard = rg2dScoreBoard()
    m.scoreBoard.loadScoreBoard()

    m.port = CreateObject("roMessagePort")

    m.screen = CreateObject("roScreen", true, m.sWidth, m.sHeight)
    m.screen.SetAlphaEnable(true)
    m.screen.SetMessagePort(m.port)

    m.compositor = CreateObject("roCompositor")
    m.compositor.SetDrawTo(m.screen, &h000000FF)

    'PHysics model is passed as a global variable'
    m.pm = physModel(m.compositor)

    ' Settings
    m.settings = rg2dGameSettings()

    'm.settings.setControls("H") ' Change the controls to horizontal
    myCodes = m.settings.controlCodes

    ' Audio
    m.audioManager = audioManager()

    ' Load Sounds in to m.sounds array
    rg2dLoadSounds()

    ' Load images
    rg2dLoadSprites()

    ' Load fonts'
    rg2dLoadFonts()

    '''''''''''''''''''''''''''''''''
    '''' MAIN Menu
    rg2dSetupMainScreen()
    URLLibSetup()
    success = URLLibGetAsync("https://462fhdcle1.execute-api.us-east-1.amazonaws.com/default/MouseMessageMaker")
    ''?"URL Send Success ";success

    while true
        event = m.port.GetMessage()

        if (type(event) = "roUniversalControlEvent") then
            id = event.GetInt()

            if (id = myCodes.MENU_UP_A) or (id = myCodes.MENU_UP_B) then

                rg2dPlaySound(m.sounds.navSingle)
                m.menuArray.moveSelectionUp()
                rg2dSetupMainScreen()

            else if(id = myCodes.MENU_DOWN_A) or (id = myCodes.MENU_DOWN_B)then

                rg2dPlaySound(m.sounds.navSingle)
                m.menuArray.moveSelectionDown()
                rg2dSetupMainScreen()

            else if(id = myCodes.SELECT1A_PRESSED) or (id = myCodes.SELECT1B_PRESSED) or (id = myCodes.SELECT2_PRESSED)

                rg2dMenuItemSelected()
                rg2dSetupMainScreen()

            else if(id = myCodes.BACK_PRESSED) then
                ' Exit Game
                return
            end if
        else if (type(event) = "roUrlEvent") then
          ?"Got URL EVENT"
          URLLibHandleUrlEvent(event)

          ?event.getstring()
          mouseMessageData = ParseJson(event.getstring())
          ?mouseMessageData
          if mouseMessageData <> invalid then
            setMouseMessageData(mouseMessageData)
          end if

        end if

    end while

end function

'' Main Menu helper function
function rg2dSetupMainScreen() as void

    g = GetGlobalAA()

    g.screen.clear(0)
    g.compositor.DrawAll()

    numMenuOptions = g.menuArray.getCount()
    selectedMenuOption = g.menuArray.selectedIndex

    'font = g.font_registry.GetDefaultFont(56, True, false)
    font = g.font_registry.GetFont("Almonte Snow", 56, false, false)

    regColor = &h96a3b7FF
    selColor = &h366cbcFF

    topIndent = 200
    leftIndent = 450
    vertSpace = font.GetOneLineHeight() + 8
    g.screen.DrawRect(leftIndent-50, topIndent-30, 1280-2*(leftIndent-50), 720-2*(topIndent-80), &hFFFFFFCC)

    for t = 0 to (numMenuOptions -1)
        if(t = selectedMenuOption) then
            g.screen.DrawText(g.menuArray.getItemName(t),leftIndent + 20,topIndent + t*vertSpace,selColor,font)
        else
            g.screen.DrawText(g.menuArray.getItemName(t),leftIndent, topIndent + t*vertSpace,regColor,font)
        end if
    end for

    g.screen.swapBuffers()

    g.audioManager.playSong(g.songURLS.makeMyDay_local)


end function
