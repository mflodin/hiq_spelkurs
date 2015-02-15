local Collision = require("lib/collision")
local Vector = require("lib/vector")
local Imagelib = require("lib/imagelib")

local Goose = {}
  
Goose.gfx = {
  image = "gfx/goose/turbulentGoose_down.png",
  down = "gfx/goose/turbulentGoose_down.png",
  up = "gfx/goose/turbulentGoose_up.png",
}

-- We're preloading the images in this scope. Since the Imagelib shares all the images interally we dont really
-- lose any performance by doing this.
-- Right now we're just making a simple animation. If we were doing anything more complex we'd use the animation class.
Goose.image = {}
Goose.image.up = Imagelib.getImage(Goose.gfx.down)
Goose.image.down = Imagelib.getImage(Goose.gfx.up)

Goose.jumpSpeed = -5
Goose.fallSpeed_max = 5
Goose.gravity = 10

Goose.collision = {}
Goose.collision.test = {}
Goose.collision.test.box = function(goose, skyRock)  
  return Collision.boxVsBox(goose.box, skyRock.box)  
end

--local Example_params = {
--  jumpKey = "space",
--}
Goose.controller = function(params)
  local jumpKey = params.jumpKey
  local fallSpeed = 0 
  local can_jump = true 
  
  local calculateGravity = function(deltaTime) --returns new fallspeed            
    return math.min(fallSpeed + (Goose.gravity * deltaTime), Goose.fallSpeed_max)
  end
 
  return function(actor, deltaTime)   
    fallSpeed = calculateGravity(deltaTime)
    local pressed_jump = love.keyboard.isDown(jumpKey) -- we say we want to jump if we pressed the key
    
    if pressed_jump and can_jump then  -- and if the button was previously released
      fallSpeed = Goose.jumpSpeed
      can_jump = false      
    end
    can_jump = not(love.keyboard.isDown(jumpKey)) -- mark jump as available if the key is up
    
    --Simple animation
    if pressed_jump then
      actor.image = Goose.image.up --Override the current actors image and show the goose up
    else
      actor.image = Goose.image.down --Override the current actors image and show the goose down
    end

    actor.position.y = actor.position.y + fallSpeed
  end
  
end

Goose.screenBoundaryCollision = function(goose) 
   
   --Collision vs bottom
  if goose.position.y + goose.size.h2 > goose.graphics.getHeight() then
    
    --Death: Michael Bay vs Goose
    
  end
  
  return 
end


return Goose