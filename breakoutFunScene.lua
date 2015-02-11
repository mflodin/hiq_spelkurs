local Scene = require("lib/scene")
local Collider = require("lib/collider")
local Tween = require("lib/Tween")
local WaitThen = require("lib/waitThen")

local Actor = require("game/actor")
local Paddle = require("game/breakout_fun/paddle_breakout")
local Ball = require("game/breakout_fun/ball_breakout")
local Brick = require("game/breakout_fun/brick_breakout")
local Score = require("game/breakout_fun/score")
local Lives = require("game/breakout_fun/lifeAnimation")
local Levels = require("game/breakout_fun/levels")

local Imagelib = require("lib/imageLib")

local breakOutScene = {}
breakOutScene.new = function()
  local scene = {}
  local game = {}  
  local actors = {}
  local collider = nil
  local backgroundColor = {255, 255, 255, 255}
  local ball_locked = true
  local ball = nil
  local paddle = nil
  local score = nil
  local lives = {}
  local level = 1
  local levels = {
    Levels.spawnLevelOne,
    Levels.spawnLevelTwo,
    Levels.spawnLevelThree,
    Levels.spawnLevelFour    
  }
  
  game.nextLevel = function()
    levels[level](scene, game, collider, score)
    level = level + 1
    if level > #levels then
      level = 1
    end
  end
  
  game.createLives = function()
    local lifeSize = 32
    local xDif = -34
    for i = 1, 3 do
      local offset = xDif * (i - 1)
      local lifeParams = {
        image = "gfx/ball.png",
        scale = { 2, 2 },
        position = { x = love.graphics.getWidth() - lifeSize + offset, y = love.graphics.getHeight() - lifeSize },
        jumpAtTime = 2,
        timeOffsetAtStartInSeconds = 0.2 * (i - 1),  
        jumpHeightInPixels = 50,
      }

      lives[#lives + 1] = Lives.new(scene, lifeParams)
    end
  end
  
  game.removeLife = function()
    if #lives == 0 then
      love.event.quit( )
    end
    
    if #lives > 0 then
      table.remove(lives, #lives)
    end    
  end
  
  game.createBall = function()
    
    local ballControllerParams = {
      speedIncrease = Ball.speedIncrease,
      onHitLeft = nil,
      onHitRight = nil,
      onHitDown = game.removeLife,
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
      meta = {
        onHit = Paddle.animations.boink(scene),
      }
    }
    paddle = Actor.new(paddleParams)
    return paddle
  end
    
  game.addActor = function(actor)
    actors[actor] = actor
  end
      
  local onBegin = function()
    local ball = game.createBall()
    game.addActor(ball)
    
    local paddle = game.createPaddle()
    game.addActor(paddle)
    
    collider = Collider.new(ball, Ball.collision.nothing)
    collider.addObject(paddle, Paddle.collision.ball, Ball.collision.test.box)
    
    local scoreParams = {
      start_score = 0,
      numbers_max = 8,
      color = { 200, 200, 200, 255 },
      position = { x = 74, y = 16 },
      numbersQuad = {
        image = "gfx/numbers_inv.png",
        rows = 10, 
        columns = 1, 
        scale = {20, 20},
      },  
    } 
    score = Score.new(scoreParams)
    
    game.createLives()
    
    game.nextLevel()
    
  end

  local onUpdate = function(deltaTime)
    collider.update(deltaTime)
    
    local actorsNum = 0
    for key, actor in pairs(actors) do
      actor.update(deltaTime)
      
      if actor.remove then
        collider.removeObject(actor)
        actors[key] = nil
      end
      
      actorsNum = actorsNum + 1
    end
    
    if actorsNum == 2 then -- We only have the ball and the paddle now. Next level!
      game.nextLevel()
      ball_locked = true
      ball.position.y = love.graphics.getHeight() - 65
      ball.direction = { x = 0, y = 0 }
    end
    
    if ball_locked then
      ball.position.x = paddle.position.x
    end
    
  end
  
  local onDraw = function()    
    love.graphics.setBackgroundColor(backgroundColor) 
    score.draw()
    
    for i = 1, #lives do
      lives[i].draw()
    end
    
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

