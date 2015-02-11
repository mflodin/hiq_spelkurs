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

local create_building_info = function(displayParams)
  local scale = displayParams.scale or {2, 2}

  local hover_image = Imagelib.getImage("gfx/gui/hoverTextLarge.png")

  local generatingItems = {}
  for key, value in pairs(displayParams.generates) do
    generatingItems[#generatingItems + 1] = { image = Imagelib.getImage("gfx/gui/"..key..".png"), text = value }
  end

  local costItems = {}
  for key, value in pairs(displayParams.cost) do
    costItems[#costItems + 1] = { image = Imagelib.getImage("gfx/gui/"..key..".png"), text = value }
  end    

  local onRender = function(x, y)
    love.graphics.print(displayParams.textLine1, x + 10, y + 6)
    love.graphics.print(displayParams.textLine2, x + 10, y + 21) 
    love.graphics.print(displayParams.textLine3, x + 10, y + 36) 

    local addX = 0
    for i = 1, #generatingItems do
      love.graphics.draw(generatingItems[i].image, x + 24 + addX, y + 62, 0, scale[1], scale[2])
      love.graphics.print(generatingItems[i].text, x + 44 + addX, y + 63) 
      addX = addX + 40
    end 

    addX = 0
    for i = 1, #costItems do
      love.graphics.draw(costItems[i].image, x + 24 + addX, y + 92, 0, scale[1], scale[2])
      love.graphics.print(costItems[i].text, x + 44 + addX, y + 94) 
      addX = addX + 40
    end       
  end  

  local onUpdate = function(deltaTime)

  end

  return hover_image, onRender, onUpdate
end

local create_building_info_units = function(displayParams)
  
  local scale = displayParams.scale or {2, 2}
  local image = Imagelib.getImage("gfx/gui/hoverTextUnits.png")

  local generatingItems = {}
  for key, value in pairs(displayParams.generates) do
    generatingItems[#generatingItems + 1] = { image = Imagelib.getImage("gfx/gui/"..key..".png"), text = value }
  end

  local costItems = {}
  for key, value in pairs(displayParams.cost) do
    costItems[#costItems + 1] = { image = Imagelib.getImage("gfx/gui/"..key..".png"), text = value }
  end

  local unitItems = {}
  for key, value in pairs(displayParams.units) do
    local unitData = require("cfg/units/"..value)  
    unitItems[#unitItems + 1] = Animation.new(unitData.battle.graphics.walking_down)
  end  

  local onRender = function(x, y)
    love.graphics.print(displayParams.textLine1, x + 10, y + 6)
    love.graphics.print(displayParams.textLine2, x + 10, y + 21) 
    love.graphics.print(displayParams.textLine3, x + 10, y + 36) 

    local addX = 0
    for i = 1, #generatingItems do
      love.graphics.draw(generatingItems[i].image, x + 24 + addX, y + 68, 0, scale[1], scale[2])
      love.graphics.print(generatingItems[i].text, x + 44 + addX, y + 69) 
      addX = addX + 40
    end 
    
    for i = 1, #unitItems do
      unitItems[i].draw(x + 44 + addX, y + 75)
      addX = addX + 34
    end

    addX = 0
    for i = 1, #costItems do
      love.graphics.draw(costItems[i].image, x + 24 + addX, y + 104, 0, scale[1], scale[2])
      love.graphics.print(costItems[i].text, x + 44 + addX, y + 105) 
      addX = addX + 40
    end       
  end

  local onUpdate = function(deltaTime)
    for i = 1, #unitItems do
      unitItems[i].update(deltaTime)
    end
--    print("updating")

  end

  return image, onRender, onUpdate

end

local create_empty_hover = function(hoverType)
  error("Error: Trying to create a hover type that doesnt exist: ".. hoverType)
end

local hover_graphics_factory = function(displayParams)

  local displayTypes = {
    textrow = create_hover_text,
    building_info = create_building_info,
    building_info_units = create_building_info_units,
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
