local Collision = require("lib/collision")
local Vector = require("lib/vector")

local Brick = {}

Brick.gfx = {
  image = "gfx/brick.png",
}

Brick.collision = {}
Brick.collision.ball = function(brick, ball)
  
  local overlap = Collision.boxOverlap(ball.box, brick.box)
  
  if overlap.x > overlap.y then -- bounce vertically
    ball.direction.y = -ball.direction.y
    
    if ball.position.y < brick.position.y then
      ball.position.y = ball.position.y - overlap.y 
    else 
      ball.position.y = ball.position.y + overlap.y
    end    
    
  elseif overlap.x < overlap.y then -- bounce horizontally
    ball.direction.x = -ball.direction.x
    
    if ball.position.x < brick.position.x then
      ball.position.x = ball.position.x - overlap.x 
    else 
      ball.position.x = ball.position.x + overlap.x
    end    
    
  end  
  
  brick.remove = true

end

Brick.Logic = function()  
  return function(actor, deltaTime)            
    
  end
end



return Brick