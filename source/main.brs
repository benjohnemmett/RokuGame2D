Library "v30/bslDefender.brs"

function Main() as void

    'Load up custom game paramters
    rg2dSetGameParameters()
    
    'Create Scoreboard, load saved scores if available
    m.scoreBoard = rg2dScoreBoard()
    m.scoreBoard.loadScoreBoard()

    m.sWidth = 1280    
    m.sHeight = 720
    
    m.port = CreateObject("roMessagePort")
    
    ' Settings
    m.settings = rg2dGameSettings()
    'm.settings.setControls("H") ' Change the controls to horizontal 
    myCodes = m.settings.controlCodes
    
    ' Audio
    m.audioPlayer = CreateObject("roAudioPlayer")
    m.audioPort = CreateObject("roMessagePort")
    m.audioPlayer.SetMessagePort(m.audioPort)
    
    ' Load Sounds in to m.sounds array
    rg2dLoadSounds()
    
    ' Load images
    rg2dLoadSprites()
    
    menuArray = ["New Game",
                    "Options",
                    "High Scores",
                    "About"]
    numMenuOptions = menuArray.Count()
    
    m.screen = CreateObject("roScreen", true, m.sWidth, m.sHeight)
    m.screen.SetAlphaEnable(true)
    m.screen.SetMessagePort(m.port)
    selectedMenuOption = 0
    
    m.compositor = CreateObject("roCompositor")
    m.compositor.SetDrawTo(m.screen, &h000000FF)
                    
    menu_indent = 300
    menu_top = 300
    menu_spacing = 100
                    
    rg2dSetupMainScreen(menuArray, selectedMenuOption)
    
    while true        
        event = m.port.GetMessage()
        
        if (type(event) = "roUniversalControlEvent") then
            id = event.GetInt()
            '?id
            if (id = myCodes.MENU_UP_A) or (id = myCodes.MENU_UP_B) then
                
                rg2dPlaySound(m.sounds.navSingle)
                
                selectedMenuOption = selectedMenuOption - 1
                if(selectedMenuOption < 0) then
                    selectedMenuOption = numMenuOptions -1
                end if
                
                rg2dSetupMainScreen(menuArray, selectedMenuOption)
            
            else if(id = myCodes.MENU_DOWN_A) or (id = myCodes.MENU_DOWN_B)then
                
                rg2dPlaySound(m.sounds.navSingle)
                selectedMenuOption = (selectedMenuOption + 1) MOD numMenuOptions
                rg2dSetupMainScreen(menuArray, selectedMenuOption)
                
            else if(id = myCodes.SELECT1A_PRESSED) or (id = myCodes.SELECT1B_PRESSED) or (id = myCodes.SELECT2_PRESSED)
                
                if(selectedMenuOption = 0) then ' New Game
                    
                    stat = playGame()
                    
                else if(selectedMenuOption = 1) then ' Settings
                    '?"Going to settings screen"
                    'rg2dPlaySound(m.sounds.warp_out)
                    stat = rg2dOpenSettingsScreen(m.screen, m.port)
                    'rg2dPlaySound(m.sounds.warp_in)
                
                else if(selectedMenuOption = 2) then
                    
                    'rg2dPlaySound(m.sounds.warp_out)
                    stat = rg2dOpenHighScoresScreen(m.screen, m.port)
                    'rg2dPlaySound(m.sounds.warp_in)
                
                else if(selectedMenuOption = 3) then
                
                    'rg2dPlaySound(m.sounds.warp_out)
                    stat = rg2dOpenCreditScreen(m.screen, m.port) 
                    'rg2dPlaySound(m.sounds.warp_in)
                end if

                rg2dSetupMainScreen(menuArray, selectedMenuOption)
            else if(id = myCodes.BACK_PRESSED) then
                ' Exit Game
                return
            end if
        end if
        
        
        
    end while
    
end function

function rg2dSetupMainScreen(menuArray, selectedMenuOption) as void

    g = GetGlobalAA()
    
    m.screen.clear(0)
    g.compositor.DrawAll()
    
    numMenuOptions = menuArray.count() 
    
    
    g.font_registry = CreateObject("roFontRegistry")
    font = g.font_registry.GetDefaultFont(56, True, false) 
    
    regColor = &hFFFFFFFF
    selColor = &hFFFF22FF
    
    topIndent = 320
    leftIndent = 400
    vertSpace = font.GetOneLineHeight() + 10

    
    for t = 0 to (numMenuOptions -1)
        if(t = selectedMenuOption) then
            m.screen.DrawText(menuArray[t],leftIndent + 20,topIndent + t*vertSpace,selColor,font)
        else
            m.screen.DrawText(menuArray[t],leftIndent,topIndent + t*vertSpace,regColor,font)
        end if
    
    end for
    
    m.screen.swapBuffers()

end function
