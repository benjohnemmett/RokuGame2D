function GameObjectManager() as object
  gom = {}

  gom.GameObjectList = []

  gom.reset = function() as void

    For each o in m.GameObjectList
      o.reset()
    End For

    m.GameObjectList.clear()
  end function

  gom.addGameObj = function(obj as object) as void
    m.GameObjectList.push(obj)
  end function

  gom.update = function(dt as float)
    i = 0
    while i < m.GameObjectList.count()
        a = m.GameObjectList[i]

        if a.update <> invalid then
          a.update(dt)
        end if
        i += 1

    end while
  end function


  return gom

end function

function gameObject(x,y) as object

  go = {}

  go.x = x
  go.y = y

  go.compTypeList = [] ' List of strings indicating which component types have been added'

  go.update = invalid  ' to be overriden by user'

  ' Add a new component to this object'
  ' - This actually merges the associative arrays.'
  go.addComponent = function(comp as object) as void
    m.compTypeList.push(comp.compType)
    m.append(comp)
  end function

  'Check to see if this object has a certain compType merged into it'
  go.hasCompType = function(compType as String) as boolean
    hasComp = false
    For each c in m.compTypeList
      if c = compType then
        hasComp = true
        Exit For
      end if
    End For

    return hasComp
  end function

  go.reset = function() as void

    ?" - GameObj Reset "
    m.compTypeList.clear()
    'm.compTypeList = invalid
  end function

  return go

end function
