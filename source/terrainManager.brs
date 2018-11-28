
' Returns an array of terrain regions'
function createTerrain(path) as object 'TODO change name to loadTerrainSprites()'
bm = CreateObject("roBitmap", path)
' x0, y0, width, height
return {
  rTopBlock_round : CreateObject("roRegion", bm, 23, 0, 21, 21),
  rTopBlock_left : CreateObject("roRegion", bm, 46, 0, 21, 21),
  rTopBlock_center : CreateObject("roRegion", bm, 69, 0, 21, 21),
  rTopBlock_right : CreateObject("roRegion", bm, 92, 0, 21, 21)
}

end function

function terrainSection(width, height) as object
  return {
    width : width,
    height : height
  }
end function

' Terrain definition defines sections of terrain & their height
function terrainDefinition() as object
  return {
    sectionList : [],

    addSection : function(width, height)
      m.sectionList.push(terrainSection(width, height))
    end function
  }
end function

'Takes terrain regions & terrain definition, creates sprites & colliders and adds them to the compositor & physModel
function laydownTerrain(physModel, compositor, terrainRegions, terrainDef) as object
  g = GetGlobalAA()

  terrain = {
    sprites : [],
    colliders : []
  }

  x_ = 0

  for each s in terrainDef.sectionList
    ' Create collider
    ' -> Stack them side by side against the bottom left corner
    fpc = fixedBoxCollider(x_, g.sHeight-s.height, s.width, s.height)
    terrain.colliders.push(fpc)
    g.pogTerr.addPhysObj(fpc)

    ' Create sprites'
    sx_ = x_
    N = int(s.width/21)
    for i = 0 to N
      sp = compositor.NewSprite(sx_ + 21, g.sHeight-s.height, terrainRegions.rTopBlock_center, 0)
      terrain.sprites.push(sp)

      sx_ += 21
    end for


    x_ += s.width
  end for

  return terrain

end function
