
local imageLib = require("lib/imagelib")
local collision = require("lib/collision")

local Actor = {}

--PARAMETER EXAMPLE = {
--  position = { 200, 300 },
--  direction = { 0.3, 0.7 },
--  speed = 200, --optional
--  scale = { 2, 2 }, --optional
--  rotation = 0, --optional
--  color = {255, 255, 255, 255}, --optional
--  imagePath = "gfx/ball.png",
--  controller = nil, -- the controls for the actor. 
--    This can be the ball (travel forward and bounce), 
--    It can be the paddle for the player that goes up and down depending on the keys pressed
--    Or our simple AI, moving up and down depending on the balls position
--  meta = nil, -- Meta attaches extra information to the actor object.
                -- This could be health, or a score that you get when you interact, anything really.
                -- If its something thats going to be on EVERY actor object i recommend that you implement it
                -- on the actor object itself.
--}

Actor.new = function(params) 
  local actor = {}
  
  params.scale = params.scale or {0, 0}
  
  actor.position = { x = params.position[1], y = params.position[2], }  
  actor.direction = { x = params.direction[1], y = params.direction[2] }
  actor.speed = params.speed or 0
  actor.image = imageLib.getImage(params.imagePath)
  actor.scale = { w = params.scale[1], h = params.scale[2] }
  actor.rotation = params.rotation or 0
  actor.color = params.color or {255, 255, 255, 255}
  actor.size = {
    w = actor.image:getWidth() * actor.scale.w,
    h = actor.image:getHeight() * actor.scale.h,
    w2 = (actor.image:getWidth() / 2) * actor.scale.w,  -- The : means that we are dereferencing a pointer from memory. 
    h2 = (actor.image:getHeight() / 2) * actor.scale.h, -- We're just pre-storing it here for readability and ease-of-debugging.                                        
  }                                                     -- You can make actual objects with a "this" variable attached to it in LUA by re-referencing our scope.
                                                        -- but since we're not using a typed language, it'll just give us extra overhead in the end.
  actor.remove = false
  actor.meta = params.meta or nil
  
  -- The controller is a callback function we're going to be attaching. If we dont apply one, we set an empty call back function.
  -- This is just to make the code cleaner later - if we dont attach a controller I dont want to have to check if this variable
  -- is nil.
  actor.setController = function(controller)    
    actor.controller = controller or function() end
  end
  actor.setController(params.controller)
     
  actor.getBox = function()
    return { x = actor.position.x - actor.size.w2, y = actor.position.y - actor.size.h2, w = actor.size.w, h = actor.size.h }
  end                                                         
  actor.box = actor.getBox()  --This is used for collision. It updates and boxes the x, y, w, and h every update.
    
  actor.update = function(deltatime)    
    -- Our new position is: 
    -- Current position + (our speed multiplied by the time between each frame * our travel direction). 
    -- We need to take the deltatime into consideration or we'll end up making this game super-fast on a faster computer. Or super-slow on a slower one.
    -- Also, we can just pause the the game by telling it the delta is 0 :D                
    actor.position.x = actor.position.x + ((actor.speed * deltatime) * actor.direction.x)
    actor.position.y = actor.position.y + ((actor.speed * deltatime) * actor.direction.y)
    
    -- We need to update this two values if we're tweening the actor. 
    actor.size = {
      w = actor.image:getWidth() * actor.scale.w,
      h = actor.image:getHeight() * actor.scale.h,
      w2 = (actor.image:getWidth() / 2) * actor.scale.w,  
      h2 = (actor.image:getHeight() / 2) * actor.scale.h, 
    }    
    actor.box = actor.getBox()
    
    actor.controller(actor, deltatime) --This is where we override the actors basic behaviour.
                                       --It can be the ball bouncing or the AI for a paddle!
  end
  
  actor.draw = function()
    love.graphics.setColor(actor.color)    
    love.graphics.draw(actor.image, actor.position.x - (actor.size.w / 2), actor.position.y - (actor.size.h / 2), actor.rotation, actor.scale.w, actor.scale.h)   
    love.graphics.setColor({255, 255, 255, 255})       
  end
  
  return actor
end



return Actor
