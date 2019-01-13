function rg2dOpenSettingsScreen(subScreen, subPort) as void
    g = GetGlobalAA()

    myCodes = g.settings.controlCodes

    codes = bslUniversalControlEventCodes()

    settingsArray = ["Background Music",
                "Sound Effects",
                "Controls"]
    '?settingsArray

    selectedSetting = 0
    rg2dSetupSettingsScreen(settingsArray, selectedSetting, subScreen)

    while true
        event = subPort.GetMessage()

        if (type(event) = "roUniversalControlEvent") then
            id = event.GetInt()
            '?id
            if (id = myCodes.MENU_UP_A) or (id = myCodes.MENU_UP_B) then

                selectedSetting = selectedSetting - 1
                if(selectedSetting < 0) then
                    selectedSetting = settingsArray.Count() -1
                end if

            else if(id = myCodes.MENU_DOWN_A) or (id = myCodes.MENU_DOWN_B) then

                selectedSetting = (selectedSetting + 1) MOD settingsArray.Count()

            else if(id = myCodes.SELECT1A_PRESSED) or (id = myCodes.SELECT1B_PRESSED) or (id = myCodes.SELECT2_PRESSED) then

                if(settingsArray[selectedSetting] = "Controls") then
                    if(g.settings.controls = "V") then
                        g.settings.setControls("H")
                    else
                        g.settings.setControls("V")
                    end if
                    myCodes = g.settings.controlCodes

                else if(settingsArray[selectedSetting] = "Background Music") then
                    if(g.settings.music = "On") then
                        g.settings.music = "Off"
                        g.audioPlayer.Stop()
                        '?"Music off"
                    else
                        g.settings.music = "On"
                        '?"Music on"
                    end if

                else if(settingsArray[selectedSetting] = "Sound Effects") then
                    if(g.settings.soundEffects = "On") then
                        g.settings.soundEffects = "Off"

                        '?"Sound FX off"
                    else
                        g.settings.soundEffects = "On"

                        '?"Sound FX on"
                    end if

                end if

            else if(id = myCodes.BACK_PRESSED)

                return

            end if

            rg2dSetupSettingsScreen(settingsArray, selectedSetting, subScreen)

        end if
    end while

end function

function rg2dSetupSettingsScreen(settingsArray, selectedSetting, subScreen) as Integer
    g = GetGlobalAA()

    subScreen.clear(0)

    'Screen stuff
    numSettingsOptions = settingsArray.Count()

    cX = 800
    cY = 300

    if(g.settings.controls = "V") then
        dfDrawImage(subScreen, "pkg:/components/images/Astroblast_Remote_Controls_V_360x360.png", cX, cY)
    else
        dfDrawImage(subScreen, "pkg:/components/images/Astroblast_Remote_Controls_H_360x360.png", cX, cY)
    end if

    font = g.font_registry.GetDefaultFont() 

    regColor = &hFFFFFFFF
    selColor = &hFFFF22FF

    topIndent = 300
    leftIndent = 180
    centerSpace = 400
    vertSpace = font.GetOneLineHeight()

    '?selectedSetting

    for t = 0 to (numSettingsOptions -1)
        if(t = selectedSetting) then
            subScreen.DrawText(SettingsArray[t],leftIndent,topIndent + t*vertSpace,selColor,font)
        else
            subScreen.DrawText(SettingsArray[t],leftIndent,topIndent + t*vertSpace,regColor,font)
        end if

        value = ""
        if(SettingsArray[t] = "Background Music") then
            value = g.settings.music
        else if(SettingsArray[t] = "Sound Effects") then
            value = g.settings.soundEffects
        else if(SettingsArray[t] = "Controls") then
            value = g.settings.controls
        end if

        subScreen.DrawText(value, leftIndent + centerSpace,topIndent + t*vertSpace,regColor,font)

    end for

    subScreen.SwapBuffers()

    return 0

end function
