' TODO should these all be subs, not returning anything? Any advantage to subs?

' Set global game parameters here.
function rg2dSetGameParameters() as void

    g = GetGlobalAA()

    g.USING_LB_CODE = false
    g.DEBUG = True

    g.highScoreRegister = "GameHighScores"

    g.menuArray = rg2dMenuItemList()
    g.menuArray.addItem("New Game", "new_game")
    g.menuArray.addItem("Options", "options")
    g.menuArray.addItem("High Scores", "high_scores")
    g.menuArray.addItem("About", "about")

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
    g.rTruck = rg2dLoadRegion("pkg:/components/sprites/firetruck_spritesheetII.png", 0, 0, 49, 36)
    g.rBricks = rg2dLoadRegion("pkg:/components/sprites/texture_brick01_60p.png", 0, 0, 60, 60)
    g.rCircleFire16 = rg2dLoadRegion("pkg:/components/sprites/circle_fire_16p.png", 0, 0, 16, 16)
    g.rCircleGrey8 = rg2dLoadRegion("pkg:/components/sprites/circle_grey_8p.png", 0, 0, 8, 8)

    ' Kenny's stuff
    g.rSnowBall = rg2dLoadRegion("pkg:/components/sprites/snowball_p21.png", 0, 0, 21, 21)
    'g.rTerrain_ice = rg2dLoadRegion("pkg:/components/sprites/terrain_ice_288_44.png", 0, 0, 288, 44)
    g.rIgloo_right = rg2dLoadRegion("pkg:/components/sprites/igloo_right_63_42.png", 0, 0, 63, 42)
    g.rIgloo_left = rg2dLoadRegion("pkg:/components/sprites/igloo_left_63_42.png", 0, 0, 63, 42)

    g.rFlagRed = rg2dLoadRegion("pkg:/components/sprites/Flag_red_white.png", 0, 0, 40, 30)
    g.rFlagBlue = rg2dLoadRegion("pkg:/components/sprites/Flag_orange_blue.png", 0, 0, 40, 30)

    g.terrain_ice = createTerrain("pkg:/components/sprites/terrain_ice_288_44.png")

    if(g.USING_LB_CODE) then
        LBLoadSprites()
    end if

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

'
' Use this to set custom actions when a menu item is selected
'
function rg2dMenuItemSelected() as void

    g = GetGlobalAA()

    if(g.DEBUG) then
      ?"Menu Item Selected ...";
    end if

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
        stat = rg2dOpenSettingsScreen(m.screen, m.port)
        'rg2dPlaySound(m.sounds.warp_in)

    else if(shortName = "high_scores") then

        'rg2dPlaySound(m.sounds.warp_out)
        stat = rg2dOpenHighScoresScreen(m.screen, m.port)
        'rg2dPlaySound(m.sounds.warp_in)

    else if(shortName = "about") then

        'rg2dPlaySound(m.sounds.warp_out)
        stat = rg2dOpenCreditScreen(m.screen, m.port)
        'rg2dPlaySound(m.sounds.warp_in)
    end if

end function


' Stuff that needs to be done at the start of each game goes here.
function rg2dGameInit() as void
    g = GetGlobalAA()

    g.bgColor = &h112233FF

end function


