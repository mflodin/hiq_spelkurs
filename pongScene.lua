local Scene = require("lib/scene")
local Quad = require("lib/quad")
local Collider = require("lib/collider")
local Actor = require("game/actor")
local Ball = require("game/pong/ball_pong")
local Paddle = require("game/pong/paddle_pong")

local pongScene = {}
pongScene.new = function(playerA_settings, playerB_settings)
  
  local pong = {}
  local scene = {}  
  local actors = {}
  local ball_paddle_collider = nil
  local ball = nil
  local paddleLeft, paddleRight
  
  local score_left, score_right = 0, 0
  local numbersLeft, numbersRight = {}, {}
  
  pong.createBall = function(direction)
    direction = direction or -1 --if no direction, move it towards left
    
    local resetToLeft = function()
      score_left = score_left + 1
      if score_left > 9 then
        score_left = 0
        score_right = 0
      end
      pong.reset(-1)
    end
    
    local resetToRight = function()
      score_right = score_right + 1
      if score_right > 9 then
        score_left = 0
        score_right = 0
      end      
      pong.reset(1)
    end
    
    local ballControllerParams = {
      speedIncrease = Ball.speedIncrease,
      onHitLeft = resetToRight,
      onHitRight = resetToLeft,
      onHitDown = nil,
      onHitUp = nil,
    }
    
    local ballParams = {
      position = { 400, love.graphics.getHeight() / 2 },
      direction = { direction, 0 },
      speed = Ball.speed,
      rotation = 0,
      scale = { 2, 2 },
      imagePath = Ball.gfx.image,
      controller = Ball.controller(ballControllerParams),
    }
    
    return Actor.new(ballParams)    
  end
  
  pong.getPaddleController = function(settings, ball)
    local controllers = {
      playerA = Paddle.Player("w", "s"),
      playerB = Paddle.Player("up", "down"),
      ai_smoothA = Paddle.AI.smoothA(ball),
      ai_smoothB = Paddle.AI.smoothB(ball),
    }
        
    return controllers[settings]
  end
  
  pong.createPaddle = function(settings, side)
    
    local position, imagePath
    if side == "left" then
      imagePath = Paddle.gfx.left
      position = { 32, love.graphics.getHeight() / 2 }
    else
      imagePath = Paddle.gfx.right
      position = { love.graphics.getWidth() - 32, love.graphics.getHeight() / 2 }
    end
    
    local paddleParams = {
      position = position,
      direction = { 0, 0 },
      speed = Paddle.speed.ai, -- Here's a bug!
      rotation = 0,
      scale = { 2, 2 },
      imagePath = imagePath,
      controller = nil,
    }
    return Actor.new(paddleParams)
  end
  
  pong.addActor = function(actor)
    --For those of you not used to non-typed languages, here we are setting an array with [object] and we index it to the pointer of the [object]
    --This makes it really easy to just remove an object later, to find it we just need to own it. The downside is that we wont be able to sort our array.
    actors[actor] = actor
  end
  
  pong.removeActor = function(actor)
    actors[actor] = nil
  end
  
  pong.reset = function(ballDirection) 
    ballDirection = ballDirection or 1 --If we dont have a direction, go right
    
    if ball then 
      pong.removeActor(ball)
    end
    
    ball = pong.createBall(ballDirection)
    pong.addActor(ball)
    
    ball_paddle_collider = Collider.new(ball, Ball.collision.paddle)
    ball_paddle_collider.addObject(paddleLeft, Paddle.collision.ball, Ball.collision.test.paddle)
    ball_paddle_collider.addObject(paddleRight, Paddle.collision.ball, Ball.collision.test.paddle)
    
    paddleLeft.setController(pong.getPaddleController(playerA_settings, ball))
    paddleRight.setController(pong.getPaddleController(playerB_settings, ball))
    
  end  
  
  local onBegin = function()
    
    paddleLeft = pong.createPaddle(playerA_settings, "left")
    pong.addActor(paddleLeft)
    
    paddleRight = pong.createPaddle(playerB_settings, "right")
    pong.addActor(paddleRight)
    
     --Ugly hack to get the AI's going
    if playerA_settings == "ai_smoothA" and playerB_settings == "ai_smoothB" then
      paddleRight.direction.y = -1
--      paddleRight.position.y = love.graphics.getHeight() / 2 + 100
    end
    
    --set up numbers so we can render the score
    local quadParamsLeft = { image = "gfx/numbers_inv.png", rows = 10, columns = 1, scale = {80, 80} }
    local quadLeft = Quad.new(quadParamsLeft)
    local quadParamsRight = { image = "gfx/numbers_inv.png", rows = 10, columns = 1, scale = {80, 80} }
    local quadRight = Quad.new(quadParamsRight)
    
    for i = 0, 9 do
      table.insert(numbersLeft, quadLeft.getRenderable(i, 0))
      table.insert(numbersRight, quadRight.getRenderable(i, 0))
    end
    
    pong.reset(); -- This also creates the ball.
  end

  local onUpdate = function(deltaTime)
    for key, actor in pairs(actors) do
      actor.update(deltaTime)
    end
    
    ball_paddle_collider.update(deltaTime)
  end
  
  local onDraw = function()
    
    --draw the blue right part of screen
    love.graphics.setColor(100, 180, 255, 255)
    love.graphics.rectangle( "fill", 400, 0, 400, 800 )
    
    --draw the score (first, so its behind everything)
    numbersLeft[score_left + 1].draw(0, 100)
    love.graphics.setColor(255, 255, 255, 255)
    
    numbersRight[score_right + 1].draw(400, 100)
    
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

return pongScene 
