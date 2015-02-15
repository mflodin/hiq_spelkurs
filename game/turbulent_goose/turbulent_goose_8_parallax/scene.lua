local Scene = require("lib/scene")
local Collider = require("lib/collider")
local Actor = require("game/actor")
local Goose = require("game/turbulent_goose/turbulent_goose_8_parallax/goose")
local Skyrock = require("game/turbulent_goose/turbulent_goose_8_parallax/skyrock")
local Parallax = require("lib/parallax")
local Score = require("lib/score")
local Tween = require("lib/tween")
local WaitThen = require("lib/waitThen")
local Generic = require("lib/generic")

local turbulentGoose = {}
turbulentGoose.new = function(playerA_settings, playerB_settings)
  
  local goose = {} -- This is the object that contains the game-functions for the scene
  local gooseActor
  local scene = {} -- We will allocate this using the scene later. 
  local actors = {} -- List of actors
  local collider = nil
  
  local spawnTime = 2.5
  local spawnTimer = 0
  
  local skyPosition = { x = 0, y = 0 }
  local skySpeed = -10
  local parallax_far 
  local parallax_near 
  
  local bestScore = nil
  local currentScore = nil
  local currentScore_float = 0
  
  local createGoose = function(reset) 
    
    local gooseControllerParams = {
      jumpKey = " ",
      scene = scene,
      reset = reset
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
    gooseActor = Actor.new(gooseParams)    
    
    return gooseActor
  end
  
  local createSkyRock = function(altitude, isTop) 
    local image = Skyrock.gfx.down
    if isTop then
      image = Skyrock.gfx.up
    end
    
    local params = {
      position = { love.graphics.getWidth() + 100, altitude }, 
      direction = { 0, 0 },
      speed = Skyrock.speed,
      rotation = 0,
      scale = { 4, 4 },
      imagePath = image,
      controller = Skyrock.controller() -- pass the collider to the controller so it can remove the actor
                                                -- from the collider upon reaching left side of the screen
    }    
    local actor = Actor.new(params) 
    if collider then 
      collider.addObject(actor, Skyrock.collision.goose, Goose.collision.test.box) 
    end
        
    return actor
  end  
  
  local createSkyRocks = function(altitude) 
    local top = true
    local added_distance = -math.random(Skyrock.randomDistance)
    
    actors[#actors + 1] = createSkyRock(altitude + Skyrock.rockDistance + added_distance, top)
    actors[#actors + 1] = createSkyRock(altitude, not(top))    
  end
  
  local setupParallax = function(position)
    local far_params = {
      position_link = goose.position,
      segments = {
        { 
          image = "gfx/goose/cloud.png",
          multiplier = { x = 1.1 },  
          scale = { 4, 4 },
          y = 170,
        },
        {
          image = "gfx/goose/cloud.png",
          multiplier = { x = 1.4 },    
          scale = { 5, 5 },
          y = 210,
        },
        {
          image = "gfx/goose/cloud.png",
          multiplier = { x = 3.0 },    
          scale = { 6, 6 },
          y = 320,
        },
      }
    }
    parallax_far = Parallax.new(position, far_params)
    
    local near_params = {
      position_link = goose.position,
      segments = {
        { 
          image = "gfx/goose/cloud.png",
          multiplier = { x = 7.0 },  
          scale = { 10, 10 },
          y = 500,
        },
      }
    }
    parallax_near = Parallax.new(position, near_params)    
  end
  setupParallax(skyPosition) --Notice that we're setting this up here and not on onBegin - we dont need or want to reset this.
  
  goose.fadeIn = function()
    local tweenTime = 0.5
    local current = { 
      a = 255,     
    }
    local target = {
      a = 0
    }
    
    local function draw()
      love.graphics.setColor(0, 0, 0, current.a)
      love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())      
      love.graphics.setColor(255, 255, 255, 255)
    end
    
    scene.addGeneric(Generic.new(draw), tweenTime)
    
    local tween = Tween.new(tweenTime, current, target, "linear")
    scene.addTween(tween)
  end
  
  goose.reset = function()
    goose.fadeIn()
    
    spawnTimer = 0
    
    actors = {}
    
    local bird = createGoose(goose.reset)
    actors[#actors + 1] = bird
    
    --We're just adding collision, not what actually happens when we collide.
    --For now, we just turn the sky red.
    collider = Collider.new(bird, Goose.event.onDeath(scene, bird, goose.reset))
    
    createSkyRocks(Skyrock.start_y)
    
    local previousScore = 0
    if bestScore then
      previousScore = bestScore.score
    end
    
    local bestScoreParams = {
      start_score = previousScore,
      numbers_max = 4,
      color = { 50, 100, 150, 200 },
      position = { x = 640, y = 550 },
      numbersQuad = {
        image = "gfx/numbers_inv.png",
        rows = 10, 
        columns = 1, 
        scale = {10, 10},
      },  
    } 
    bestScore = Score.new(bestScoreParams)
    
    local scoreParams = {
      start_score = 0,
      numbers_max = 4,
      color = { 200, 100, 50, 200 },
      position = { x = 640, y = 500 },
      numbersQuad = {
        image = "gfx/numbers_inv.png",
        rows = 10, 
        columns = 1, 
        scale = {10, 10},
      },  
    } 
    currentScore = Score.new(scoreParams)
  end
  
  local onBegin = function()
    love.graphics.setBackgroundColor(94, 169, 255) 
    goose.reset()
  end

  local onUpdate = function(deltaTime)
    
    if currentScore.score > bestScore.score then
      bestScore.set(currentScore.score)
      bestScore.color = { 255, 0, 0, 200 }
    end
    
    if collider then
      collider.update(deltaTime)
    end
    
    spawnTimer = spawnTimer + deltaTime
    
    if spawnTimer > spawnTime then
      createSkyRocks(Skyrock.space + math.random(Skyrock.start_y))
      spawnTimer = spawnTimer - spawnTime
      
      if gooseActor then
        currentScore.add(1) 
      end
    end
    
    for key, actor in pairs(actors) do
      actor.update(deltaTime)
     
      if actor.remove then
        if actor == gooseActor then
          collider = nil --This is spaghett-ish code. It should be stored as a meta function on the goose. 
          gooseActor = nil
        end   
      
        if collider then
          collider.removeObject(actor)
        end
        
        actors[key] = nil
      end
      
    end
    
    skyPosition.x = skyPosition.x + (skySpeed * deltaTime)
    
  end
  
  local onDraw = function()
    
    parallax_far.draw()
    
    --draw all the actors (ball, left and right paddle)
    for key, actor in pairs(actors) do
      actor.draw()
    end
    
    parallax_near.draw()
    
    currentScore.draw()
    bestScore.draw()
        
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
