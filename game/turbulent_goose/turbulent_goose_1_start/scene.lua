local Scene = require("lib/scene")
local Actor = require("game/actor")
local Goose = require("game/turbulent_goose/turbulent_goose_1_start/goose")

local turbulentGoose = {}
turbulentGoose.new = function(playerA_settings, playerB_settings)
  
  local goose = {} -- This is the object that contains the game-functions for the scene
  local scene = {} -- We will allocate this using the scene later. 
  local actors = {} -- List of actors
  
  local createGoose = function() 
    local gooseParams = {
      position = { 100, 150 },
      direction = { 0, 0 },
      speed = Goose.speed,
      rotation = 0,
      scale = { 4, 4 },
      imagePath = Goose.gfx.image,
      controller = nil,
    }
    
    return Actor.new(gooseParams)    
  end
  
  local onBegin = function()
    love.graphics.setBackgroundColor(94, 169, 255) 
    
    actors[#actors + 1] = createGoose()
  end

  local onUpdate = function(deltaTime)
    -- Deltatime is: (Current time) - (Previous onUpdates time).
    -- We use it to make sure everything has a constant speed.
    
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
