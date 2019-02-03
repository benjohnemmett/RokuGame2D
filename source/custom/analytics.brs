function sendLocaldata()
  g = GetGlobalAA()

  ' Post user info'
  myData = m.localData

  myDataString = FormatJSON(myData,0)

  ?"Posting MyDataString"
  ?myDataString

  dbPostURL = "https://ohh7ckjw0g.execute-api.us-east-1.amazonaws.com/default/SnowBattleData_Test"
  rPost = URLLibPostStringAsync(dbPostURL, myDataString)

end function
