
local Generic = {}

Generic.new = function(onDraw, onUpdate)
  
  local generic = {}
  generic.canRemove = false
  
  generic.draw = onDraw or function() end
  generic.update = onUpdate or function(deltaTime) end --will get deltatime input
  
  return generic
end

return Generic