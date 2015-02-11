local Scene = require("lib/scene")
local Collider = require("lib/collider")

local Actor = require("game/actor")
local Paddle = require("game/breakout/paddle_breakout")
local Ball = require("game/breakout/ball_breakout")
local Brick = require("game/breakout/brick_breakout")

local breakOutScene = {}
breakOutScene.new = function()
  local scene = {}
  local actors = {}
  local collider = nil
  local backgroundColor = {255, 255, 255, 255}
  local ball_locked = true
  local ball = nil
  local paddle = nil
  
  local game = {}
  
  --step 1:
  --create the ball
  game.createBall = function()
    
    local ballControllerParams = {
      speedIncrease = Ball.speedIncrease,
      onHitLeft = nil,
      onHitRight = nil,
      onHitDown = nil,
      onHitUp = nil,
    }
    
    local ballParams = {
      position = { love.graphics.getWidth() / 2, love.graphics.getHeight() - 65 },
      direction = { 0, 0 },
      speed = Ball.speed,
      rotation = 0,
      scale = { 2, 2 },
      imagePath = Ball.gfx.image,
      controller = Ball.controller(ballControllerParams),
    }
    
    ball = Actor.new(ballParams)    
    return ball
  end
  
  game.createPaddle = function(settings)
    
    local paddleParams = {
      position = { love.graphics.getWidth() / 2, love.graphics.getHeight() - 32 },
      direction = { 0, 0 },
      speed = Paddle.speed, 
      rotation = 0,
      scale = { 2, 2 },
      imagePath = Paddle.gfx.image,
      controller = Paddle.Player(),
    }
    paddle = Actor.new(paddleParams)
    return paddle
  end
  
  game.createBrick = function(position)
    local brickParams = {
      position = position,
      direction = { 0, 0 },
      speed = 0, 
      rotation = 0,
      scale = { 2, 2 },
      imagePath = Brick.gfx.image,
      controller = nil,
    }
    return Actor.new(brickParams)
  end
  
  game.spawnLevelOne = function()
    local colors = {      
      {255, 255, 255, 255},
    }
    
    for x = 1, 9 do
      for y = 1, 5 do
        
        local brickParams = {
          position = { 64 + (x * 68), 64 + (y * 36) },
          direction = { 0, 0 },
          color = colors[(x + y) % #colors],
          speed = 0, 
          rotation = 0,
          scale = { 2, 2 },
          imagePath = Brick.gfx.image,
          controller = Brick.Logic(),
        }
        local actor = Actor.new(brickParams)
        game.addActor(actor)
        collider.addObject(actor, Brick.collision.ball, Ball.collision.test.box)
      end
    end
    
  end
  
  game.addActor = function(actor)
    actors[actor] = actor
  end
  
  game.removeActor = function(actor)
    actors[actor] = nil
  end
  
  local onBegin = function()
    local ball = game.createBall()
    game.addActor(ball)
    
    local paddle = game.createPaddle()
    game.addActor(paddle)
    
    collider = Collider.new(ball, Ball.collision.nothing)
    collider.addObject(paddle, Paddle.collision.ball, Ball.collision.test.box)
    
    game.spawnLevelOne()
    
  end

  local onUpdate = function(deltaTime)
    collider.update(deltaTime)
    
    for key, actor in pairs(actors) do
      actor.update(deltaTime)
      
      if actor.remove then
        collider.removeObject(actor)
        actors[key] = nil
      end
    end
    
    if ball_locked then
      ball.position.x = paddle.position.x
    end
  end
  
  local onDraw = function()
    love.graphics.setBackgroundColor(backgroundColor) 
    
    for key, actor in pairs(actors) do
      actor.draw()
    end
  end
  
  local onMouseReleased = function(x, y, button)
    if ball_locked then
      ball_locked = false
      ball.direction = { x = 0.5, y = -0.5 }
    end
  end
  
  local onMousePressed = function(x, y, button)
    
  end
  
  local onStop = function()
    
  end

  scene = Scene.new(onBegin, onUpdate, onDraw, onMouseReleased, onMousePressed, onStop)
  
  return scene
end

return breakOutScene 

