local Scene = require("lib/scene")
local Parallax = require("lib/parallax")

local parallaxScene = {}
parallaxScene.new = function()
  local scene = {}
  
  local position = { x = 100, y = 200 }
  local parallax_params = {
    segments = {
      { 
        image = "gfx/wave_red.png",
        multiplier = { x = 1.1, y = 1.1 },  
        scale = { 4, 4 },
        y = 200,
      },
      {
        image = "gfx/wave_purple.png",
        multiplier = { x = 1.4, y = 1.2 },    
        scale = { 4, 4 },
        y = 260,
      },
      {
        image = "gfx/wave_blue.png",
        multiplier = { x = 2.0, y = 1.3 },    
        scale = { 4, 4 },
        y = 320,
      },
    }
  }

  local parallax = Parallax.new(position, parallax_params)
  
  local onBegin = function()
    love.graphics.setBackgroundColor(68, 0, 255) 
  end

  local onUpdate = function(deltaTime)
    position.x = position.x + (30 * deltaTime)
  end
  
  local onDraw = function()
    parallax.draw()
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

return parallaxScene 
