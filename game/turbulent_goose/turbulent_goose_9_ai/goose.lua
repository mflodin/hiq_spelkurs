local Collision = require("lib/collision")
local Vector = require("lib/vector")
local Imagelib = require("lib/imagelib")
local Tween = require("lib/tween")
local WaitThen = require("lib/waitThen")
local Generic = require("lib/generic")

local Goose = {}
  
Goose.gfx = {
  image = "gfx/goose/turbulentGoose_down.png",
  down = "gfx/goose/turbulentGoose_down.png",
  up = "gfx/goose/turbulentGoose_up.png",
  explode = "gfx/goose/explode.png"
}

-- We're preloading the images in this scope. Since the Imagelib shares all the images interally we dont really
-- lose any performance by doing this.
Goose.image = {}
Goose.image.up = Imagelib.getImage(Goose.gfx.down)
Goose.image.down = Imagelib.getImage(Goose.gfx.up)
Goose.image.explode = Imagelib.getImage(Goose.gfx.explode)

Goose.jumpSpeed = -7
Goose.fallSpeed_max = 10
Goose.gravity = 20
Goose.rotationMax = 0.2

Goose.hitbox_relative = { --This gives us a much more "fun" hitbox to play with
  x = 10,
  y = 10,
  w = -10,
  h = -20  
}

Goose.event = {}
Goose.event.onDeath = function(scene, actor, reset) --reset is optional
  
  return function()
    Goose.animation.death(scene, actor)()
  
    if reset then
      local waitThen = WaitThen.new(Goose.animation.deathAnimationTime + 1.5, function()
        reset()
      end)  
      scene.addWaitThen(waitThen)
      
    end
    
  end
  
end

Goose.collision = {}
Goose.collision.test = {}
Goose.collision.test.box = function(goose, skyRock)  
  return Collision.boxVsBox(goose.box, skyRock.box)  
end

Goose.animation = {}
Goose.animation.deathAnimationTime = 2
Goose.animation.death = function(scene, actor)
  
  return function()
    
    local tweenTime = Goose.animation.deathAnimationTime
    local image = actor.image
    local explo = Goose.image.explode
    local gooseAni = { 
      r = actor.rotation,
      x = actor.position.x, 
      y = actor.position.y,
      scale = actor.scale.w,
      rgba = 255,
      x_explo = actor.position.x,
      y_explo = actor.position.y,
      r_explo = 0,
      scale_explo = 4,
    }
    local targetAni = {
      r = math.random(20) - 10,
      x = math.random(love.graphics.getWidth()), 
      y = math.random(love.graphics.getHeight()),
      scale = math.random(20),
      rgba = 0,
      x_explo = actor.position.x,
      y_explo = actor.position.y,
      r_explo = 0.4,
      scale_explo = 12
    }
    
    local function draw()
      love.graphics.setColor(255, gooseAni.rgba, gooseAni.rgba, gooseAni.rgba)
      love.graphics.draw(image, gooseAni.x, gooseAni.y, gooseAni.r, gooseAni.scale, gooseAni.scale, image:getWidth() / 2, image:getHeight() / 2)
      love.graphics.setColor(gooseAni.rgba, gooseAni.rgba, gooseAni.rgba, gooseAni.rgba)
      love.graphics.draw(explo, gooseAni.x_explo, gooseAni.y_explo, gooseAni.r_explo, gooseAni.scale_explo, gooseAni.scale_explo, explo:getWidth() / 2, explo:getHeight() / 2)
      love.graphics.setColor(255, 255, 255, 255)
    end
    
    scene.addGeneric(Generic.new(draw), tweenTime)
    
    local tween = Tween.new(tweenTime, gooseAni, targetAni, "outQuad")
    scene.addTween(tween)    
    
  end
end

local calculateGravity = function(fallSpeed, deltaTime) --returns new fallspeed            
  return math.min(fallSpeed + (Goose.gravity * deltaTime), Goose.fallSpeed_max)
end

Goose.AI = {}
Goose.AI.falls_to_its_death = function(goose, deltaTime, actors)
  return false -- Never flaps.
end

Goose.AI.flaps_furiously = function(goose, deltaTime, actors)
  
  if goose.position.y > 320 then
    return true
  end
  
  return false
end

Goose.AI.flaps_every_half_second = function(goose, deltaTime, actors)
  
  local flapAt = 0.8 --this is a nice number, lets use that
  
  --attach some extra metadata to keep track of time...
  if goose.meta.timetrack == nil then 
    goose.meta.timetrack = 0.71
  end
  goose.meta.timetrack = goose.meta.timetrack + deltaTime
  
  if goose.meta.timetrack > flapAt then
    goose.meta.timetrack = goose.meta.timetrack - flapAt
    return true
  end
  
  return false  
end

