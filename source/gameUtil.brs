function rg2dGameSettings() as object
    return {
        controls : "V",
        music : "On",
        soundEffects : "On",
        controlCodes : rg2dGameControlCodes("V"),
        
        setControls : function(mode as string) as void
            if(mode = "V") then
                m.controlCodes = gameControlCodes("V")
                m.controls = "V"
            else
                m.controlCodes = gameControlCodes("H")
                m.controls = "H"
            end if
        end function
    }

end function

function rg2dPlaySound(sound) as void
    g = GetGlobalAA()
    if(g.settings.soundEffects = "On") then
        '?"Audio Stream ";g.audioStream
        sound.trigger(80, g.audioStream)
        g.audioStream = (g.audioStream + 1) mod g.maxAudioStreams
    end if
    '?"Next Audio Stream ";g.audioStream

end function

function rg2dGameControlCodes(mode as string) as object

    codes = bslUniversalControlEventCodes()

    if(mode = "V") then
        'Vertical controls
        return {
            UP_PRESSED : codes.BUTTON_UP_PRESSED,
            DOWN_PRESSED : codes.BUTTON_DOWN_PRESSED,
            RIGHT_PRESSED : codes.BUTTON_RIGHT_PRESSED,
            LEFT_PRESSED : codes.BUTTON_LEFT_PRESSED,
            SELECT1A_PRESSED : codes.BUTTON_SELECT_PRESSED,
            SELECT1B_PRESSED : 18,  'Blue Button
            SELECT2_PRESSED : 17,   ' Green Button
            BACK_PRESSED : codes.BUTTON_BACK_PRESSED,
            PLAY_PRESSED : codes.BUTTON_PLAY_PRESSED,
            
            UP_RELEASED : codes.BUTTON_UP_RELEASED,
            DOWN_RELEASED : codes.BUTTON_DOWN_RELEASED,
            RIGHT_RELEASED : codes.BUTTON_RIGHT_RELEASED,
            LEFT_RELEASED : codes.BUTTON_LEFT_RELEASED,
            SELECT1A_RELEASED : codes.BUTTON_SELECT_RELEASED,
            SELECT1B_RELEASED : 18,  'Blue Button
            SELECT2_RELEASED : 17,   ' Green Button
            BACK_RELEASED : codes.BUTTON_BACK_RELEASED,
            PLAY_RELEASED : codes.BUTTON_PLAY_RELEASED,
            
            MENU_UP_A : codes.BUTTON_UP_PRESSED,
            MENU_DOWN_A : codes.BUTTON_DOWN_PRESSED,
            MENU_LEFT_A : codes.BUTTON_LEFT_PRESSED,
            MENU_RIGHT_A : codes.BUTTON_RIGHT_PRESSED,
            MENU_UP_B : codes.BUTTON_RIGHT_PRESSED,
            MENU_DOWN_B : codes.BUTTON_LEFT_PRESSED,
            MENU_LEFT_B : codes.BUTTON_UP_PRESSED,
            MENU_RIGHT_B : codes.BUTTON_DOWN_PRESSED,
            
        }
    else
        'Horizontal controls
        return {
            
            UP_PRESSED : codes.BUTTON_RIGHT_PRESSED,
            DOWN_PRESSED : codes.BUTTON_LEFT_PRESSED,
            LEFT_PRESSED : codes.BUTTON_DOWN_PRESSED,
            RIGHT_PRESSED : codes.BUTTON_UP_PRESSED,
            SELECT1A_PRESSED : codes.BUTTON_SELECT_PRESSED,
            SELECT1B_PRESSED : 18,  'Blue Button
            SELECT2_PRESSED : 17,   ' Green Button
            BACK_PRESSED : codes.BUTTON_BACK_PRESSED,
            PLAY_PRESSED : codes.BUTTON_PLAY_PRESSED,
            
            UP_RELEASED : codes.BUTTON_RIGHT_RELEASED,
            DOWN_RELEASED : codes.BUTTON_LEFT_RELEASED,
            LEFT_RELEASED : codes.BUTTON_DOWN_RELEASED,
            RIGHT_RELEASED : codes.BUTTON_UP_RELEASED,
            SELECT1A_RELEASED : codes.BUTTON_SELECT_RELEASED,
            SELECT1B_RELEASED : 118,  'Blue Button
            SELECT2_RELEASED : 117,   ' Green Button
            BACK_RELEASED : codes.BUTTON_BACK_RELEASED,
            PLAY_RELEASED : codes.BUTTON_PLAY_RELEASED,
            
            MENU_UP_A : codes.BUTTON_UP_PRESSED,
            MENU_DOWN_A : codes.BUTTON_DOWN_PRESSED,
            MENU_LEFT_A : codes.BUTTON_LEFT_PRESSED,
            MENU_RIGHT_A : codes.BUTTON_RIGHT_PRESSED,
            MENU_UP_B : codes.BUTTON_RIGHT_PRESSED,
            MENU_DOWN_B : codes.BUTTON_LEFT_PRESSED,
            MENU_LEFT_B : codes.BUTTON_UP_PRESSED,
            MENU_RIGHT_B : codes.BUTTON_DOWN_PRESSED,
            
        }
    
    end if

end function

function rg2dGameStats(score, wave) as object
    return {
        score: score,
        wave: wave,
        playerName: "Wildcard"
    }
end function

function rg2dScoreBoard() as object
    return {
    
        ' Return true if input arg gameStats is high enough to reach the scoreboard
        checkHighScore : function(gs) as boolean
            
            if(gs.score <= 0) then
                return false
            end if
            
            if(m.topGames.Count() < m.maxGames) then
                return true
            end if
            
            for each g in m.topGames
                if gs.score > g.score then
                    return true
                end if
            end for 
            
            return false
        
        end function,
        ' 
        addGameStats: function(gs) as integer
            ' >> Insertion sort, keeping top N games
            
                ' INsert
            m.topGames.Push(gs)
                ' sort
            m.topGames.SortBy("score","r")
            
                ' clip the end object
            if m.topGames.Count() > 10 then
                for i = 10 to m.topGames.Count()-1
                    m.topGames.delete(i)
                end for
            end if
                
        end function,
        
        clearScoreBoard : function() as void
            m.topGames = []
        
        end function,
        
        saveScoreBoard : function() as void
            '?"Saving High Scores"
            g = GetGlobalAA()
            
            json = FormatJSON({topGames: m.topGames}, 1)
            sec = CreateObject("roRegistrySection", "PoP")
            sec.Write(g.highScoreRegister, json)
            sec.Flush()
        end function,
        
        loadScoreBoard : function() as void
            '?"Loading High Scores"
            g = GetGlobalAA()
            
            json = GetRegistryString(g.highScoreRegister)

            if json <> ""
                obj = ParseJSON(json)

                if obj <> invalid and obj.topGames <> invalid
                    m.topGames = obj.topGames
                end if
                
            else 
                '?"- No high scores registry found"
            end if
        
        end function,
        
        ' For debugging
        printHighScores : function() as void
            ?"--- High Scores ---"
            for each g in m.topGames
                ?" * ";g.playerName;"   ";g.wave;"   ";g.score
            end for
            
        end function,
    
        topGames : [],
        maxGames : 10
    
    }
end function  

Function rg2dGetRegistryString(key as String, default = "") As String
    sec = CreateObject("roRegistrySection", "PoP")
    if sec.Exists(key)
        return sec.Read(key)
    end if
    return default
End Function