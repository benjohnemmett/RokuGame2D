Library "v30/bslDefender.brs"

function Main() as void

    m.sWidth = 1280    
    m.sHeight = 720
    
    m.port = CreateObject("roMessagePort")
    
    ' Settings
    m.settings = gameSettings()
    m.settings.setControls("H")
    myCodes = m.settings.controlCodes
    
    ' Audio
    m.audioPlayer = CreateObject("roAudioPlayer")
    m.audioPort = CreateObject("roMessagePort")
    m.audioPlayer.SetMessagePort(m.audioPort)
    
    ' Load Sounds in to m.sounds array
    loadSounds()
    
    ' Load images
    loadSprites()
    
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
    m.compositor.SetDrawTo(m.screen, &h11AA11FF)
                    
    menu_indent = 300
    menu_top = 300
    menu_spacing = 100
                    
    setupMainScreen(menuArray, selectedMenuOption)
    
    while true        
        event = m.port.GetMessage()
        if (type(event) = "roUniversalControlEvent") then
            id = event.GetInt()
            '?id
            if (id = myCodes.MENU_UP_A) or (id = myCodes.MENU_UP_B) then
                
                playSound(m.sounds.navSingle)
                
                selectedMenuOption = selectedMenuOption - 1
                if(selectedMenuOption < 0) then
                    selectedMenuOption = numMenuOptions -1
                end if
                
                setupMainScreen(menuArray, selectedMenuOption)
            
            else if(id = myCodes.MENU_DOWN_A) or (id = myCodes.MENU_DOWN_B)then
                
                playSound(m.sounds.navSingle)
                selectedMenuOption = (selectedMenuOption + 1) MOD numMenuOptions
                setupMainScreen(menuArray, selectedMenuOption)
                
            else if(id = myCodes.SELECT1A_PRESSED) or (id = myCodes.SELECT1B_PRESSED) or (id = myCodes.SELECT2_PRESSED)
                
                if(selectedMenuOption = 0) then ' New Game
                    
                    stat = playGame()
                    
                else if(selectedMenuOption = 1) then ' Settings
                    '?"Going to settings screen"
                    'playSound(m.sounds.warp_out)
                    stat = openSettingsScreen(m.screen, m.port)
                    'playSound(m.sounds.warp_in)
                
                else if(selectedMenuOption = 2) then
                    
                    'playSound(m.sounds.warp_out)
                    stat = openHighScoresScreen(m.screen, m.port)
                    'playSound(m.sounds.warp_in)
                
                else if(selectedMenuOption = 3) then
                
                    'playSound(m.sounds.warp_out)
                    stat = openCreditScreen(m.screen, m.port) 
                    'playSound(m.sounds.warp_in)
                end if

                setupMainScreen(menuArray, selectedMenuOption)
'                setupMainScreenSprites(menuArray, selectedMenuOption, m.screen, compositor, menuSprites)
            else if(id = myCodes.BACK_PRESSED) then
                ' Exit Game
                return
            end if
        end if
        
        
        
    end while
    
end function

function setupMainScreen(menuArray, selectedMenuOption) as void

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
