local Scene = require("lib/scene")
local Button = require("lib/button")

local PongScene = require("pongScene")
local BreakoutScene = require("breakoutScene")
local BreakoutFunScene = require("breakoutFunScene")

local Particles = require("lib/particles")

local debugScene = {}

debugScene.new = function()
  local scene = {}
  
  -- Set up a fancy bubble particle animation
  local particleConf = {    
    position = { x = 1024 / 2, y = love.graphics:getHeight() },
    lifeLengthSeconds = 0, 
    spawnRatePerSecond = 3, 
    particleGenerator = {
      generator = Particles.standard_move,
      params = {
        tweenType = "outQuad",
        image = "gfx/ball.png",
        from_position = { x = 0, y = 0 }, --relative to particle position
        within_area = { width = 1024, height = 0 }, --centered on mid
        travelsDistance = { --Should be distance per axis instead :/
          x = { min = 0, max = 0 }, 
          y = { min = -100, max = -500 }, 
        },
        rgba_from = { 255, 255, 255, 255 },
        rgba_to = { 128, 255, 255, 0 },
        overTimeInSeconds = 5,
        rotation_from = 0,
        rotation_to = 0,
        scale_from = 0,
        scale_to = 4,
      }          
    }
  }
  local particles_bubbles = Particles.new(particleConf)
  
  local onBegin = function()
  
  end

  local onUpdate = function(deltaTime)
    if particles_bubbles then
      particles_bubbles.update(deltaTime)
      
      if particles_bubbles.canRemove() then
        particles_bubbles = nil
      end
    end
  end
  
  local onDraw = function()
    
    if particles_bubbles then
      particles_bubbles.draw(0, 0)
      love.graphics.setColor(255, 0, 0, 255)
      love.graphics.print("Particles: " .. #particles_bubbles.particles, 100, 700) 
      love.graphics.setColor(255, 255, 255, 255)
    end
  end
  
  local onMouseReleased = function(x, y, button)
    
  end
  
  local onMousePressed = function(x, y, button)
    
  end
  
  local onStop = function()
    
  end

  scene = Scene.new(onBegin, onUpdate, onDraw, onMouseReleased, onMousePressed, onStop)
  
  -- Set up a few buttons and connect them to their scenes  
  local openPongAIScene = function()    
    local pongScene = PongScene.new("ai_smoothA", "ai_smoothB")  
    scene.addChildScene(pongScene)
    scene.buttons = {}
    particles_bubbles = nil
  end
  scene.registerButton(Button.newButton(32, 32, "gfx/pongai.png", "gfx/pongai.png", openPongAIScene, nil, {4, 4}))
  
  local openPongPvsAiScene = function()    
    local pongScene = PongScene.new("playerA", "ai_smoothB")  
    scene.addChildScene(pongScene)
    scene.buttons = {}
    particles_bubbles = nil
  end
  scene.registerButton(Button.newButton(32, 176, "gfx/pongpva.png", "gfx/pongpva.png", openPongPvsAiScene, nil, {4, 4}))

  local openPongPvPScene = function()    
    local pongScene = PongScene.new("playerA", "playerB")  
    scene.addChildScene(pongScene)
    scene.buttons = {}
    particles_bubbles = nil
  end
  scene.registerButton(Button.newButton(32, 320, "gfx/pongpvp.png", "gfx/pongpvp.png", openPongPvPScene, nil, {4, 4}))

  local openBreakoutScene = function()    
    local bscene = BreakoutScene.new()  
    scene.addChildScene(bscene)
    scene.buttons = {}
    particles_bubbles = nil
  end
  scene.registerButton(Button.newButton(love.graphics.getWidth() - 160, 32, "gfx/breakout.png", "gfx/breakout.png", openBreakoutScene, nil, {4, 4}))
  
  local openBreakoutFunScene = function()    
    local bscene = BreakoutFunScene.new()  
    scene.addChildScene(bscene)
    scene.buttons = {}
    particles_bubbles = nil
  end
  scene.registerButton(Button.newButton(love.graphics.getWidth() - 160, 176, "gfx/breakoutlol.png", "gfx/breakoutlol.png", openBreakoutFunScene, nil, {4, 4}))

  return scene
end

return debugScene 
