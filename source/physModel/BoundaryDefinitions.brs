function boundaryAABB(x, y, w, h) as object
    
    return {
        type : "AABB",
        x: x,
        y: y,
        w: w,
        h: h        
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