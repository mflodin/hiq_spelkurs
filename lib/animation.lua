local Imagelib = require("Lib/Imagelib")

local animation = {}

--Example input:
--local testAnimation = {
--  position = { x = 500, y = 100 },  --optional, default: {0, 0}
--  images = {1, 2, 3, 4}, 
--  offset = {{x, y}, {x, y}},        --optional, default: {0, 0} 
--  time = {100, 200, 100, 100}, 
--  type = "loop" / "once", 
--  scale = {x, y}                    --optional, default: {2, 2}
--  rotation = { 0, 90, 180, 270 },   --optional, default: 0, in degrees
--  maybe play a little sound? :)
--}

animation.TYPES = {}
animation.TYPES.ONCE = "once"
animation.TYPES.LOOP = "loop"

animation.new = function(settings)
  local ani = {}
  local time = 0
  local frame = 1  
  local tween = nil

  ani.completed = false
  ani.type = settings.type
  
  if settings.position == nil then
    settings.position = { x = 0, y = 0 }
  end
  ani.x = settings.position.x or 0
  ani.y = settings.position.y or 0
  ani.scale = settings.scale
  
  --Load images from settings
  ani.images = {}
  for i = 1, #settings.images do
    ani.images[#ani.images + 1] = Imagelib.getImage(settings.images[i])
  end

  --Streamline offsets
  if settings.offset == nil then
    settings.offset = {}
    for i = 1, #settings.images do
      settings.offset[#settings.offset + 1] = {0, 0}
    end
  end
  
  --Set scale
  if ani.scale == nil then
    ani.scale = {2, 2}
  end
  
  --Set rotation
  if settings.rotation == nil then
    settings.rotation = {}
    for i = 1, #settings.images do
      settings.rotation[#settings.rotation + 1] = 0
    end    
  else --convert to radians from degrees
    for i = 1, #settings.rotation do
      settings.rotation[i] = (math.pi * settings.rotation[i]) / 180
    end
  end
  
  ani.draw = function(x, y)
    local imgwidth, imgheight = ani.images[frame]:getWidth(), ani.images[frame]:getHeight()
    local scale = settings.scale

    
    love.graphics.draw(ani.images[frame], ani.x + x + settings.offset[frame][1], ani.y + y + settings.offset[frame][2], 
      settings.rotation[frame], ani.scale[1], ani.scale[2], imgwidth / 2, imgheight / 2)    
  end
  
  ani.addTween = function(newTween)
    tween = newTween
  end
  
  ani.update = function(deltaTime)
    time = time + deltaTime
    
    if time > settings.time[frame] then
      time = time - settings.time[frame]
      frame = frame + 1
      if frame > #settings.time then
        
        if settings.type == animation.TYPES.LOOP then 
          frame = 1 
        end
        
        if settings.type == animation.TYPES.ONCE then 
          frame = #settings.time 
          ani.completed = true
        end
      end
    end
    
    if tween then
      if tween:update(deltaTime) then
        tween = nil
      end
    end
    
    return (ani.completed and tween == nil)
  end
  
  ani.reset = function()
    ani.completed = false
    time = 0
    frame = 1
  end

  return ani
end

return animation