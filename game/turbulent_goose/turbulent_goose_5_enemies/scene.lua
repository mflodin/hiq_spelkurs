local Scene = require("lib/scene")
local Actor = require("game/actor")
local Goose = require("game/turbulent_goose/turbulent_goose_5_enemies/goose")
local Skyrock = require("game/turbulent_goose/turbulent_goose_5_enemies/skyrock")

local turbulentGoose = {}
turbulentGoose.new = function(playerA_settings, playerB_settings)
  
  local goose = {} -- This is the object that contains the game-functions for the scene
  local scene = {} -- We will allocate this using the scene later. 
  local actors = {} -- List of actors
  
  local spawnTime = 3.5
  local spawnTimer = 0
  
  local createGoose = function() 
    
    local gooseControllerParams = {
      jumpKey = " ",
    }
    
    local gooseParams = {
      position = { 100, 150 },
      direction = { 0, 0 },
      speed = Goose.speed,
      rotation = 0,
      scale = { 4, 4 },
      imagePath = Goose.gfx.image,
      controller = Goose.controller(gooseControllerParams),
    }
        
    return Actor.new(gooseParams)    
  end
  
  local createSkyRock = function(altitude) 
    local params = {
      position = { love.graphics.getWidth() + 100, altitude }, 
      direction = { 0, 0 },
      speed = Skyrock.speed,
      rotation = 0,
      scale = { 4, 4 },
      imagePath = Skyrock.gfx.down,
      controller = Skyrock.controller(),
    }
        
    return Actor.new(params) 
  end  
  
  local onBegin = function()
    love.graphics.setBackgroundColor(94, 169, 255) 
    
    actors[#actors + 1] = createGoose()
    actors[#actors + 1] = createSkyRock(Skyrock.start_y)
  end

  local onUpdate = function(deltaTime)
    
    spawnTimer = spawnTimer + deltaTime
    
    if spawnTimer > spawnTime then
      actors[#actors + 1] = createSkyRock(Skyrock.space + math.random(Skyrock.start_y))
      spawnTimer = spawnTimer - spawnTime
    end
    
    for key, actor in pairs(actors) do
      actor.update(deltaTime)
    end
    
  end
  
  local onDraw = function()
    
    --draw all the actors (ball, left and right paddle)
    for key, actor in pairs(actors) do
      actor.draw()
    end
  end
  
  local onMouseReleased = function(x, y, button)
    
  end
  
  local onMousePressed = function(x, y, button)
    
  end
  
  local onStop = function()
    
  end

  scene = Scene.new(onBegin, onUpdate, onDraw, onMouseReleased, onMousePressed, onStop)
  
  return scene
end

return turbulentGoose 
