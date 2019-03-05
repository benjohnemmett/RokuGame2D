function rcPair(r as integer, c as integer) as object
  rcp = {}

  rcp.row = r
  rcp.col = c

  rcp.getRow = function() as integer
    return m.row
  end function
  
  rcp.getCol = function() as integer
    return m.col
  end function

  return rcp
end function
