function rg2dOpenCreditScreen(subScreen, subPort) as void
    g = GetGlobalAA()

    rg2dSetupCreditScreen(subScreen)

    codes = bslUniversalControlEventCodes()

    while true
        event = subPort.GetMessage()

        if (type(event) = "roUniversalControlEvent") then
            id = event.GetInt()
             if(id = codes.BUTTON_BACK_PRESSED)

                return

            end if
        end if
    end while


end function

function rg2dSetupCreditScreen(subScreen) as Integer
    g = GetGlobalAA()

    subScreen.clear(0)

    g.font_registry = CreateObject("roFontRegistry")
    font = g.font_registry.GetDefaultFont() 

    subScreen.SwapBuffers()

    return 0

end function
