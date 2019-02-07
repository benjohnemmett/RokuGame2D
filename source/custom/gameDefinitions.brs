' Defines how a game will be played'
' tank1 & tank2 are player defninition objects with a generate() function'
function gameDefinition(rounds as integer, tank1, tank2, windspeed, levelPlayers, songURL) as object

  GDef = {rounds : rounds,
          tank1 : tank1,
          tank2 : tank2 }

  GDef.windspeed = windspeed ' INvalid selects random wind speed'
  GDef.levelPlayers = levelPlayers
  GDef.songURL = songURL
  GDef.terrainDef = invalid

  return GDef

end function

' Wrapper definition with function for generating a player
function playerDef(playerNumber, isHumanPlayer, tankType, name)
  pdef =  {playerNumber : playerNumber,
          isHumanPlayer : isHumanPlayer,
          tankType : tankType,
          name : name}

  '''' Generate player function
  pdef.generate = function() as object

    faceRight = true
    if(m.playerNumber = 2) then
      faceRight = False
    end if

    if(m.isHumanPlayer) then
            'createTank(playerNumber, isHumanPlayer, x, y, angle, faceRight, tank_type)'
      tank = createTank(m.playerNumber, true, 100, 200, 0, faceRight, m.tankType)
    else
      'AITankRanger(playerNumber, x, y, angle, faceRight, tank_type)'
      tank = AITankRandy(m.playerNumber, 100, 100,0, faceRight, m.tankType)
    end if

    tank.name = m.name

    return tank
  end function


  return pdef

end function

' Wrapper definition with function for generating an AIRanger player'
'' Must be called in level setup so that compisitor for level has been set
function AIRangerPlayerDef(playerNumber, tankType, badness, name)
  pdef = playerDef(playerNumber, false, tankType, name)
  pdef.badness = badness

  pdef.generate = function() as object

    faceRight = true
    if(m.playerNumber = 2) then
      faceRight = False
    end if

    tank = AITankRanger(m.playerNumber, 100, 100,0, faceRight, m.tankType)
    tank.badness = m.badness
    tank.name = m.name

    return tank
  end function

  return pdef

end function



function getAIPlayerDefForLevel(playerNumber, level as integer) as object

      pdef = invalid

      if level = 1 then
        pdef = PlayerDef(playerNumber, false, "igloo_blue", "Iceman")
      else if level = 2 then
        pdef = AIRangerPlayerDef(playerNumber, "igloo_green", 1.5, "Green Giant")
      else if level = 3 then
        pdef = AIRangerPlayerDef(playerNumber, "igloo_red", 1.0, "Rudolph")
      else if level = 4 then
        pdef = AIRangerPlayerDef(playerNumber, "igloo_pink", 0.5, "Popper")
      else if level = 5 then
        pdef = AIRangerPlayerDef(playerNumber, "igloo_grey", 0.3, "Ghost")
      else if level = 6 then
        pdef = AIRangerPlayerDef(playerNumber, "igloo_black", 0.1, "Jet")
      else
        ?"Warning got unhandled level ";level
      end if

      return pdef

end function


' Called by main after setup'
function createGameDefinitions() as void
    g = GetGlobalAA()

    yourName = "Player 1"

    gameDefs = []

    gd1 = gameDefinition(1, playerDef(1, true, "igloo", yourName), getAIPlayerDefForLevel(2, 1),       0, false, g.songURLS.cosmic_local)
    gd1.terrainDef = terrainDefinition()
    gd1.terrainDef.createSections([147,126,126, 126,126,105, 126,126,126,147], [241,220,301, 270,270,320, 280,220,220,241])

    gd2 = gameDefinition(1, playerDef(1, true, "igloo", yourName), getAIPlayerDefForLevel(2, 2), -8, false, g.songURLS.makeMyDay_local)
    gd2.terrainDef = terrainDefinition()
    gd2.terrainDef.createSections([147,126,126, 126,126,105, 126,126,126,147], [240,240,310, 310,270,300, 300,335,300,300])

    gd3 = gameDefinition(1, playerDef(1, true, "igloo", yourName), getAIPlayerDefForLevel(2, 3), invalid, false, g.songURLS.stuff_local)
    gd3.terrainDef = terrainDefinition()
    gd3.terrainDef.createSections([147,126,126, 126,126,105, 126,126,126,147], [200,200,300, 270,310,330, 230,280,240,240])


    gd4 = gameDefinition(1, playerDef(1, true, "igloo", yourName), getAIPlayerDefForLevel(2, 4), invalid, false, g.songURLS.stuff_local)
    gd5 = gameDefinition(1, playerDef(1, true, "igloo", yourName), getAIPlayerDefForLevel(2, 5), invalid,  true, g.songURLS.slowWalk_local)

    gd6 = gameDefinition(1, playerDef(1, true, "igloo", yourName), getAIPlayerDefForLevel(2, 6),       0,  true, g.songURLS.slowWalk_local)
    gd6.terrainDef = terrainDefinition()
    gd6.terrainDef.createSections([147,126,126, 126,126,105, 126,126,126,147], [200,160,190, 280,230,350, 416,336,170,200])

    gameDefs.push(gd1)
    gameDefs.push(gd2)
    gameDefs.push(gd3)
    gameDefs.push(gd4)
    gameDefs.push(gd5)
    gameDefs.push(gd6)

    g.gameDefs = gameDefs

end function
