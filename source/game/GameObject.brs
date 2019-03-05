function GameObjectManager() as object

  g = GetGlobalAA()

  if g.DoesExist("GameObjectManager") then
    gom = g.GameObjectManager
  else
    gom = {}
    gom.GameObjectList = []

    gom.addGameObj = function(obj as object) as void
      m.GameObjectList.push(obj)
    end function

    gom.update = function(dt as float)
      i = 0
      while i < m.GameObjectList.count()
          a = m.GameObjectList[i]

          if a.update <> invalid then
            a.update(dt) 'Update Display
          end if
          i += 1

      end while
    end function
    ' Set global game object manager'
    g.GameObjectManager = gom
  end if

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
        ' TODO how do you break out of a for loop?'
      end if
    End For

    return hasComp
  end function

  gom = GameObjectManager() ' Get singleton gom'
  gom.addGameObj(go)

  return go

end function
