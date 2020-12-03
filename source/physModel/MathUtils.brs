' Library of Generic Math functions

Function MaxFloat(a as float, b as float) as float

    if(a > b)
        Return a
    else
        Return b
    end if

End Function

Function MinFloat(a as float, b as float) as float

    if(a < b)
        Return a
    else
        Return b
    end if

End Function

function minInt(a,b) as Integer
    if(a < b)
        Return a
    else
        Return b
    end if
End Function

function maxInt(a,b) as Integer
    if(a > b)
        Return a
    else
        Return b
    end if
End Function

function ClampInt(a, min, max) as Integer 
  if (a < min)
    return min
  else if (a > max)
    return max
  else
    return a
  end if
end function

function pi() as float
    return atn(1)*4
end function

'wrap angle to be in the [-pi to pi] range
Function boundAngle(angle) as float
    p = pi()

    if(angle < -p) then
        return angle + 2*p
    else if(angle > p) then
        return angle - 2*p
    else
        return angle
    end if

'    return ((angle + p) MOD (2*p)) - p

End Function

function pow(x,n) as float
    v = x
    for i = 2 to n
        v *= x
    end for
    return v
end function

function vec2d(x,y) as object
    return {
        x : x,
        y : y
    }
end function

function rotateVec2d(v2d, angle) as object

    x = cos(angle) * v2d.x - sin(angle) * v2d.y
    y = sin(angle) * v2d.x + cos(angle) * v2d.y

    return vec2d(x,y)

end function
