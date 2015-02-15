local Collision = require("lib/collision")
local Vector = require("lib/vector")

local Goose = {}
  
Goose.gfx = {
  image = "gfx/goose/turbulentGoose_down.png",
}

Goose.jumpSpeed = -5
Goose.fallSpeed_max = 5
Goose.gravity = 10

--local Example_params = {
--  jumpKey = "space",
--}
Goose.controller = function(params)
  local jumpKey = params.jumpKey
  local fallSpeed = 0 
  local can_jump = true -- We only want the goose to be able to jump after we've released the jump key. 
                        -- Otherwise we could just fly upwards indefinately.
                        -- This would make jumping harder, because the player's going to release the key
                        -- at different times every time he presses the key, ever so slightly.
                        -- So our can_jump definition is this: 
                        --    we can jump if we pressed the button 
                        --    if the button was previously released
  
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
    
    actor.position.y = actor.position.y + fallSpeed
  end
  
end

Goose.screenBoundaryCollision = function(goose) 
   
   --Collision vs bottom
  if goose.position.y + goose.size.h2 > goose.graphics.getHeight() then
    
    --Apply ungoose
    
  end
  
  return 
end


return Goose