'''''''''' OUTER LOOP STUFF
' Stuff to be done at the start of each level goes here.
function rg2dLoadLevel(level as integer) as void
    g = GetGlobalAA()

    ''Moved from game init
    ' Create Truck
    g.tank1 = createTank(1, true, 100, g.sHeight-200, 0, true, "igloo") ' TODO Flip this one
    g.tank2 = createTank(2, false, g.sWidth-100, g.sHeight-200,0, false, "igloo")

    g.tank1.bmFlag.setFlagImage(g.rFlagRed)
    g.tank2.bmFlag.setFlagImage(g.rFlagBlue)

    g.pogTanks = g.pm.createPhysObjGroup()
    g.pogProjs = g.pm.createPhysObjGroup()
    g.pogTerr = g.pm.createPhysObjGroup()

    g.pogTanks.addPhysObj(g.tank1)
    g.pogTanks.addPhysObj(g.tank2)

    cpTankProj = g.pm.createCollisionPair(g.pogTanks,g.pogProjs)

    cpTankProj.overlapCallback = function(t,p) as integer

      if(p.ttl > 29) then

        ?"Projectile must be firing still!";p.ttl
        return 1
      end if
      if p.state = "ALIVE" then
        ?"Projectile Hit Tank!"
        t.takeDamage(10)
        p.ttl = 0.0
        p.state = "DEAD"
        p.NotifyOwnerOfCollision(t)
      end if

      return 1 ' Indicate not to perform normal collision

    end function

    if(g.USING_LB_CODE) then
        LBMakeGroups()
    end if

    '' End Moved from game init


    g.bgColor = &h112233FF



    if(g.DEBUG) then
      ?"rg2dLoadLevel()..."
    end if
    if(g.USING_LB_CODE) then
        LBLoadLevel(level)
    end if

    g.player_state = "IDLE"

    g.player_turn = 1

    cpProjTerr = g.pm.createCollisionPair(g.pogProjs,g.pogTerr)
    cpProjTerr.overlapCallback = function(p,t) as integer
      ?"Projectile hitting ICE"
      if p.state = "ALIVE" then
        p.ttl = 0.1
        p.state = "DEAD"
        p.NotifyOwnerOfCollision(t)
      end if
      return 1
    end function

    td = terrainDefinition()
    randomizeTerrainDefinition(td, 10)

    terrain = laydownTerrainInOneSprite(g.pm, g.compositor, g.terrain_ice, td)

    g.tank1.setPosition(100, g.sHeight-td.getHeightAtXPoint(100) - 21)
    g.tank2.setPosition(g.sWidth-100, g.sHeight-td.getHeightAtXPoint(g.sWidth-100) - 21)
    g.tank1.updateDisplay()
    g.tank2.updateDisplay()

end function

function switchActivePlayer() as void
    g = GetGlobalAA()
    If g.player_turn = 1 then
      g.player_turn = 2
    else
      g.player_turn = 1
    End If

end function

' Stuff to be done at the start of each update loop goes here.
' TODO ?? dt is in seconds, but button_hold_time is in milliseconds'
function rg2dInnerGameLoopUpdate(dt as float, button, button_hold_time) as object
    g = GetGlobalAA()
    if(g.DEBUG and (dt > 0.040)) then
      ?"rg2dInnerGameLoopUpdate(";dt;")..."
    end if

    angle_inc = pi()/180

    If g.player_turn = 1 then
      active_player = g.tank1
    else
      active_player = g.tank2
    End If

    PBT = 2000 'Powerbar period in milliseconds '

    if active_player.isHumanPlayer then

      if(button.bUp) then
          active_player.set_turret_angle(active_player.tank_turret_angle + angle_inc)
          ?"Angle Up ";active_player.tank_turret_angle

      else if(button.bDown) then
          active_player.set_turret_angle(active_player.tank_turret_angle - angle_inc)
          ?"Angle Up ";active_player.tank_turret_angle

      else if(button.bRight) then
          ?"Trucking Left"

      else if(button.bLeft) then
          ?"Trucking Right"

      end if

      if(button.bSelect1) then
        if g.player_state = "IDLE" then
          ?"Prepping to fire"
          g.projectileInFlight = Invalid
          g.player_state = "POWER_SELECT"
          g.power_select = 0
        else if g.player_state = "POWER_SELECT" then
          p1 = (button_hold_time MOD (2*PBT)) ' Power as a sawtooth wave'
          p2 = (2*PBT) - p1 'Cross over sawtooth'
          pwr = minFloat(p1,p2)

          g.power_select =  (pwr/PBT)
          active_player.setPowerBar(g.power_select)
        end if
      else
        if g.player_state = "POWER_SELECT" then
          g.player_state = "FIRE"
        end if
      end if

      if g.player_state = "FIRE" ' Player just let go of fire button'
        g.player_state = "WAITING_IMPACT"
        g.projectileInFlight = active_player.fireProjectile(300 + g.power_select * 200)
      else if g.player_state = "WAITING_IMPACT"
        if g.projectileInFlight.state = "DEAD"
          g.player_state = "IMPACTED"
          g.projectileInFlight = invalid
        end if
      else if g.player_state = "IMPACTED"
        switchActivePlayer()
        g.player_state = "IDLE"
      end if


    else ' AI Player'
      if g.player_state = "IDLE" then
        ?"IDLE"
        g.player_state = "CALCULATING"
      else if g.player_state = "CALCULATING"
        ?" - CALCULATING"
        'shot = active_player.calculateNextShot() 'TODO Temporary hard code'
        active_player.shot = {}
        active_player.shot.angle = 60 * (pi()/180)
        active_player.shot.power = 450
        active_player.shot.powerBar = ((active_player.shot.power-300)/200)
        g.player_state = "AIMING"
      else if g.player_state = "AIMING" 'Animate turret aiming
        ?" - AIMING from ";active_player.tank_turret_angle;" to ";active_player.shot.angle
        da = active_player.shot.angle - active_player.tank_turret_angle
        if abs(da) <= angle_inc then
          active_player.set_turret_angle(active_player.shot.angle)
          g.player_state = "POWER_SELECT"
        else
          active_player.set_turret_angle(active_player.tank_turret_angle + sgn(da)*angle_inc)
        end if

      else if g.player_state = "POWER_SELECT" ' Animate power select bar'
        ?" - POWER_SELECT"
        dp = active_player.shot.powerBar - active_player.getPowerBarValue()

        pwr_inc = (1.0/PBT)*(dt*1000)

        if abs(dp) <= pwr_inc then
          active_player.setPowerBar(active_player.shot.powerBar)
          g.player_state = "FIRE"
        else
          active_player.setPowerBar(active_player.getPowerBarValue() + sgn(dp)*pwr_inc)
        end if

      else if g.player_state = "FIRE"
        ?" - POWER_SELECT"
        g.projectileInFlight = active_player.fireProjectile(active_player.shot.power)
        g.player_state = "WAITING_IMPACT"

      else if g.player_state = "WAITING_IMPACT"
        ?" - WAITING_IMPACT"
        if g.projectileInFlight.state = "DEAD"
          g.player_state = "IMPACTED"
          g.projectileInFlight = invalid
        end if

      else if g.player_state = "IMPACTED"
        switchActivePlayer()
        g.player_state = "IDLE"
      end if

    end if


    ' TODO create level status object'
    stat = {}
    stat.level_complete = false
    stat.game_complete = false

    if (g.tank1.health <= 0) OR (g.tank2.health <= 0) then
      stat.level_complete = true
    end if

    return stat

end function
