local Collision = require("lib/collision")
local Vector = require("lib/vector")

local Ball = {}
  
Ball.gfx = {
  image = "gfx/ball.png",
}

Ball.speed = 200
Ball.speedMax = 400
Ball.speedIncreaseOnPaddle = 25

-- The ball simply bounces on the sides and travels forward.
-- If we bounce on the sides, we increase the speed by 10%.
-- local params_example = {
--   speedIncrease = Ball.speedIncrease,
--   onHitLeft = pong.reset,
--   onHitRight = pong.reset,
--   onHitDown = nil,
--   onHitUp = nil,
-- }
Ball.controller = function(params) --optional parameter
  
  --Construct onHit logic using params, which is passed later to the balls boundaryCollision data
  --We're doing it like this to let the scene dictate what should happen to the ball when its done
  --This lets us create a "cleaner" ball without having to nestle the score logic deep inside the ball object
  local onHit = {
    left = params.onHitLeft or function() end,
    right = params.onHitRight or function() end,
    bottom = params.onHitDown or function() end,
    top = params.onHitUp or function() end,
  }
  
  -- This function returns the change required to keep the actor inside the screens boundaries.
  -- It returns position relative to the change required on both axises
  -- It returns the new direction that should be set if the actor is to bounce from the edge.  
  return function(actor, deltaTime)  
    local change = Ball.screenBoundaryCollision(actor, onHit)        
    
    actor.direction.x = change.direction.x
    actor.direction.y = change.direction.y
    actor.position.x = actor.position.x + change.position.x
    actor.position.y = actor.position.y + change.position.y
    
    if actor.speed > Ball.speedMax then
      actor.speed = Ball.speedMax
    end
  end
  
end

Ball.collision = {}
Ball.collision.test = {}
Ball.collision.test.box = function(ball, box)  
  return Collision.boxVsBox(ball.box, box.box)  
end

Ball.collision.nothing = function(ball, item)
  
end


Ball.collision.brick = function(ball, paddle)
  
  --We intersect the two boxes to find out what way to bounce the ball,
  --and how much to adjust the balls position so that the rectangle doesn't keep intersecting the ball.
  local overlap = Collision.boxOverlap(ball.box, paddle.box)
  
  if overlap.x > overlap.y then -- bounce vertically
    ball.direction.y = -ball.direction.y
    
    if ball.position.y < paddle.position.y then
      ball.position.y = ball.position.y - overlap.y 
    else 
      ball.position.y = ball.position.y + overlap.y
    end
    
    local u, v = Vector.sub(ball.position.x, ball.position.y, paddle.position.x, paddle.position.y)
    ball.direction.x, ball.direction.y = Vector.normalize(u, v)
    
  elseif overlap.x < overlap.y then -- bounce horizontally
    ball.direction.x = -ball.direction.x
    
    if ball.position.x < paddle.position.x then
      ball.position.x = ball.position.x - overlap.x 
    else 
      ball.position.x = ball.position.x + overlap.x
    end    
    
  end  
end

-- This function returns the change required to keep the actor inside the screens boundaries.
-- It returns position relative to the change required on both axises
-- It returns the new direction that should be set if the actor is to bounce from the edge.

Ball.screenBoundaryCollision = function(ball, onHit) 
    
  local change = { 
    position =  { x = 0, y = 0 },
    direction = { x = ball.direction.x, y = ball.direction.y },
  }
  
  --Collision vs bottom
  if ball.position.y + ball.size.h2 > love.graphics.getHeight() then
    
    -- We bounce by just making the direction vector negative.       
    change.direction.y = -ball.direction.y 
    
    -- We also need to adjust the position or we might get stuck behind the line we're bouncing from
    local distanceFromCollision = love.graphics.getHeight() - (ball.position.y + ball.size.h2)      
    change.position.y = distanceFromCollision
    
    onHit.bottom()
  end
  
  --Collision vs top
  if ball.position.y - ball.size.h2 < 0 then
    change.direction.y = -ball.direction.y 
    local distanceFromCollision = (ball.position.y - ball.size.h2) - 0       
    change.position.y = -distanceFromCollision
    
    onHit.top()
  end
  
  --Collision vs right side  
  if ball.position.x + ball.size.w2 > love.graphics.getWidth()  then
    change.direction.x = -ball.direction.x
    local distanceFromCollision = love.graphics.getWidth() - (ball.position.x + ball.size.w2)      
    change.position.x = distanceFromCollision
    
    onHit.right()
  end
  
  --Collision vs left
  local left = 0
  if ball.position.x - ball.size.w2 < left then
    change.direction.x = -ball.direction.x      
    local distanceFromCollision = (ball.position.x - ball.size.w2) - left
    change.position.y = -distanceFromCollision
    
    onHit.left()
  end
  
  return change
end


return Ball