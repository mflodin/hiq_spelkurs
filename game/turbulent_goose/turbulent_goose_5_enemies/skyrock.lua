local Collision = require("lib/collision")
local Vector = require("lib/vector")

local SkyRock = {}
  
SkyRock.gfx = {
  up = "gfx/goose/skyRockUp.png",
  down = "gfx/goose/skyRockDown.png",
}

SkyRock.speed = 100
SkyRock.space = 400
SkyRock.start_y = 450

SkyRock.controller = function(params)
  --Travels to the left
  --If it hits 0 - width, we mark it for removal 
 
  return function(actor, deltaTime)  
    actor.position.x = actor.position.x - (SkyRock.speed * deltaTime)
    
    if actor.position.x - actor.image:getWidth() < 0 then 
      actor.remove = true
      --also we need to remove the collision, we do that later
    end
  end
  
end

return SkyRock