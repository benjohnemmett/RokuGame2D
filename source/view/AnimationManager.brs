function AnimationManager() as object
  am = {}

  am.AnimationList = []

  am.addAnimation = function(anim as object) as void
    m.AnimationList.push(anim)
  end function

  am.updateAnimations = function(dt as float)
    i = 0
    while i < m.AnimationList.count()
        a = m.AnimationList[i]

        if (a.done) OR (a.nf >= a.maxFrames) OR (a.t >= a.maxTime) then
            a.AnimationHasEnded()
            m.AnimationList.delete(i) ' remove object
        else
            a.preUpdateAnimation(dt) ' Update frame count & time
            a.updateAnimation(dt) 'Update animation
            i += 1
        end if

    end while
  end function

  am.animationCount = function() as integer
    return m.AnimationList.count()
  end function


  return am

end function

function Animation() as object

  an = {}

  an.maxFrames = 100
  an.maxTime = 2

  an.nf = 0'  number of frames advanced'
  an.t = 0.0'  total time advanced'

  an.done = false ' When done is true this animation will be removed from the list'

  an.preUpdateAnimation = function(dt) as void
    m.nf += 1
    m.t += dt
  end function

  an.UpdateAnimation = function(dt) as void
    ?"Warning: No UpdateAnimation function defined."
  end function

  an.AnimationHasEnded = function() as void
    ?"Animation Ended"
  end function

  return an

end function
