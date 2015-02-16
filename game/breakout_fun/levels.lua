local Actor = require("game/actor")
local Ball = require("game/breakout_fun/ball_breakout")
local Brick = require("game/breakout_fun/brick_breakout")
local WaitThen = require("lib/waitThen")
local Tween = require("lib/tween")

-- This class is kind of quick and dirty. Running out of time, many apologies! 

local Levels = {}

Levels.spawnBrick = function(scene, game, collider, score, brickType, x, y, addScoreOnHit, addScoreOnDeath)
  local space_x, space_y = 68, 36
  local color = { brickType.color[1], brickType.color[2], brickType.color[3], brickType.color[4] } 
  local positionTo = { x = 64 + (x * space_x), y = 112 + (y * space_y) }

  local meta = { 
    life = brickType.life,          
    onDeath = { Brick.animations.onDeath(scene), addScoreOnDeath, addScoreOnHit },
    onHit = { Brick.animations.onHit(scene), addScoreOnHit }
  }
  
  local brickParams = {
    position = { positionTo.x, -100 },
    direction = { 0, 0 },
    color = color,
    speed = 0, 
    rotation = 0,
    scale = { 2, 2 },
    imagePath = Brick.gfx.image,
    controller = Brick.Logic(),
    meta = meta
  }
  local actor = Actor.new(brickParams)
  game.addActor(actor)
  collider.addObject(actor, Brick.collision.ball, Ball.collision.test.box)
  
  --add intro animation
  local waitThen = WaitThen.new(math.random(), 
    function() 
      local tween = Tween.new(1, actor.position, positionTo, "outBounce")
      scene.addTween(tween)            
    end)
  scene.addWaitThen(waitThen)
end


Levels.spawnLevelOne = function(scene, game, collider, score)
  
  score.color = Brick.meta.lightBlue.color

  local brickMeta = {
    Brick.meta.blue, 
    Brick.meta.lightBlue,
    Brick.meta.white,       
  }
  
  local addScoreOnHit = function()
    score.add(5)
  end

  local addScoreOnDeath = function()
    score.add(10)
  end
  
  local level = {
    { 3, 2, 1, 1, 1, 1, 1, 2, 3 },
    { 0, 0, 0, 0, 0, 0, 0, 0, 2 },
    { 0, 0, 0, 0, 0, 0, 0, 0, 1 },
    { 3, 2, 1, 1, 1, 1, 0, 0, 1 },
    { 2, 3, 3, 3, 3, 2, 0, 0, 1 },
    { 1, 3, 3, 3, 3, 2, 0, 0, 1 },
    { 2, 3, 3, 3, 3, 2, 0, 0, 2 },
    { 3, 2, 1, 1, 1, 1, 1, 2, 3 },
  }
  
  local space_x, space_y = 68, 36
  for y = 1, #level do
    for x = 1, #level[y] do
      
      if not(level[y][x] == 0) then
        local brickType = brickMeta[level[y][x]]
        Levels.spawnBrick(scene, game, collider, score, brickType, x, y, addScoreOnHit, addScoreOnDeath)        
      end
    end
  end
  
end 

Levels.spawnLevelTwo = function(scene, game, collider, score)

  score.color = Brick.meta.pink.color

  local brickMeta = {
    Brick.meta.red, 
    Brick.meta.pink,
    Brick.meta.white,       
  }
  
  local addScoreOnHit = function()
    score.add(10)
  end

  local addScoreOnDeath = function()
    score.add(20)
  end
  
  local level = {
    { 0, 0, 1, 1, 0, 1, 1, 0, 0 },
    { 0, 1, 2, 2, 1, 2, 2, 1, 0 },
    { 1, 2, 3, 3, 2, 3, 3, 2, 1 },
    { 1, 2, 3, 3, 3, 3, 3, 2, 1 },
    { 0, 1, 2, 3, 3, 3, 2, 1, 0 },
    { 0, 0, 1, 2, 3, 2, 1, 0, 0 },
    { 0, 0, 0, 1, 2, 1, 0, 0, 0 },
    { 0, 0, 0, 0, 1, 0, 0, 0, 0 },
  }
  
  local space_x, space_y = 68, 36
  for y = 1, #level do
    for x = 1, #level[y] do
      
      if not(level[y][x] == 0) then
        local brickType = brickMeta[level[y][x]]
        Levels.spawnBrick(scene, game, collider, score, brickType, x, y, addScoreOnHit, addScoreOnDeath)        
      end
    end
  end
    
