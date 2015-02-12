local Hover_graphics = require("lib/hover_graphics")
local Tween = require("lib/tween")
local Imagelib = require("lib/imagelib")
--local gameSettings = require("cfg/gameSettings")
local Animation = require("lib/animation")


local hover = {}

-- Displayparams!
--{ --textrow
--  offset = {16, 16},
--  type = "textrow",
--  text = "hej babberiba",
--  scale = {2, 2}
--}
--{ --hoverinfo for buildings
--  offset = {16, 16},
--  type = "building_info",
--  textLine1 = "Fisherman (small)",
--  textLine2 = "Generates food.",
--  textLine3 = "Smells fishy.",
--  generates = {
--    food = 5,
--  },
--  cost = {
--    wood = 20,
--    recruits = 5,
--  },
--  scale = {2, 2}
--}

local secondsUntilDisplay = 0.5--gameSettings.hoverWindow.secondsUntilDisplay
local openingTime = 1--gameSettings.hoverWindow.openingTime

hover.new = function(displayParams)
  local hvr = {}  
  local scale = displayParams.scale or {2, 2}
  local image 
  
  image, hvr.onRender, hvr.extraUpdate = Hover_graphics(displayParams)

  local offset = displayParams.offset or {16, 16}
  local displayCounter = 0  
  local canDisplay = false
  local rgba = { 0, 0, 0, 0 }
  local tween = nil
  local currentDisplay = nil

  local display = function()
    local x, y = love.mouse.getPosition()    
    x = x + offset[1]
    y = y + offset[2]
    local screenFixX, screenFixY = 0, 0
    local testY = y + offset[2] + (image:getHeight() * scale[2])
    if testY > love.graphics.getHeight() then
      y = love.graphics.getHeight() - (image:getHeight() * scale[2])
    end

    love.graphics.setColor(rgba[1], rgba[2], rgba[3], rgba[4])
    love.graphics.draw(image, x, y, 0, 2, 2)
    hvr.onRender(x, y)

    love.graphics.setColor(255, 255, 255, 255)    
  end

  local noDisplay = function() end  
  currentDisplay = noDisplay

  hvr.draw = function()
    currentDisplay()
  end

  hvr.mouseIsOn = function(deltaTime)
    displayCounter = displayCounter + deltaTime 
    if displayCounter > secondsUntilDisplay then
      currentDisplay = display
      tween = Tween.new(openingTime, rgba, {255, 255, 255, 255}, "linear")
--      hvr.update(deltaTime)
    end
  end

  hvr.mouseIsOff = function(deltaTime)
    displayCounter = 0
    tween = Tween.new(openingTime, rgba, {0, 0, 0, 0}, "linear")
  end

  hvr.update = function(deltaTime)
    if tween then
      if tween:update(deltaTime) then
        tween = nil
        currentDisplay = noDisplay
      end
    end
    
    if hvr.extraUpdate then
--      print(hvr.extraUpdate)
      hvr.extraUpdate(deltaTime)
    end
  end

  return hvr
end

return hover

