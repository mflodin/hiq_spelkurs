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

Goose.jumpSpeed = -5
Goose.fallSpeed_max = 5
Goose.gravity = 10
Goose.rotationMax = 0.2

Goose.collision = {}
Goose.collision.test = {}
Goose.collision.test.box = function(goose, skyRock)  
  return Collision.boxVsBox(goose.box, skyRock.box)  
end

Goose.animation = {}
Goose.animation.death = function(scene, actor)
  
  return function()
    
    local tweenTime = 2
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
      scale_explo = 8,
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
      scale_explo = 20
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

--local Example_params = {
--  jumpKey = "space",
--  scene = scene,
--}
Goose.controller = function(params)
  local jumpKey = params.jumpKey
  local fallSpeed = 0 
  local can_jump = true 
  local scene = params.scene
  
  local calculateGravity = function(deltaTime) --returns new fallspeed            
    return math.min(fallSpeed + (Goose.gravity * deltaTime), Goose.fallSpeed_max)
  end
 
  return function(actor, deltaTime)   
    fallSpeed = calculateGravity(deltaTime)
    local pressed_jump = love.keyboard.isDown(jumpKey) -- we say we want to jump if we pressed the key
    
    if pressed_jump and can_jump then  -- and if the button was previously released
      fallSpeed = Goose.jumpSpeed
      can_jump = false      
    end
    can_jump = not(love.keyboard.isDown(jumpKey)) -- mark jump as available if the key is up
    
    --If we go at the bottom or top, play the death animation and mark as removable
    if Goose.screenBoundaryCollision(actor) then
      Goose.animation.death(scene, actor)()
      actor.remove = true
    end
    
    --Simple animation
    if pressed_jump then
      actor.image = Goose.image.up --Override the current actors image and show the goose up
    else
      actor.image = Goose.image.down --Override the current actors image and show the goose down
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
  if goose.position.y < 0 then --we allow the bird to go a bit above
    return true
  end
  
  return false
end


return Goose