Goose.AI.flaps_randomly = function(goose, deltaTime, actors)
  local flapAt = 0.8   
  
  --attach some extra metadata to keep track of time...
  if goose.meta.timetrack == nil then 
    goose.meta.timetrack = flapAt
  end
  goose.meta.timetrack = goose.meta.timetrack + deltaTime
  
  if goose.meta.timetrack > flapAt then
    goose.meta.timetrack = goose.meta.timetrack - flapAt
    flapAt = math.random()
    
    return true
  end
  
  return false  
end

Goose.AI.follows_player = function(goose, deltaTime, actors)
  
  local function findPlayer()
    for key, actor in pairs(actors) do
      if actor.meta.isPlayer then
        return actor
      end
    end
  end
  local player = findPlayer()
  
  if player then --player might be dead!
    if goose.position.y > player.position.y + 10 then
      return true
    end
  end
  
  return false
end


Goose.AI.avoids_nearest_skyrock = function(goose, deltaTime, actors)
  
  local function findRock()
    
    local selectedActor = nil
    for key, actor in pairs(actors) do --loop through all the actors
      if actor.meta.isSkyrock and not(actor.meta.isTop) then --find the skyrocks at the bottom
        local dist = (actor.position.x + actor.size.w2) - goose.position.x --calculate x distance - dont forget to add width of the object as well!
        if dist > 0 then --discard any skyrocks behind us
          if selectedActor then 
            -- if we have a rock, select the closest one
            if selectedActor.position.x > actor.position.x then
              selectedActor = actor
            end
          else --if we dont have a rock, select it
            selectedActor = actor
          end
        end 
      end      
    end
    return selectedActor
  end
  local rock = findRock()
  
  if rock then
    local goodDistanceToKeep = 35
    if rock.position.y - rock.size.h2 - goodDistanceToKeep < goose.position.y then
      return true
    end
  end
    
  return false
end


-- local params_example = {
--    scene, 
--    actors = {} --list of all the actors from the given scene
--    ai = Goose.AI.flaps_furiously -- If you dont give it an AI, its gonna fall to its death.
-- }
Goose.AI.controller = function(params)
  
  local fallSpeed = 0   
  local scene = params.scene
  local ai = params.ai or Goose.AI.falls_to_its_death
  local actors = params.actors
    
  return function(actor, deltaTime)   
    fallSpeed = calculateGravity(fallSpeed, deltaTime)    
    
    local wingflap = ai(actor, deltaTime, actors)
    
    if wingflap then
      fallSpeed = Goose.jumpSpeed
      actor.image = Goose.image.up
    else
      actor.image = Goose.image.down
    end
        
    if Goose.screenBoundaryCollision(actor) then
      Goose.event.onDeath(scene, actor)()
      actor.remove = true      
    end
    
    -- Some rotation on the animation
    if fallSpeed > 0 then --going down
      local percentage = fallSpeed / Goose.fallSpeed_max
      actor.rotation = Goose.rotationMax * percentage
    elseif fallSpeed < 0 then
      local percentage = math.abs(fallSpeed) / Goose.fallSpeed_max      
      actor.rotation = -(Goose.rotationMax * percentage)
    end
    
    actor.position.y = actor.position.y + fallSpeed
  end
  
end


--local Example_params = {
--  jumpKey = "space",
--  scene = scene,
--}
Goose.player_controller = function(params)
  local jumpKey = params.jumpKey
  local fallSpeed = 0 
  local can_jump = true 
  local scene = params.scene
  local reset = params.reset or function() end
  
  return function(actor, deltaTime)   
    fallSpeed = calculateGravity(fallSpeed, deltaTime)
    local pressed_jump = love.keyboard.isDown(jumpKey) -- we say we want to jump if we pressed the key
    
    if pressed_jump and can_jump then  -- and if the button was previously released
      fallSpeed = Goose.jumpSpeed
      can_jump = false            
    end
    can_jump = not(love.keyboard.isDown(jumpKey)) -- mark jump as available if the key is up
    
    --Simple animation
    if pressed_jump then
      actor.image = Goose.image.up --Override the current actors image and show the goose up
    else
      actor.image = Goose.image.down --Override the current actors image and show the goose down
    end
    
    if Goose.screenBoundaryCollision(actor) then
      Goose.event.onDeath(scene, actor)()
      actor.remove = true      
    end
    
    -- Some rotation on the animation
    if fallSpeed > 0 then --going down
      local percentage = fallSpeed / Goose.fallSpeed_max
      actor.rotation = Goose.rotationMax * percentage
    elseif fallSpeed < 0 then
      local percentage = math.abs(fallSpeed) / Goose.fallSpeed_max      
      actor.rotation = -(Goose.rotationMax * percentage)
    end
    
    actor.position.y = actor.position.y + fallSpeed
  end
  
end

Goose.screenBoundaryCollision = function(goose) 
   
   --Collision vs bottom
  if goose.position.y + goose.size.h2 > love.graphics.getHeight() then    
    return true    
  end
  
  --Collision vs top
  if goose.position.y < 0 then -- We allow the bird to go a bit above, makes the game a bit easier
    return true
  end
  
  return false
end


return Goose
