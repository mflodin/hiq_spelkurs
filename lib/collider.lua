
local Collider = {}

Collider.new = function(mainObject, main_onCollision)
  local collider = {}
  
  collider.mainObject = mainObject
  collider.onMainCollision = main_onCollision 
  collider.objects = {}  
  
  collider.addObject = function(object, object_onCollisionCb, colliderCb)    
    collider.objects[object] = { object = object, onCollision = object_onCollisionCb, collider = colliderCb }
  end
  
  collider.removeObject = function(object)
    collider.objects[object] = nil    
  end
  
  collider.update = function(deltaTime)
    for key, obj in pairs(collider.objects) do            
      if obj.collider(mainObject, obj.object) then
        collider.onMainCollision(collider.mainObject, obj.object)
        obj.onCollision(obj.object, collider.mainObject)
        
        return -- This makes it an incorrect collision behaviour (what if we collided with two objects this frame?) 
               -- but it makes it fast. Fortunately, thats good enough for us right now! :)
      end
    end
  end
  
  collider.getLiving = function()
    local living = 0
    --Here's the problems with having a list indexed the way we do - we cant get the length smoothly
    for key, obj in pairs(collider.objects) do            
      living = living + 1
    end
    
    return living
  end
  
  return collider
end

return Collider