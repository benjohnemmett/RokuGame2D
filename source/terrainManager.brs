
' Returns an array of terrain regions'
function createTerrain(path) as object 'TODO change name to loadTerrainSprites()'
bm = CreateObject("roBitmap", path)
' x0, y0, width, height
return {
  rTopBlock_round : CreateObject("roRegion", bm, 23, 0, 21, 21),
  rTopBlock_left : CreateObject("roRegion", bm, 46, 0, 21, 21),
  rTopBlock_center : CreateObject("roRegion", bm, 69, 0, 21, 21),
  rTopBlock_right : CreateObject("roRegion", bm, 92, 0, 21, 21),

  rCenterBlock : CreateObject("roRegion", bm, 46, 23, 21, 21)
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

function laydownTerrainInOneSprite(physModel, compositor, terrainRegions, terrainDef) as object
  g = GetGlobalAA()

  terrain = {
    sprites : [],
    colliders : []
  }

  bm = CreateObject("roBitmap", {width:1280, height:720, AlphaEnable:true})
  bm.clear(&h00000000)
  reg = CreateObject("roRegion", bm, 0, 0, 1280, 720)

  sprite = g.compositor.NewSprite(0, 0, reg, 0)
  terrain.sprites.push(sprite)

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
      bm.DrawObject(sx_, g.sHeight-s.height, terrainRegions.rTopBlock_center)

      for j = 1 to int(g.sHeight-s.height/21)
        bm.DrawObject(sx_, g.sHeight-s.height + j*21, terrainRegions.rCenterBlock)
      end for

      sx_ += 21
    end for


    x_ += s.width
  end for

  return terrain

end function
