local Paddle = {}

Paddle.gfx = {
  left = "gfx/paddle_vertical.png",
  right = "gfx/paddle_vertical2.png",
}

Paddle.speed = {}
Paddle.speed.ai = 1000
Paddle.speed.player = 150

Paddle.collision = {}
Paddle.collision.ball = function(paddle, ball)
  --we can add a sweet effect here!
end

Paddle.screenBoundaryCollision = function(paddle) 
    
  local change = { 
    position =  { x = 0, y = 0 },
    direction = { x = paddle.direction.x, y = paddle.direction.y },
  }
  
  --Collision vs bottom
  if paddle.position.y + paddle.size.h2 > love.graphics.getHeight() then
    
    -- We bounce by just making the direction vector negative.       
    change.direction.y = -paddle.direction.y 
    
    -- We also need to adjust the position or we might get stuck behind the line we're bouncing from
    local distanceFromCollision = love.graphics.getHeight() - (paddle.position.y + paddle.size.h2)      
    change.position.y = distanceFromCollision
  end
  
  --Collision vs top
  if paddle.position.y - paddle.size.h2 < 0 then
    change.direction.y = -paddle.direction.y 
    local distanceFromCollision = (paddle.position.y - paddle.size.h2) - 0       
    change.position.y = -distanceFromCollision
  end
  
  return change
end

Paddle.Player = function(upKey, downKey)  
  return function(actor, deltaTime)        
    actor.direction.y = 0
    
    local up_key = love.keyboard.isDown(upKey)
    local down_key = love.keyboard.isDown(downKey)
    
    if up_key and down_key then
      actor.direction.y = 0
    elseif up_key then
      actor.direction.y = -1  
    elseif down_key then
      actor.direction.y = 1
    end        
    
    local change = Paddle.screenBoundaryCollision(actor)        
    actor.position.x = actor.position.x + change.position.x
    actor.position.y = actor.position.y + change.position.y
  end
end

Paddle.AI = {}
Paddle.AI.smoothA = function(ball)
  
  local directionMultiplierSpeed = 7
  local direction = 0
  
  return function(actor, deltaTime)
    local change = Paddle.screenBoundaryCollision(actor)
    actor.position.x = actor.position.x + change.position.x
    actor.position.y = actor.position.y + change.position.y
   
   
    if not(actor.direction.y == change.direction.y) then
      direction = 0    
    elseif ball.position.y > actor.position.y then       
      direction = direction + (directionMultiplierSpeed * deltaTime)          
    elseif ball.position.y < actor.position.y then 
      direction = direction - (directionMultiplierSpeed * deltaTime)      
    end 
    
    direction = math.min(math.max(direction, -1), 1) --this is a simple clamp
    actor.direction.y = direction
        
  end  
  
end

Paddle.AI.smoothB = function(ball) 
  local directionMultiplierSpeed = 2
  local direction = 0
  
  return function(actor, deltaTime)
    local change = Paddle.screenBoundaryCollision(actor)
    actor.position.x = actor.position.x + change.position.x
    actor.position.y = actor.position.y + change.position.y
   
    if not(actor.direction.y == change.direction.y) then
      direction = 0    
    elseif ball.position.y > actor.position.y then       
      direction = direction + (directionMultiplierSpeed * deltaTime)          
    elseif ball.position.y < actor.position.y then 
      direction = direction - (directionMultiplierSpeed * deltaTime)      
    end 
    
    direction = math.min(math.max(direction, -1), 1) --this is a simple clamp
    actor.direction.y = direction
        
  end  
end

return Paddle