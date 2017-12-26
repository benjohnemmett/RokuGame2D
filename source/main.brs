Library "v30/bslDefender.brs"

#const debug = true

function Main() as void

    #if debug
        ?" *** Debug flag enabled ***"
    #end if
    

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
    
    m.screen = CreateObject("roScreen", true, m.sWidth, m.sHeight)
    m.screen.SetAlphaEnable(true)
    m.screen.SetMessagePort(m.port)
    
    m.compositor = CreateObject("roCompositor")
    m.compositor.SetDrawTo(m.screen, &h000000FF)
                    
    rg2dSetupMainScreen()
    
    while true        
        event = m.port.GetMessage()
        
        if (type(event) = "roUniversalControlEvent") then
            id = event.GetInt()
            #if debug
                ?id
            #end if
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
        end if
        
        
        
    end while
    
end function

function rg2dSetupMainScreen() as void

    g = GetGlobalAA()
    
    m.screen.clear(0)
    g.compositor.DrawAll()
    
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
            g.screen.DrawText(g.menuArray.getItemName(t),leftIndent + 20,topIndent + t*vertSpace,selColor,font)
        else
            g.screen.DrawText(g.menuArray.getItemName(t),leftIndent, topIndent + t*vertSpace,regColor,font)
        end if
    
    end for
    
    g.screen.swapBuffers()

end function
