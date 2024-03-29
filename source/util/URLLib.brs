Function URLLibSetup()
  g = GetGlobalAA()
    g.pendingXfers = {}
End Function

Function URLLibGetAsync(url as String)
  g = GetGlobalAA()
    newXfer = CreateObject("roUrlTransfer")
    newXfer.EnableHostVerification(false)
    newXfer.EnablePeerVerification(false)
    newXfer.SetUrl(url)
    newXfer.SetRequest("GET")
    newXfer.SetMessagePort(g.port)
    success = newXfer.AsyncGetToString()
    requestId = newXfer.GetIdentity().ToStr()
    g.pendingXfers[requestId] = newXfer

    return success
End Function

Function URLLibPostStringAsync(url as String, val as String)
  g = GetGlobalAA()
    newXfer = CreateObject("roUrlTransfer")
    newXfer.EnableHostVerification(false)
    newXfer.EnablePeerVerification(false)
    newXfer.SetUrl(url)
    newXfer.SetRequest("POST")
    newXfer.SetMessagePort(g.port)
    success = newXfer.AsyncPostFromString(val)
    requestId = newXfer.GetIdentity().ToStr()
    g.pendingXfers[requestId] = newXfer

    return success
End Function

Function URLLibHandleUrlEvent(event as Object)
    g = GetGlobalAA()
    ?"URL EVENT, huh... I'll handle this."

    requestId = event.GetSourceIdentity().ToStr()
    ?" requestId = ";requestId
    xfer = g.pendingXfers[requestId]
    ?" xfer = ";xfer
    if xfer <> invalid then
        ' process it
        g.pendingXfers.Delete(requestId)
    end if

    ?"Event ";event.GetString()

End Function
