local Collision = require("lib/collision")
local Vector = require("lib/vector")

local SkyRock = {}
  
SkyRock.gfx = {
  up = "gfx/goose/skyRockUp.png",
  down = "gfx/goose/skyRockDown.png",
}

SkyRock.speed = 350
SkyRock.space = 400
SkyRock.spawnPos_y = 450
SkyRock.first_rock = 650
SkyRock.rockDistance = -675
SkyRock.randomDistance = 100
SkyRock.spawnTime = 1.2

SkyRock.collision = {}
SkyRock.collision.goose = function(skyrock, goose)
  
  goose.remove = true
  
end

SkyRock.controller = function()
  --Travels to the left
  --If it hits 0 - width, we mark it for removal 
 
  return function(actor, deltaTime)  
    actor.position.x = actor.position.x - (SkyRock.speed * deltaTime)
    if actor.position.x + (actor.image:getWidth() * actor.scale.w) < 0 then 
      actor.remove = true
    end
  end
  
end

return SkyRock