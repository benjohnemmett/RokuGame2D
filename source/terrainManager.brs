
' Returns an array of terrain regions'
function createTerrain(path) as object 'TODO change name to loadTerrainSprites()'
bm = CreateObject("roBitmap", path)
' x0, y0, width, height
return {
  rTopBlock_round : CreateObject("roRegion", bm, 23, 0, 21, 21),
  rTopBlock_left : CreateObject("roRegion", bm, 46, 0, 21, 21),
  rTopBlock_center : CreateObject("roRegion", bm, 69, 0, 21, 21),
  rTopBlock_right : CreateObject("roRegion", bm, 92, 0, 21, 21),
  rTopAngle_left : CreateObject("roRegion", bm, 138, 0, 21, 21),
  rTopAngle_right : CreateObject("roRegion", bm, 161, 0, 21, 21),

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
    end function,

    getHeightAtXPoint : function(x)
      x_ = 0

      for each s in m.sectionList
        x_ += s.width
        if(x_ >= x) then
          return s.height
        end if
      end for

      return invalid

    end function,

    setSectionHeight : function(idx, height)
      section = m.sectionList[idx]
      section.height = height
    end function

  }
end function

' randomly adds sections to the terrain definition'
function randomizeTerrainDefinition(td, number_of_sections) as void

  MIN_H = 150
  MAX_H = 400
  MAX_H_TANK_SPOT = 300
  TOTAL_WIDTH = 1280
  DH = 100

  UNIT = 21

  x_ = 0

  avg_w = cint(TOTAL_WIDTH/number_of_sections)

  h = rnd(MAX_H - MIN_H) + MIN_H

  for i = 1 to number_of_sections
    if(i = 1) then
      h = minFloat(maxFloat( h - rnd(DH), MIN_H), MAX_H_TANK_SPOT)
    else if(i = 2) then
      h = minFloat(maxFloat( h - UNIT*rnd(4), MIN_H), MAX_H) ' Always start by going down'
    else if(i = (number_of_sections-1)) then
      h = minFloat(maxFloat( h + UNIT*(rnd(9) - 5), MIN_H), MAX_H_TANK_SPOT) ' Second to last can't be too high'
    else if(i = number_of_sections) then
      h = minFloat(maxFloat( h + UNIT*rnd(4), MIN_H), MAX_H_TANK_SPOT) ' Always end by going up'
    else
      h = minFloat(maxFloat( h + UNIT*(rnd(9) - 5), MIN_H), MAX_H)
    end if

    w = avg_w
    td.addSection(w, h)
  end for


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

  ' Add colliders around left & right edges of screen and far above the top'
  left = fixedBoxCollider(-100, -3*g.sHeight, 100, 4*g.sHeight)
  terrain.colliders.push(left)
  g.pogTerr.addPhysObj(left)
  right = fixedBoxCollider(g.sWidth, -3*g.sHeight, 100, 4*g.sHeight)
  terrain.colliders.push(right)
  g.pogTerr.addPhysObj(right)
  top = fixedBoxCollider(-100, -3*g.sHeight, g.sWidth + 200, 100)
  terrain.colliders.push(top)
  g.pogTerr.addPhysObj(top)

  x_ = 0
  prevX_ = 0
  numSections = terrainDef.sectionList.count()
  'for each s in terrainDef.sectionList

  prevH = 0
  nextH = 0
  for si = 0 to (numSections-1)

    s = terrainDef.sectionList[si]
    ' Create collider
    ' -> Stack them side by side against the bottom left corner
    fpc = fixedBoxCollider(x_, g.sHeight-s.height, s.width, s.height)
    terrain.colliders.push(fpc)
    g.pogTerr.addPhysObj(fpc)

    if si > 1 then
      prevH = terrainDef.sectionList[si-1].height
    end if
    if si < (numSections-1) then
      nextH = terrainDef.sectionList[si+1].height
    else
      nextH = 100000
    end if


    ' Create sprites'
    sx_ = x_
    N = int(s.width/21)
    for i = 0 to N ' N blocks in this section'
      if (i = 0) AND ((s.height - prevH) > 30) then ' Corner where this is higher than the previous'
        bm.DrawObject(sx_, g.sHeight-s.height, terrainRegions.rTopBlock_left) ' Top '
      else if (i = N) AND ((s.height - nextH) > 30) ' Corner where this is higher than the next'
        bm.DrawObject(sx_, g.sHeight-s.height, terrainRegions.rTopBlock_right) ' Top '
      else
        bm.DrawObject(sx_, g.sHeight-s.height, terrainRegions.rTopBlock_center) ' Top '
      end if

      for j = 1 to int((g.sHeight-s.height)/21)
        bm.DrawObject(sx_, g.sHeight-s.height + j*21, terrainRegions.rCenterBlock) 'going down'
      end for

      sx_ += 21
    end for

    'Angles'
    if si > 0 then ' Not the first one'
      sPrev = terrainDef.sectionList[si-1]
      if (s.height - sPrev.height) > 20 then ' Last one was lower'
          bm.DrawObject(x_-21, g.sHeight-sPrev.height-21, terrainRegions.rTopAngle_left)
          bm.DrawObject(x_-21, g.sHeight-sPrev.height, terrainRegions.rCenterBlock)
      end if

      if (sPrev.height - s.height) > 20 then ' Last one was Higher'
        bm.DrawObject(prevX_+sPrev.width+19, g.sHeight-s.height-21, terrainRegions.rTopAngle_right)
        bm.DrawObject(prevX_+sPrev.width+19, g.sHeight-s.height, terrainRegions.rCenterBlock)
        bm.DrawObject(prevX_+sPrev.width, g.sHeight-s.height, terrainRegions.rCenterBlock)

      end if
    end if

    'trees ' Only on non-tank sections, higher sections
    TREE_HEIGHT = 90
    if (si > 0) and (si < (numSections-1)) then
      if ((s.height - prevH) > 0) and ((s.height - nextH) > 0) then
        down = 10
        for i = 1 to rnd(3)
          bm.DrawObject(x_-10 + rnd(s.width-40), g.sHeight - s.height - TREE_HEIGHT + down, g.regions.tree_1_A)
          down += rnd(10)
        end for

      else if ((s.height - prevH) > 0) or ((s.height - nextH) > 0) then
            down = 10
            for i = 1 to rnd(5)
              bm.DrawObject(x_-10 + rnd(s.width-40), g.sHeight - s.height - TREE_HEIGHT + down, g.regions.tree_1_A)
              down += rnd(10)
            end for
      else
          if rnd(10) > 8 then
            bm.DrawObject(x_-10 + rnd(s.width-40), g.sHeight - s.height - TREE_HEIGHT + 10 + rnd(10), g.regions.tree_1_A)
          end if
      end if
    end if

    prevX_ = x_
    x_ += s.width
  end for


  return terrain

end function
