local DemoScene = require("demoScene")
local ParallaxScene = require("tests/parallaxScene")

local gamescene

function love.load(t) 
  print("--- BEGIN GAME ---")
  love.mouse.setVisible( true )

  if arg[#arg] == "-debug" then require("mobdebug").start() end -- start debugger for zerobrane
  math.randomseed(os.time()) -- init random
  
  love.graphics.setBackgroundColor(255, 255, 255) 
    
  gamescene = DemoScene.new()
--  gamescene = ParallaxScene.new()

  gamescene.begin()
end

function love.draw()

  gamescene.draw()

  love.graphics.print("FPS: " .. love.timer.getFPS(), love.graphics:getWidth() - 50, 2)
  love.window.setTitle( "DEMO" )
end

function love.mousereleased(x, y, button)

  gamescene.mousereleased(x, y, button)

end

function love.mousepressed(x, y, button)

  gamescene.mousepressed(x, y, button)

end

function love.update( dt )

  gamescene.update(dt)

end

