local WaitThen = require("lib/WaitThen")
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
      
      for key, value in pairs(s.tweens) do
        if value:update(deltatime) then
          key = nil
          value = nil
        end
      end
      
      for key, value in pairs(s.waitThens) do
        value.update(deltatime)
        if value.done then
          s.waitThens[key] = nil
        end
      end
        
      for key, value in pairs(s.generics) do
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