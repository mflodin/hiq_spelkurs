local Collision = require("lib/collision")
local Vector = require("lib/vector")
local Imagelib = require("lib/imagelib")
local Generic = require("lib/generic")
local Tween = require("lib/tween")
local WaitThen = require("lib/waitThen")

local Brick = {}

local function clamp(n, low, high) 
  return math.min(math.max(n, low), high) 
end

local function runList(list, actor)
  for i = 1, #list do
    list[i](actor)
  end
end

Brick.gfx = {
  image = "gfx/brick.png",
}

Brick.meta = {}
Brick.meta.white = {
  color = {255, 255, 255, 255},
  life = 1
}

Brick.meta.pink = {
  color = {255, 128, 128, 255},
  life = 2
}

Brick.meta.red = {
  color = {255, 0, 0, 255},
  life = 4
}

Brick.meta.green = {
  color = {0, 150, 0, 255},
  life = 4
}

Brick.meta.lightGreen = {
  color = {0, 255, 0, 255},
  life = 2
}

Brick.meta.blue = {
  color = {0, 100, 255, 255},
  life = 3
}

Brick.meta.lightBlue = {
  color = {100, 200, 255, 255},
  life = 2
}

Brick.meta.orange = {
  color = {255, 128, 0, 255},
  life = 3
}

Brick.meta.yellow = {
  color = {255, 255, 0, 255},
  life = 2
}


Brick.animations = {}
Brick.animations.onDeath = function(scene)
  return function(actor)
    
    --This is a death animation    
    local x, y = actor.position.x, actor.position.y
    local color = actor.color
    local image = Imagelib.getImage(Brick.gfx.image)
    local animationData = { w = 2, h = 2, alpha = 255 }
    local to = { w = 5, h = 5, alpha = 0 }
    local tweenTime = 0.3
    
    local function draw()
      love.graphics.setColor(color[1], color[2], color[3], animationData.alpha)
      love.graphics.draw(image, x - (image:getWidth() * (animationData.w / 2)), y - (image:getHeight() * (animationData.h / 2)), 0, animationData.w, animationData.h)
      love.graphics.setColor(255, 255, 255, 255)
    end
    
    scene.addGeneric(Generic.new(draw), tweenTime)
    
    local tween = Tween.new(tweenTime, animationData, to, "inOutQuad")
    scene.addTween(tween)
  end
end

Brick.animations.onHit = function(scene)
  return function(actor)            
    
    local tweenTime = 0.1
    local originalScale = { w = 2, h = 2 }
    local newScale = { w = 1.0, h = 1.0 }
    local tween = Tween.new(tweenTime, actor.scale, newScale, "inOutQuad")
    scene.addTween(tween)                        
    
    local waitThen = WaitThen.new(tweenTime, function()
      local newScale = { w = originalScale.w, h = originalScale.h }
      local tween = Tween.new(0.2, actor.scale, newScale, "outBounce")
      scene.addTween(tween)  
    end)
  
    scene.addWaitThen(waitThen)
  end
end

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
  
  if brick.meta then
    if brick.meta.life > 1 then
      brick.meta.life = brick.meta.life - 1
      brick.color[1] = clamp(brick.color[1] + 100, 0, 255)
      brick.color[2] = clamp(brick.color[2] + 100, 0, 255)
      brick.color[3] = clamp(brick.color[3] + 100, 0, 255)
      
      runList(brick.meta.onHit, brick)
      
    else 
      brick.remove = true
      runList(brick.meta.onDeath, brick)
    end
  else 
    brick.remove = true
    runList(brick.meta.onDeath, brick)
  end

end

Brick.Logic = function(life)  
  return function(actor, deltaTime)            
    
  end
end



return Brick
