local Scene = require("lib/scene")
local Quad = require("lib/quad")
local Collider = require("lib/collider")
local Actor = require("game/actor")
local Ball = require("game/pong/ball_pong")
local Paddle = require("game/pong/paddle_pong")

local pongScene = {}
pongScene.new = function(playerA_settings, playerB_settings)
  
  local pong = {} -- This is the object that contains the game-functions for the scene
  local scene = {} -- We will allocate this using the scene later. 
  local actors = {} -- List of actors
  
  local ball_paddle_collider = nil
  local ball = nil
  local paddleLeft, paddleRight
  
  local score_left, score_right = 0, 0
  local numbersLeft, numbersRight = {}, {}
  
  -- Creates the ball and ties it to the scene logic.
  -- Returns a ball actor.
  pong.createBall = function(direction)
    direction = direction or -1 --if no direction, move it towards left. If more moving positively, we're moving to the right.
    
    --Callbacks used to give a score for when the ball touches left or right side. We pass these into the ball controller later.
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
  
  -- Sets up the controllers of each type and returns them in an array.
  pong.getPaddleController = function(settings, ball)
    local controllers = {
      playerA = Paddle.Player("w", "s"),
      playerB = Paddle.Player("up", "down"),
      ai_smoothA = Paddle.AI.smoothA(ball),
      ai_smoothB = Paddle.AI.smoothB(ball),
    }
    -- Now we can find the player controller in controllers[playerA] or controllers.playerA. It's all the same in lua.
        
    return controllers[settings]
  end
  
  --Creates a paddle 
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
      speed = Paddle.speed.ai, -- Here's a bug! It should use the players speed if it can. Unfortunately we havent really 
                               -- determined what the paddle will be used for yet. We should just set it later when we set
                               -- the controller.                
      rotation = 0,
      scale = { 2, 2 },
      imagePath = imagePath,
      controller = nil,
    }
    return Actor.new(paddleParams)
  end
  
  pong.addActor = function(actor)
    -- For those of you not used to non-typed languages, here we are setting an array with [object] and we index it to the pointer of the [object]
    -- So, if the pointer allocation = 0xe032b4 then we're setting it to actors[0xe032b4]. This makes it really easy to just remove an object later. 
    -- The downsides to having this useful array type is that it's hard to find the object if you dont own the pointer address somewhere without
    -- looping through the array, and indexing the array is meaningless.
    actors[actor] = actor
  end
  
  pong.removeActor = function(actor)
    --This is why its so useful. We dont need to loop through the array to clear out the object now. Any array[key] element set to nil is removed from the memory.
    actors[actor] = nil
  end
  
  pong.reset = function(ballDirection) 
    ballDirection = ballDirection or 1 --If we dont have a direction, go right!
    
    if ball then 
      pong.removeActor(ball)
    end
    
    ball = pong.createBall(ballDirection)
    pong.addActor(ball)
    
    -- Set up the collisions. The ball is what everything in the collider tries to collide against.
    ball_paddle_collider = Collider.new(ball, Ball.collision.paddle)
    
    -- Here we're doing: Add paddleLeft to the list of objects that are going to collide with the ball
    -- Use the function Ball.collision.test.paddle() to see if we collide with the ball
    -- If we do collide with the ball, run the function Paddle.collision.ball()
    -- By doing it this way we can easily set up the behaviour of each object vs each object.
    ball_paddle_collider.addObject(paddleLeft, Paddle.collision.ball, Ball.collision.test.paddle)
    ball_paddle_collider.addObject(paddleRight, Paddle.collision.ball, Ball.collision.test.paddle)
    
    -- ...we really should set the correct speed here. Or we move it inside the paddle setup. Or into the next function, onBegin. Feel free to! :)
    paddleLeft.setController(pong.getPaddleController(playerA_settings, ball))
    paddleRight.setController(pong.getPaddleController(playerB_settings, ball))
    
  end  
  
  local onBegin = function()
    
    paddleLeft = pong.createPaddle(playerA_settings, "left")
    pong.addActor(paddleLeft)
    
    paddleRight = pong.createPaddle(playerB_settings, "right")
    pong.addActor(paddleRight)
    
     --Ugly hack to get the AI's going. We just give the right side a push upwards, so that it'll wobble around and not hit the ball in a perfect 270' angle.
    if playerA_settings == "ai_smoothA" and playerB_settings == "ai_smoothB" then
      paddleRight.direction.y = -1
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
    -- Deltatime is: (Current time) - (Previous onUpdates time).
    -- We use it to make sure everything has a constant speed.
    
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

  -- There we go! The games ticking!
  scene = Scene.new(onBegin, onUpdate, onDraw, onMouseReleased, onMousePressed, onStop)
  
  return scene
end

return pongScene 
