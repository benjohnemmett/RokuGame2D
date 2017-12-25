' TODO should these all be subs, not returning anything? Any advantage to subs?

' Set global game parameters here. 
function rg2dSetGameParameters() as void

    g = GetGlobalAA()
    
    g.highScoreRegister = "myGameHighScores"
    


end function


function rg2dLoadSprites() as void
    g = GetGlobalAA()
    
    bmScore = CreateObject("roBitmap", "pkg:/assets/Asteroid_Numbers_Spritesheet_32.png")
    
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
    
    
    bmTruck = CreateObject("roBitmap", "pkg:/components/sprites/texture_brick01_60p.png")
    g.rTruck = CreateObject("roRegion", bmTruck, 0, 0, 60, 60)

end function

function rg2dLoadSounds() as void
    g = GetGlobalAA()
    
    g.sounds ={}
    'g.sounds.ship_engines = CreateObject("roAudioResource", "pkg:/assets/ship_engines.wav")
    g.sounds.navSingle = CreateObject("roAudioResource", "navsingle")
    
    '?"Max Streams ";g.sounds.astroid_blast.maxSimulStreams()
    g.audioStream = 1
    g.maxAudioStreams = 1 'g.sounds.astroid_blast.maxSimulStreams()

end function



function rg2dGameInit() as void
    g = GetGlobalAA()
    
    ' Create Truck
    'sTruck = g.compositor.NewSprite(100, 100, g.rTruck, 0)
    'g.truck = physObj(sTruck, )
    g.truck = g.pm.createPhysObj( 100, 100, 49, 36, "pkg:/components/sprites/firetruck_spritesheetII.png")    

end function


'''''''''' OUTER LOOP STUFF

' Load up level specified by input argument
function rg2dLoadLevel(level as integer) as void
    g = GetGlobalAA()
    ' 


end function

function rg2dInnerGameLoopUpdate(button) as void
    g = GetGlobalAA()

    if(button.bUp) then
        ?"Trucking Up"
    
    else if(button.bDown) then
        ?"Trucking Down"
    
    else if(button.bRight) then
        ?"Trucking Left"
    
    else if(button.bLeft) then
        ?"Trucking Right"
    
    end if

end function



