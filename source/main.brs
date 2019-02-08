Library "v30/bslDefender.brs"

function Main() as void

    g = m
    '''''''''''''''''''''''''''''''''
    '''' GENERAL SETUP
    g.screenWidth = 1280
    g.screenHeight = 720

    '''''''''''''''''''''''''''''''''
    'Load up custom game paramters
    rg2dSetGameParameters()

    '''''''''''''''''''''''''''''''''
    ' Create Key Components

    ' Scoreboard, load saved scores if available
    g.scoreBoard = rg2dScoreBoard()
    g.scoreBoard.loadScoreBoard()

    g.port = CreateObject("roMessagePort")

    g.screenMgr = screenManager()
    screen = g.screenMgr.getMainScreen()

    'g.screen = CreateObject("roScreen", true, g.screenWidth, g.screenHeight)
    'g.screen.SetAlphaEnable(true)
    screen.SetMessagePort(g.port)

    'g.compositor = CreateObject("roCompositor")
    'g.compositor.SetDrawTo(g.screen, g.menuBgColor)

    g.mainView = g.screenMgr.createView("main")

    'g.bmMainScreen = CreateObject("roBitmap", {width:g.screenWidth, height:g.screenWidth, AlphaEnable:True})
    'g.rgMainScreen = CreateObject("roRegion", g.bmMainScreen, 0, 0, g.screenWidth, g.screenWidth)
    'g.spMainScreen = g.compositor.NewSprite(0, 0, g.rgMainScreen, 1)


    g.pm = physModel(g.compositor)

    ' Settings
    g.settings = rg2dGameSettings()

    'g.settings.setControls("H") ' Change the controls to horizontal
    myCodes = g.settings.controlCodes

    ' Audio
    g.audioPlayer = CreateObject("roAudioPlayer")
    g.audioPort = CreateObject("roMessagePort")
    g.audioPlayer.SetMessagePort(g.audioPort)

    ' Load Sounds in to g.sounds array
    rg2dLoadSounds()

    ' Load images
    rg2dLoadSprites()

    'Load Fonts'
    rg2dLoadFonts()


    '''''''''''''''''''''''''''''''''
    '''' MAIN Menu
    rg2dSetupMainScreen()

    while true
        event = g.port.GetMessage()

        if (type(event) = "roUniversalControlEvent") then
            id = event.GetInt()

            if (id = myCodes.MENU_UP_A) or (id = myCodes.MENU_UP_B) then

                rg2dPlaySound(g.sounds.navSingle)
                g.menuArray.moveSelectionUp()
                rg2dSetupMainScreen()

            else if(id = myCodes.MENU_DOWN_A) or (id = myCodes.MENU_DOWN_B)then

                rg2dPlaySound(g.sounds.navSingle)
                g.menuArray.moveSelectionDown()
                rg2dSetupMainScreen()

            else if(id = myCodes.SELECT1A_PRESSED) or (id = myCodes.SELECT1B_PRESSED) or (id = myCodes.SELECT2_PRESSED)

                rg2dMenuItemSelected()
                rg2dSetupMainScreen()

            else if(id = myCodes.BACK_PRESSED) then
                ' Exit Game
                return
            end if
        end if

    end while

end function

'' Main Menu helper function
function rg2dSetupMainScreen() as void

    g = GetGlobalAA()

    g.mainView.bmView.clear(&h33333333)

    numMenuOptions = g.menuArray.getCount()
    selectedMenuOption = g.menuArray.selectedIndex

    g.font_registry = CreateObject("roFontRegistry")
    font = g.font_registry.GetDefaultFont(56, True, false)

    regColor = &hFFFFFFFF
    selColor = &hFFFF22FF

    topIndent = 320
    leftIndent = 400
    vertSpace = font.GetOneLineHeight() + 10

    for t = 0 to (numMenuOptions -1)
        if(t = selectedMenuOption) then
            g.mainView.bmView.DrawText(g.menuArray.getItemName(t),leftIndent + 20,topIndent + t*vertSpace,selColor,font)
        else
            g.mainView.bmView.DrawText(g.menuArray.getItemName(t),leftIndent, topIndent + t*vertSpace,regColor,font)
        end if

    end for

    g.mainView.redraw()

end function
