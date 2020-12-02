function IncrementScore(points) as void
  g = GetGlobalAA()
  g.gameScore += points
  g.ScoreBoard.SetText(strI(g.gameScore))
end function
