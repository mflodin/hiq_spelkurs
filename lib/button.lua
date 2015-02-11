local Collision = require("lib/collision")
local Imagelib = require("lib/ImageLib")
local Tween = require("lib/Tween")
local Hover = require("lib/Hover")

local button = {}

button.newButton = function(x, y, buttonImgUp, buttonImgDown, buttonCallbackLeft, buttonCallbackRight, buttonScale, hoverParams)

  local scale = buttonScale or {2, 2}

  local btn = {}

  btn.x = x
  btn.y = y
  btn.scaleX = scale[1]
  btn.scaleY = scale[2]
  btn.callbackLeft = buttonCallbackLeft
  btn.callbackRight = buttonCallbackRight
  btn.color = {255, 255, 255, 255}
  btn.imgUp = Imagelib.getImage(buttonImgUp)
  btn.imgDown = Imagelib.getImage(buttonImgDown)

  btn.img = btn.imgUp  

  btn.mouseIsDown = false
  btn.drawHover = function() end
  if hoverParams then
    btn.hover = Hover.new(hoverParams)
    btn.drawHover = btn.hover.draw  
  end
  
  btn.draw = function()  
    love.graphics.setColor(btn.color[1], btn.color[2], btn.color[3], btn.color[4])
    love.graphics.draw(btn.img, btn.x, btn.y, 0, btn.scaleX, btn.scaleY)          
  end
  
  btn.drawScrollable = function(x, y)  
    love.graphics.setColor(btn.color[1], btn.color[2], btn.color[3], btn.color[4])
    love.graphics.draw(btn.img, btn.x + x, btn.y + y, 0, btn.scaleX, btn.scaleY)          
  end

  btn.mousereleased = function(x, y, button)
    btn.mouseIsDown = false
    btn.img = btn.imgUp

    if Collision.pointInBox(x, y, {btn.x, btn.y, btn.img:getWidth() * btn.scaleX, btn.img:getHeight() * btn.scaleY}) then
      if btn.callbackLeft and button == "l" then
        btn.callbackLeft()
      elseif btn.callbackRight and button == "r" then
        btn.callbackRight()
      end
      return true
    end
    return false
  end

  btn.mousepressed = function(x, y, button)
    if Collision.pointInBox(x, y, {btn.x, btn.y, btn.img:getWidth() * btn.scaleX, btn.img:getHeight() * btn.scaleY}) then
      btn.mouseIsDown = true
      btn.img = btn.imgDown      
      return true
    else 
      btn.mouseIsDown = false
      btn.img = btn.imgUp
      return false
    end    
    
    
  end

  btn.update = function(deltaTime)
    local x, y = love.mouse.getPosition()

    if btn.hover then
      if Collision.pointInBox(x, y, {btn.x, btn.y, btn.img:getWidth() * btn.scaleX, btn.img:getHeight() * btn.scaleY}) then
        btn.hover.mouseIsOn(deltaTime)
      else
        btn.hover.mouseIsOff(deltaTime)
      end

      btn.hover.update(deltaTime)      
    end
  end

  return btn
end

return button