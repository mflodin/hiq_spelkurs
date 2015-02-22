local Scene = require("lib/scene")
local Button = require("lib/button")
local Imagelib = require("lib/imagelib")

local PongScene = require("game/pong/scene")
local BreakoutScene = require("game/breakout/scene")
local BreakoutFunScene = require("game/breakout_fun/scene")
local ParallaxScene = require("tests/parallaxScene")

local Goose1Scene = require("game/turbulent_goose/turbulent_goose_1_start/scene")
local Goose2Scene = require("game/turbulent_goose/turbulent_goose_2_gravity/scene")
local Goose3Scene = require("game/turbulent_goose/turbulent_goose_3_jump/scene")
local Goose4Scene = require("game/turbulent_goose/turbulent_goose_4_simpleAnimation/scene")
local Goose5Scene = require("game/turbulent_goose/turbulent_goose_5_enemies/scene")
local Goose6Scene = require("game/turbulent_goose/turbulent_goose_6_collision/scene")
local Goose7Scene = require("game/turbulent_goose/turbulent_goose_7_DEATH/scene")
local Goose8Scene = require("game/turbulent_goose/turbulent_goose_8_parallax/scene")
local Goose9Scene = require("game/turbulent_goose/turbulent_goose_9_ai/scene")

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

  local openParallaxScene = function()    
    local bscene = ParallaxScene.new()
    scene.addChildScene(bscene)
    scene.buttons = {}
    particles_bubbles = nil
  end
  scene.registerButton(Button.newButton(196, 32, "gfx/parallax.png", "gfx/parallax.png", openParallaxScene, nil, {4, 4}))  
  
  local openGoose1Scene = function()    
    local bscene = Goose1Scene.new()
    scene.addChildScene(bscene)
    scene.buttons = {}
    particles_bubbles = nil
  end
  scene.registerButton(Button.newButton(196 + 160, 32, "gfx/goose/button.png", "gfx/goose/button.png", openGoose1Scene, nil, {2, 2}))
  
  local openGoose2Scene = function()    
    local bscene = Goose2Scene.new()
    scene.addChildScene(bscene)
    scene.buttons = {}
    particles_bubbles = nil
  end
  scene.registerButton(Button.newButton(196 + 160 + 70, 32, "gfx/goose/button2.png", "gfx/goose/button2.png", openGoose2Scene, nil, {2, 2}))  
  
  local openGoose3Scene = function()    
    local bscene = Goose3Scene.new()
    scene.addChildScene(bscene)
    scene.buttons = {}
    particles_bubbles = nil
  end
  scene.registerButton(Button.newButton(196 + 160, 102, "gfx/goose/button3.png", "gfx/goose/button3.png", openGoose3Scene, nil, {2, 2}))    
  
  local openGoose4Scene = function()    
    local bscene = Goose4Scene.new()
    scene.addChildScene(bscene)
    scene.buttons = {}
    particles_bubbles = nil
  end
  scene.registerButton(Button.newButton(196 + 160 + 70, 102, "gfx/goose/button4.png", "gfx/goose/button4.png", openGoose4Scene, nil, {2, 2}))    
  
  local openGoose5Scene = function()    
    local bscene = Goose5Scene.new()
    scene.addChildScene(bscene)
    scene.buttons = {}
    particles_bubbles = nil
  end
  scene.registerButton(Button.newButton(196 + 160, 172, "gfx/goose/button5.png", "gfx/goose/button5.png", openGoose5Scene, nil, {2, 2}))    
  
  local openGoose6Scene = function()    
    local bscene = Goose6Scene.new()
    scene.addChildScene(bscene)
    scene.buttons = {}
    particles_bubbles = nil
  end
  scene.registerButton(Button.newButton(196 + 160 + 70, 172, "gfx/goose/button6.png", "gfx/goose/button6.png", openGoose6Scene, nil, {2, 2}))    
  
  local openGoose7Scene = function()    
    local bscene = Goose7Scene.new()
    scene.addChildScene(bscene)
    scene.buttons = {}
    particles_bubbles = nil
  end
  scene.registerButton(Button.newButton(196 + 160, 242, "gfx/goose/button7.png", "gfx/goose/button7.png", openGoose7Scene, nil, {2, 2})) 
  
  local openGoose8Scene = function()    
    local bscene = Goose8Scene.new()
    scene.addChildScene(bscene)
    scene.buttons = {}
    particles_bubbles = nil
  end
  scene.registerButton(Button.newButton(196 + 160 + 70, 242, "gfx/goose/button8.png", "gfx/goose/button8.png", openGoose8Scene, nil, {2, 2})) 
  
  local openGoose9Scene = function()    
    local bscene = Goose9Scene.new()
    scene.addChildScene(bscene)
    scene.buttons = {}
    particles_bubbles = nil
  end
  scene.registerButton(Button.newButton(196 + 160, 312, "gfx/goose/button9.png", "gfx/goose/button9.png", openGoose9Scene, nil, {2, 2})) 
  
  return scene
end

return debugScene 
