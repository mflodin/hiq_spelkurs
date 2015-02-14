
local Imagelib = require("lib/imagelib")

local Parallax = {}

--local example_params = {
--  position_link = actor.position,
--  segments = {
--    { 
--      image = "gfx/wave_red.png",
--      multiplier = { x = 1.1 },  
--      scale = { 4, 4 },
--      y = 200,
--    },
--    {
--      image = "gfx/wave_purple.png",
--      multiplier = { x = 1.4 },    
--      scale = { 4, 4 },
--      y = 260,
--    },
--    {
--      image = "gfx/wave_blue.png",
--      multiplier = { x = 2.0 },    
--      scale = { 4, 4 },
--      y = 320,
--    },
--  }
--}
-- We could still implement a scrolling multiplier along Y axis
-- But, as an example this would do nicely

Parallax.new = function(position, params)
  
  local parallax = {}   
  parallax.segment = {}
  
  --setup segments
  for i = 1, #params.segments do
    local scale = params.segments[i].scale
    local image = Imagelib.getImage(params.segments[i].image)
    local imageWidth = image:getWidth() * scale[1]
    local multiplier = params.segments[i].multiplier
    
    local y = params.segments[i].y

    local draw = function(x)             
      local xFromLeft = (x * multiplier.x)  % imageWidth
      for drawIndex = -imageWidth, love.graphics.getWidth() + imageWidth, imageWidth do        
        love.graphics.draw(image, xFromLeft + (drawIndex -imageWidth), y, 0, scale[1], scale[2])
      end      
    end
    
    parallax.segment[#parallax.segment + 1] = draw
  end
  
  
  parallax.draw = function()    
    
    for i = 1, #parallax.segment do
      parallax.segment[i](position.x)
    end
    
  end
  
  return parallax

end

return Parallax