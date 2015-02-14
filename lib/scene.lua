local WaitThen = require("lib/waitThen")
local scene = {}

scene.new = function(beginCb, updateCb, drawCb, mousereleasedCb, mousepressedCb, stopCb )
  
  local s = {}
  
  s.beginCb = beginCb
  s.updateCb = updateCb
  s.drawCb = drawCb
  s.mousereleasedCb = mousereleasedCb
  s.mousepressedCb = mousepressedCb
  s.stopCb = stopCb
  s.paused = false
  s.childScene = nil
  
  s.buttons = {}
  s.tweens = {}  
  s.waitThens = {}
  s.generics = {}
  
  local displayDebugInformation = false
  local debugInfo = {
    buttons = 0,
    tweens = 0,
    waitThens = 0,
    generics = 0,
  }
  
  s.addTween = function(tween)
    table.insert(s.tweens, tween)
  end
  
  s.addWaitThen = function(waitThen)
    s.waitThens[waitThen] = waitThen
  end
  
  s.addGeneric = function(generic, removeInSeconds)    
    s.generics[generic] = generic    
    if removeInSeconds > 0 then      
      local waitThen = WaitThen.new(removeInSeconds, function() generic.canRemove = true end)
      s.addWaitThen(waitThen)
    end    
  end
  
  s.begin = function()
    s.beginCb()
  end

  s.update = function(deltatime)
    
    if s.paused == false then      
      s.updateCb(deltatime)
      for i = 1, #s.buttons do 
        s.buttons[i].update(deltatime)
      end    
      debugInfo.buttons = #s.buttons
      
      debugInfo.tweens = 0
      for key, value in pairs(s.tweens) do
        debugInfo.tweens = debugInfo.tweens + 1
        if value:update(deltatime) then
          s.tweens[key] = nil
        end
      end
      
      debugInfo.waitThens = 0
      for key, value in pairs(s.waitThens) do
        debugInfo.waitThens = debugInfo.waitThens + 1
        
        value.update(deltatime)
        if value.done then
          s.waitThens[key] = nil
        end
      end
      
      debugInfo.generics = 0
      for key, value in pairs(s.generics) do
        debugInfo.generics = debugInfo.generics + 1
        value.update(deltatime)
        if value.canRemove then
          s.generics[key] = nil
        end
      end      
      
    end
    
    if s.childScene then
      s.childScene.update(deltatime)
    end
    
  end

  s.draw = function()  
    s.drawCb()
    
    for i = 1, #s.buttons do 
      if s.buttons[i] then 
        s.buttons[i].draw()
      end
    end
    
    for i = 1, #s.buttons do 
      if s.buttons[i] then 
        s.buttons[i].drawHover()
      end      
    end
        
    if s.childScene then
      s.childScene.draw()
    end
    
    for key, value in pairs(s.generics) do
      value.draw()      
    end        
    
    if displayDebugInformation and s.childScene == nil then

      love.graphics.setColor(0, 0, 0, 255)
      love.graphics.print("buttons " .. debugInfo.buttons, 0, 0)
      love.graphics.print("tweens " .. debugInfo.tweens, 0, 16)
      love.graphics.print("waitThens " .. debugInfo.waitThens, 0, 32)
      love.graphics.print("generics " .. debugInfo.generics, 0, 48)     
      love.graphics.setColor(255, 255, 255, 255)
      
    end

  end

  s.mousereleased = function(x, y, button)
    if s.paused == false then      
      for i = 1, #s.buttons do 
        if s.buttons[i] then 
          if s.buttons[i].mousereleased(x, y, button) then
            return true
          end
        end
      end
      
      return s.mousereleasedCb(x, y, button)
    end
    
    if s.childScene then
      return s.childScene.mousereleased(x, y, button)
    end
    
    return false
  end

  s.mousepressed = function(x, y, button)
    if s.paused == false then      
      for i = 1, #s.buttons do 
        if s.buttons[i] then 
          if s.buttons[i].mousepressed(x, y, button) then
            return true
          end
        end
      end
      
      return s.mousepressedCb(x, y, button)
    end
    
    if s.childScene then
      return s.childScene.mousepressedCb(x, y, button)
    end
    
    return false
  end

  s.stop = function()
    s.stopCb()
  end

  s.registerButton = function(button)
    s.buttons[#s.buttons + 1] = button
  end
  
  s.pause = function()
    s.paused = true
  end
  
  s.unpause = function()
    s.paused = false
  end
  
  s.addChildScene = function(scene)
    s.pause()
    s.childScene = scene
    s.childScene.begin()
  end
  
  s.removeChildScene = function()
    s.unpause()
    s.childScene.stop()
    s.childScene = nil
  end

  return s
end


return scene
