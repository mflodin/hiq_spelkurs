local Collision = require("lib/collision")
local Vector = require("lib/vector")

local Goose = {}
  
Goose.gfx = {
  image = "gfx/goose/turbulentGoose_down.png",
}

Goose.controller = function(params)
 
  --We're just adding some simple gravity now  
  local fallSpeed = 0 --The speed we're currently falling with
  local fallSpeed_max = 5 --Our max fallspeed (too high might be too fast to control)
  local gravity = 10 --How strong gravity is
 
  return function(actor, deltaTime)  
    fallSpeed = fallSpeed + (gravity * deltaTime)
    fallSpeed = math.min(fallSpeed, fallSpeed_max)
    
    actor.position.y = actor.position.y + fallSpeed
  end
  
end

Goose.screenBoundaryCollision = function(goose) 
   
  
  
  --Collision vs bottom
  if goose.position.y + goose.size.h2 > goose.graphics.getHeight() then
    
    --This kills a goose
    
  end
  
  return 
end


return Goose