local Collision = require("lib/collision")
local Vector = require("lib/vector")

local Goose = {}
  
Goose.gfx = {
  image = "gfx/goose/turbulentGoose_down.png",
}

Goose.controller = function(params)
 
  return function(actor, deltaTime)  
    
  end
  
end

Goose.screenBoundaryCollision = function(goose) 
   
  
  --Collision vs bottom
  if goose.position.y + goose.size.h2 > goose.graphics.getHeight() then
    
    --Goose dies from this
    
  end
  
  return
end


return Goose