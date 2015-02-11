local Tween = require "lib/tween"

local camera = {}

camera.new = function(x, y, interpolationType)
    
  local cam = {} 
  cam.x = x
  cam.y = y
  cam.tween = nil
  cam.interpolationType = interpolationType or "inOutSine"
  
  cam.moveTo = function(x, y, timeMs)
    cam.tween = Tween.new(timeMs, cam, { x = x, y = y}, cam.interpolationType)
  end
  
  cam.moveToRelative = function(x, y, timeMs)    
    cam.tween = Tween.new(timeMs, cam, { x = cam.x + x, y = cam.y + y}, cam.interpolationType)
  end
  
  cam.update = function(dt) 
    if cam.tween then
      cam.tween:update(dt)
    end
  end
  
  return cam
  
end

return camera