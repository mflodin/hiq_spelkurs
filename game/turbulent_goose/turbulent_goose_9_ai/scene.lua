local Scene = require("lib/scene")
local Collider = require("lib/collider")
local Actor = require("game/actor")
local Goose = require("game/turbulent_goose/turbulent_goose_9_ai/goose")
local Skyrock = require("game/turbulent_goose/turbulent_goose_9_ai/skyrock")
local Parallax = require("lib/parallax")
local Score = require("lib/score")
local Tween = require("lib/tween")
local WaitThen = require("lib/waitThen")
local Generic = require("lib/generic")

local turbulentGoose = {}
turbulentGoose.new = function(playerA_settings, playerB_settings)
  
  local goose = {} -- This is the object that contains the game-functions for the scene
  local gooseActors = {}
--  local gooseActor
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
  
  local fading = false
  local fade_time = 0.5
  
  local createGoose = function(y, controller, color) 
    
    color = color or {255, 255, 255, 255}
    
    local params = {
      position = { 100, y },
      direction = { 0, 0 },
      speed = Goose.speed,
      color = color,
      rotation = 0,
      scale = { 4, 4 },
      imagePath = Goose.gfx.image,
      controller = controller,
      hitBoxModifier = Goose.hitbox_relative,
    }
    local actor = Actor.new(params) 
    local gooseCollider = Collider.new(actor, Goose.event.onDeath(scene, actor, nil))
    actor.attachMeta({ 
      collider = gooseCollider,
      isGoose = true,
    }) 
    -- Attach meta collider manually instead of via the actor creation.
    -- This is because we havent created the actor yet and we need
    -- it for the collider. 
    -- Properly encapsulated, but maybe a bit messy?

    gooseActors[actor] = actor
    
    return actor
  end
  
  local createAiGoose = function(y, ai, color)    
    local params = {
      scene = scene,
      actors = actors,
      ai = ai
    }    
        
    return createGoose(y, Goose.AI.controller(params), color)     
  end
  
  local createPlayerGoose = function(y, color) 
    
    local gooseControllerParams = {
      jumpKey = " ",
      scene = scene,
      reset = nil,      
    }
    
    local meta = { 
      isPlayer = true
    }
    
    local controller = Goose.player_controller(gooseControllerParams)
    local actor = createGoose(y, controller, color) 
    actor.meta.isPlayer = true
    
    return actor
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
      controller = Skyrock.controller(), -- pass the collider to the controller so it can remove the actor
                                                -- from the collider upon reaching left side of the screen
      meta = {
        isSkyrock = true,
        isTop = isTop
      }
    }    
    local actor = Actor.new(params) 
    
    --Make it so that the collider adds the objects on each gooses collider instead  
    for key, goose in pairs(gooseActors) do
      goose.meta.collider.addObject(actor, Skyrock.collision.goose, Goose.collision.test.box) 
    end
        
    return actor
  end  
  
  
  local createSkyRocks = function(altitude) 
    local top = true
    local added_distance = -math.random(Skyrock.randomDistance)
    
    local topRock = createSkyRock(altitude + Skyrock.rockDistance + added_distance, top) 
    local botRock = createSkyRock(altitude, not(top))    
    actors[topRock] = topRock
    actors[botRock] = botRock
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
    
    local tweenTime = fade_time
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
  
  goose.fadeOut = function()
    fading = true
    
    local tweenTime = fade_time
    local current = { 
      a = 0,     
    }
    local target = {
      a = 255
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
    
    fading = false
        
    goose.fadeIn()
    
    spawnTimer = 0
    
    actors = {}
    
    --This is where we create the ai's! (and the player)
    
    local randomGoose = createAiGoose(300, Goose.AI.flaps_randomly, { 255, 100, 255, 128 })
    local timeGoose = createAiGoose(185, Goose.AI.flaps_every_half_second, { 255, 255, 100, 128 })
    local followGoose = createAiGoose(185, Goose.AI.follows_player, { 255, 0, 0, 128 })
    local dodgeGoose = createAiGoose(185, Goose.AI.avoids_nearest_skyrock, { 0, 0, 0, 128 })
    local dodgeGoose2 = createAiGoose(550, Goose.AI.avoids_nearest_skyrock, { 255, 100, 255, 128 })
    
    actors[dodgeGoose] = dodgeGoose    
    actors[dodgeGoose2] = dodgeGoose2
    actors[randomGoose] = randomGoose
    actors[timeGoose] = timeGoose
    actors[followGoose] = followGoose
    
    local player = createPlayerGoose(150, { 255, 255, 255, 255 })
    actors[player] = player
    
    createSkyRocks(Skyrock.first_rock)
    
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
    
    local activeGeese = 0
    for key, goose in pairs(gooseActors) do
      goose.meta.collider.update(deltaTime)
      
      activeGeese = activeGeese + 1
    end
    
    if activeGeese == 0 then
      if fading == false then        
        fading = true
        local waitUntilAnimationIsDone = WaitThen.new(Goose.animation.deathAnimationTime - 1, function()
          goose.fadeOut()
          local restartWaitThen = WaitThen.new(fade_time, function()
            goose.reset()
          end)      
          scene.addWaitThen(restartWaitThen)            
        end)
        scene.addWaitThen(waitUntilAnimationIsDone)
        
      end
    end
    
    spawnTimer = spawnTimer + deltaTime
    
    if spawnTimer > Skyrock.spawnTime then
      createSkyRocks(Skyrock.space + math.random(Skyrock.spawnPos_y))
      spawnTimer = spawnTimer - Skyrock.spawnTime
      
      if activeGeese then
        currentScore.add(1) 
      end
    end
    
    for key, actor in pairs(actors) do
      actor.update(deltaTime)
     
      if actor.remove then       

        if gooseActors[actor] then 
          gooseActors[actor].meta.collider = nil
          gooseActors[actor] = nil          
        else 
          --remove skyrock from all colliders
          for key, goose in pairs(gooseActors) do
            goose.meta.collider.removeObject(actor)
          end
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
