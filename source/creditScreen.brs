function rg2dOpenCreditScreen() as void
    g = GetGlobalAA()

    rg2dSetupCreditScreen()

    codes = bslUniversalControlEventCodes()

    g.audioManager.stop()
    g.audioManager.playsong(g.songURLS.goingDown_local)

    while true
        event = g.port.GetMessage()

        if (type(event) = "roUniversalControlEvent") then
            id = event.GetInt()
             if(id = codes.BUTTON_BACK_PRESSED)
                g.audioManager.stop()
                return

            end if
        end if
    end while


end function

function rg2dSetupCreditScreen() as Integer
    g = GetGlobalAA()
    ?"Setting up about screen"

    g.screen.clear(0)
    g.compositor.DrawAll()

    dfDrawImage(g.screen, "pkg:/images/snowbattle_about_screen.jpg", 0, 0)

    g.screen.SwapBuffers()

    return 0

end function
