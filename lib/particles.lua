-- Use the real particle engine included in love2d!
--
-- Dont use this. Really, don't. This is an abomation and it shouldn't exist or be used ever. 
-- It's literally the code from the abyss and you dont want to stare at it because it'll look back and you'll be stuck in recursive hell. But with particles.
-- It's super slow because it uses tweens. 

local Tween = require("lib/tween")
local ImageLib = require("lib/imagelib")

local particlesHolder = {}

particlesHolder.standard_move = function(params, startTimePercentage) 
--  local paramsEx = {
--    tweenType = "linear",
--    image = "gfx/gui/mana.png",
--    from_position = { x = 0, y = 0 }, --relative to particle position
--    within_area = { width = 100, height = 100 }, --centered on mid
--    travelsDistance = { --need to have this per axis instead
--        x = { min = 100, max = 200 }, 
--        y = { min = 100, max = 200 }, 
--    },
--    rgba_from = { 255, 255, 255, 255 },
--    rgba_to = { 255, 255, 255, 255 },
--    overTimeInSeconds = 3,
--    rotation_from = 0,
--    rotation_to = 0,
--    scale_from = 1,
--    scale_to = 4,
--  }

  startTimePercentage = startTimePercentage or 0
  
  --creates a particle
  local particle = {
    image = ImageLib.getImage(params.image),
    x = params.from_position.x + math.random(params.within_area.width) - (params.within_area.width / 2),
    y = params.from_position.y + math.random(params.within_area.height) - (params.within_area.height / 2),
    rgba = { params.rgba_from[1], params.rgba_from[2], params.rgba_from[3], params.rgba_from[4] },
    r = params.rotation_from,
    s = params.scale_from,
  }
  
  local particleTo = {
    x = particle.x - ((particle.image:getWidth() * params.scale_to) / 2) 
        + math.random(params.travelsDistance.x.min) + (params.travelsDistance.x.max - params.travelsDistance.x.min), 
    y = particle.y - ((particle.image:getHeight() * params.scale_to) / 2)
        + math.random(params.travelsDistance.y.min) + (params.travelsDistance.y.max - params.travelsDistance.y.min), 
    rgba = { params.rgba_to[1], params.rgba_to[2], params.rgba_to[3], params.rgba_to[4] },
    r = params.rotation_to,
    s = params.scale_to,
  }  

  particle.tween = Tween.new(params.overTimeInSeconds, particle, particleTo, params.tweenType)
  
  particle.draw = function(offsetX, offsetY)
    love.graphics.setColor(particle.rgba)
    love.graphics.draw(particle.image, particle.x + offsetX, particle.y + offsetY, particle.r, particle.s, particle.s)
  end
  
  return particle
end

--local confParamsExample = {
--  position = { x = 500, y = 500 },
--  lifeLengthSeconds = 10, --0 for forever
--  spawnRatePerSecond = 3,
--  particleGenerator = {
--    generator = particlesHolder.standard_move,
--    params = {
--      --this is specific to the particle thing itself
--    }
--  }
--}
particlesHolder.new = function(params)
  
  local particleData = {}
  particleData.canRemove = false
  particleData.particles = {}
  particleData.time = 0
  particleData.particlesSpawnerTime = 0
  particleData.particlesSpawnTimeInterval = ( 1 / params.spawnRatePerSecond )   
  
  local loop = 0
  particleData.update = function(deltaTime)
    particleData.time = particleData.time + deltaTime    
    
    for i = #particleData.particles, 1, -1 do
      if particleData.particles[i].tween:update(deltaTime) then
        table.remove(particleData.particles, i) 
      end
    end
    
    particleData.particlesSpawnerTime = particleData.particlesSpawnerTime + deltaTime    
    if particleData.timeIsUp() == false then
      local whiles = 0
      while particleData.particlesSpawnerTime > particleData.particlesSpawnTimeInterval do        
        particleData.particlesSpawnerTime = particleData.particlesSpawnerTime - particleData.particlesSpawnTimeInterval
        table.insert(particleData.particles, params.particleGenerator.generator(params.particleGenerator.params, 0))              
        whiles = whiles + 1
      end
      
    end
    
    loop = loop + 1
    
  end
  
  particleData.draw = function(offsetX, offsetY)
    for i = 1, #particleData.particles do
      particleData.particles[i].draw(params.position.x + offsetX, params.position.y + offsetY)
    end
    
    love.graphics.setColor(255, 255, 255, 255)
  end
  
  particleData.timeIsUp = function()
    if params.lifeLengthSeconds == 0 then
      return false
    else 
      return params.lifeLengthSeconds < particleData.time 
    end      
  end
  
  particleData.canRemove = function()
    if particleData.timeIsUp() == true then
      return #particleData.particles == 0
    end
  end
  
  particleData.stop = function()
    if params.lifeLengthSeconds == 0 then 
      params.lifeLengthSeconds = 1
    end
     
    particleData.time = params.lifeLengthSeconds
  end
  
  return particleData
end

return particlesHolder
