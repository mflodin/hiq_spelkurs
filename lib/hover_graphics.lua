local Imagelib = require("lib/Imagelib")
local Animation = require("lib/animation")

local create_hover_text = function(displayParams)
  local scale = displayParams.scale or {2, 2}
  local hover_image = Imagelib.getImage("gfx/gui/hovertext.png")
  local onRender = function(x, y)
    love.graphics.print(displayParams.text, x + 10, y + 10)
  end

  local onUpdate = function(deltaTime)

  end

  return hover_image, onRender, onUpdate
end

local create_empty_hover = function(hoverType)
  error("Error: Trying to create a hover type that doesnt exist: ".. hoverType)
end

local hover_graphics_factory = function(displayParams)

  local displayTypes = {
    textrow = create_hover_text,
    empty = create_empty_hover,
  }

  local hover_image, onRender, onUpdate
  if displayTypes[displayParams.type] then
    hover_image, onRender, onUpdate = displayTypes[displayParams.type](displayParams)
  else
    hover_image, onRender, onUpdate = create_empty_hover(displayParams.type)
  end

  return hover_image, onRender, onUpdate

end

return hover_graphics_factory
