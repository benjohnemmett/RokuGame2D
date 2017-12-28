function boundaryAABB(x, y, w, h) as object
    
    return {
        type : "AABB",
        x: x,
        y: y,
        w: w,
        h: h,
        radius: 2*maxFloat(h,w)   
    }

end function

function boundaryCircular(x, y, radius) as object
    return {
        type : "Circular",
        x: x,
        y: y,
        radius: radius
    }
end function