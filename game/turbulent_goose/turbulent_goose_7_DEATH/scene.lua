local Scene = require("lib/scene")
local Collider = require("lib/collider")
local Actor = require("game/actor")
local Goose = require("game/turbulent_goose/turbulent_goose_7_DEATH/goose")
local Skyrock = require("game/turbulent_goose/turbulent_goose_7_DEATH/skyrock")

local turbulentGoose = {}
turbulentGoose.new = function(playerA_settings, playerB_settings)
  
  local goose = {} -- This is the object that contains the game-functions for the scene
  local gooseActor
  local scene = {} -- We will allocate this using the scene later. 
  local actors = {} -- List of actors
  local collider = nil
  
  local spawnTime = 2.5
  local spawnTimer = 0
  
  local createGoose = function() 
    
    local gooseControllerParams = {
      jumpKey = " ",
      scene = scene,
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
  
  local onBegin = function()
    love.graphics.setBackgroundColor(94, 169, 255) 
    
    actors = {}
    
    local goose = createGoose()
    actors[#actors + 1] = goose
    
    --We're just adding collision, not what actually happens when we collide.
    --For now, we just turn the sky red.
    collider = Collider.new(goose, Goose.animation.death(scene, goose))
    
    createSkyRocks(Skyrock.start_y)
    
  end

  local onUpdate = function(deltaTime)
    if collider then
      collider.update(deltaTime)
    end
    
    spawnTimer = spawnTimer + deltaTime
    
    if spawnTimer > spawnTime then
      createSkyRocks(Skyrock.space + math.random(Skyrock.start_y))
      spawnTimer = spawnTimer - spawnTime
    end
    
    for key, actor in pairs(actors) do
      actor.update(deltaTime)
     
      if actor.remove then
        if actor == gooseActor then
          collider = nil --This is spaghett-ish code. It should be stored as a meta function on the goose. 
        end   
      
        if collider then
          collider.removeObject(actor)
        end
        
        actors[key] = nil
      end
      
    end
    
  end
  
  local onDraw = function()
    
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

return turbulentGoose 
