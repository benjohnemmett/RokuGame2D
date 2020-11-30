' Set global game parameters here.
function rg2dSetGameParameters() as void

    g = GetGlobalAA()

    g.DEBUG = True

    g.highScoreRegister = "GameHighScores"

    g.menuArray = rg2dMenuItemList()
    g.menuArray.addItem("New Game", "new_game")
    g.menuArray.addItem("Options", "options")
    g.menuArray.addItem("High Scores", "high_scores")
    g.menuArray.addItem("About", "about")
    g.menuBgColor = &hAACCFFFF

end function

'
' Load all Sprites Used in the game
'
function rg2dLoadSprites() as void
    g = GetGlobalAA()

    if(g.DEBUG) then
      ?"Loading Sprites..."
    end if

    bmScore = CreateObject("roBitmap", "pkg:/components/sprites/Numbers_Spritesheet_32.png")

    g.rScore = []
    g.rScore[0] = CreateObject("roRegion", bmScore, 0*32, 0, 32, 32)
    g.rScore[1] = CreateObject("roRegion", bmScore, 1*32, 0, 32, 32)
    g.rScore[2] = CreateObject("roRegion", bmScore, 2*32, 0, 32, 32)
    g.rScore[3] = CreateObject("roRegion", bmScore, 3*32, 0, 32, 32)
    g.rScore[4] = CreateObject("roRegion", bmScore, 4*32, 0, 32, 32)
    g.rScore[5] = CreateObject("roRegion", bmScore, 5*32, 0, 32, 32)
    g.rScore[6] = CreateObject("roRegion", bmScore, 6*32, 0, 32, 32)
    g.rScore[7] = CreateObject("roRegion", bmScore, 7*32, 0, 32, 32)
    g.rScore[8] = CreateObject("roRegion", bmScore, 8*32, 0, 32, 32)
    g.rScore[9] = CreateObject("roRegion", bmScore, 9*32, 0, 32, 32)


    bmPauseScreen = CreateObject("roBitmap", "pkg:/components/sprites/Pause_Menu_Screen.png")
    g.rPauseScreen = CreateObject("roRegion", bmPauseScreen, 0, 0, 640, 200)

    'bmTruck = CreateObject("roBitmap", "pkg:/components/sprites/texture_brick01_60p.png")
    'g.rTruck = CreateObject("roRegion", bmTruck, 0, 0, 60, 60)
    g.rTruck = rg2dLoadRegion("pkg:/components/sprites/texture_brick01_60p.png", 0, 0, 60, 60)

end function

'
' Load all sounds used in the game
'
function rg2dLoadSounds() as void
    g = GetGlobalAA()

    if(g.DEBUG) then
      ?"Loading Sounds..."
    end if

    g.sounds ={}
    'g.sounds.ship_engines = CreateObject("roAudioResource", "pkg:/assets/ship_engines.wav")
    g.sounds.navSingle = CreateObject("roAudioResource", "navsingle")

    '?"Max Streams ";g.sounds.astroid_blast.maxSimulStreams()
    g.audioStream = 1
    g.maxAudioStreams = 1 'g.sounds.astroid_blast.maxSimulStreams()

end function

function rg2dLoadFonts() as void

end function

'
' Use this to set custom actions when a menu item is selected
'
function rg2dMenuItemSelected() as void

    g = GetGlobalAA()

    if(g.DEBUG) then
      ?"Menu Item Selected ...";
    end if


    screen = g.screenMgr.getMainScreen()

    selectedMenuOption = g.menuArray.selectedIndex

    shortName = g.menuArray.getSelectedItemShortName()

    if(g.DEBUG) then
      ?"->";shortName
    end if

    if(shortName = "new_game") then ' New Game

        stat = rg2dPlayGame()

    else if(shortName = "options") then ' Settings
        '?"Going to settings screen"
        'rg2dPlaySound(m.sounds.warp_out)
        stat = rg2dOpenSettingsScreen(screen, m.port)
        'rg2dPlaySound(m.sounds.warp_in)

    else if(shortName = "high_scores") then

        'rg2dPlaySound(m.sounds.warp_out)
        stat = rg2dOpenHighScoresScreen(screen, m.port)
        'rg2dPlaySound(m.sounds.warp_in)

    else if(shortName = "about") then

        'rg2dPlaySound(m.sounds.warp_out)
        stat = rg2dOpenCreditScreen(screen, m.port)
        'rg2dPlaySound(m.sounds.warp_in)
    end if


end function


' Stuff that needs to be done at the start of each game goes here.
function rg2dGameInit() as void
    g = GetGlobalAA()

    if(g.DEBUG) then
      ?"rg2dGameInit()..."
    end if

    ' Create Truck
    'g.truck = g.pm.createPhysObj( g.screenWidth/4, g.screenHeight*0.9, 49, 36, "pkg:/components/sprites/firetruck_spritesheetII.png")
    g.truck = gameObject(100, 100)

    g.truck.update = function(dt) ' Called on every frame by the gameObjectManager'
      ''?"Truck Update ";dt
      'm.x += 1
    end function

    g.truck.addComponent(physObj())

    bmTruck = CreateObject("roBitmap", "pkg:/components/sprites/firetruck_spritesheetII.png")
    rTruck = CreateObject("roRegion", bmTruck, 0, 0, 49, 36)
    sTruck = g.gameView.NewSprite(100, 100, rTruck, 1)
    g.truck.addComponent(DisplayComp(sTruck))

    g.om.addGameObj(g.truck)
    g.pm.addPhysObj(g.truck)
    g.dm.addDisplayObj(g.truck)

end function


'''''''''' OUTER LOOP STUFF
' Stuff to be done at the start of each level goes here.
function rg2dLoadLevel(level as integer) as void
    g = GetGlobalAA()
    if(g.DEBUG) then
      ?"rg2dLoadLevel()..."
    end if
end function

' Stuff to be done at the start of each update loop goes here.
function rg2dInnerGameLoopUpdate(dt as float, button, holdTime) as object
    g = GetGlobalAA()
    if(g.DEBUG) AND dt > 0.04 then
      ?"rg2dInnerGameLoopUpdate long frame ";dt;"..."
    end if

    status = rg2dStatus()

    truck_acc = 200
    truck_v_df = 0.8

    if(button.bUp) then
        ?"Trucking Up"
        g.truck.ay = -truck_acc

    else if(button.bDown) then
        ?"Trucking Down"
        g.truck.ay = truck_acc

    else if(button.bRight) then
        ?"Trucking Left"
        g.truck.ax = truck_acc

    else if(button.bLeft) then
        ?"Trucking Right"
        g.truck.ax = -truck_acc

    else if(button.bSelect1) then
        ?"Fire!"
        an = Animation()
        an.target = g.truck
        an.maxTime = 1
        an.UpdateAnimation = function(dt)
          ?"animating truck ";m.fn;" ";m.t
          m.target.x += 1
          m.target.y += 1
        end function

        g.am.addAnimation(an)
    else
      g.truck.ax = 0
      g.truck.ay = 0
      g.truck.vx = g.truck.vx*truck_v_df
      g.truck.vy = g.truck.vy*truck_v_df

    end if

    return status

end function
