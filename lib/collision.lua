local collision = {}

collision.pointInBox = function(x, y, rect)
  --rect definition = { 
  --  indexed array where i:
  --  1 = x, 2 = y, 3 = width, 4 = height
  -- }
  -- we really should refactor this so its identical to the boxVsBox box definition 
  -- one day
  
  local rectX, rectY = rect[1], rect[2]
  local rectWidth, rectHeight = rect[3], rect[4]
        
  if x > rectX and x < rectX + rectWidth then
    if y > rectY and y < rectY + rectHeight then
      return true
    end
  end    
  return false
  
end

collision.boxVsBox = function(A, B)
  
  if (A.x + A.w < B.x) or (A.x > B.x + B.w) then return false end
  if (A.y + A.h < B.y) or (A.y > B.y + B.h) then return false end
  
  return true
end

collision.boxOverlap = function(boxA, boxB) 
  return { x = math.max(0, math.min(boxA.x + boxA.w, boxB.x + boxB.w) - math.max(boxA.x, boxB.x)), 
           y = math.max(0, math.min(boxA.y + boxA.h, boxB.y + boxB.h) - math.max(boxA.y, boxB.y)) }
end

return collision