end 

Levels.spawnLevelThree = function(scene, game, collider, score)

  score.color = Brick.meta.lightGreen.color
  
  local brickMeta = {
    Brick.meta.green, 
    Brick.meta.green, 
    Brick.meta.lightGreen, 
    Brick.meta.white,       
  }
  
  local addScoreOnHit = function()
    score.add(20)
  end

  local addScoreOnDeath = function()
    score.add(50)
  end
  
  for x = 1, 9 do 
    for y = 1, 5 do
      local brickIndex = ((x + y) % #brickMeta) + 1
      Levels.spawnBrick(scene, game, collider, score, brickMeta[brickIndex], x, y, addScoreOnHit, addScoreOnDeath)
      
    end
  end
  
end 

Levels.spawnLevelFour = function(scene, game, collider, score)

  score.color = Brick.meta.orange.color

  local brickMeta = {    
    Brick.meta.red,  
    Brick.meta.orange,       
    Brick.meta.yellow,      
    Brick.meta.white,      
  }
  
  local addScoreOnHit = function()
    score.add(50)
  end

  local addScoreOnDeath = function()
    score.add(100)
  end
  
  local level = {
    { 1, 1, 0, 0, 0, 0, 0, 1, 1 },
    { 1, 1, 1, 0, 0, 0, 1, 1, 1 },
    { 1, 1, 1, 1, 0, 1, 1, 1, 1 },
    { 1, 1, 1, 1, 1, 1, 1, 1, 1 },
    { 1, 1, 0, 1, 1, 1, 0, 1, 1 },
    { 1, 1, 0, 0, 1, 0, 0, 1, 1 },
    { 1, 1, 0, 0, 0, 0, 0, 1, 1 },
    { 1, 1, 0, 0, 0, 0, 0, 1, 1 },
  }
  
  local brick = 1
  local space_x, space_y = 68, 36
  for y = 1, #level do
    for x = 1, #level[y] do
      
      if not(level[y][x] == 0) then        
        local brickIndex = ((x + y) % #brickMeta) + 1
        Levels.spawnBrick(scene, game, collider, score, brickMeta[brickIndex], x, y, addScoreOnHit, addScoreOnDeath)        
      end
      
      brick = brick + 1
      if brick > #brickMeta then
        brick = 1
      end
    end
  end
  
end 

Levels.spawnLevelTest = function(scene, game, collider, score)
  
  local addScoreOnHit = function()
    score.add(10000)
  end

  local addScoreOnDeath = function()
    score.add(0)
  end
  
  Levels.spawnBrick(scene, game, collider, score, Brick.meta.white, 8, 5, addScoreOnHit, addScoreOnDeath)        
  
end 

Levels.spawnLevelInfinity = function(scene, game, collider, score)
  
  score.color = Brick.meta.lightBlue.color

  local brickMeta = {
    Brick.meta.blue, 
    Brick.meta.lightBlue,
    Brick.meta.white,       
  }
  
  local addScoreOnHit = function()
    score.add(0)
  end

  local addScoreOnDeath = function()
    score.add(1)
  end
  
  local level = {
    { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    { 0, 0, 3, 0, 0, 0, 3, 0, 0 },
    { 0, 3, 0, 3, 0, 3, 0, 3, 0 },
    { 3, 0, 0, 0, 3, 0, 0, 0, 3 },
    { 3, 0, 0, 0, 3, 0, 0, 0, 3 },
    { 0, 3, 0, 3, 0, 3, 0, 3, 0 },
    { 0, 0, 3, 0, 0, 0, 3, 0, 0 },
    { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  }
  
  local space_x, space_y = 68, 36
  for y = 1, #level do
    for x = 1, #level[y] do
      
      if not(level[y][x] == 0) then
        local brickType = brickMeta[level[y][x]]
        Levels.spawnBrick(scene, game, collider, score, brickType, x, y, addScoreOnHit, addScoreOnDeath)        
      end
    end
  end
  
end 

return Levels
