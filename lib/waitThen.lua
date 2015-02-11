local waitThen = {}

--waits around then runs the callback

waitThen.new = function(time, callback)
  
  local waiter = {}
  waiter.timeSinceStart = 0
  waiter.timeUntil = time
  waiter.done = false
  
  waiter.update = function(deltaTime)
    waiter.timeSinceStart = waiter.timeSinceStart + deltaTime    
    if waiter.timeSinceStart >= waiter.timeUntil then
      waiter.callback()
      waiter.done = true
    end    
  end
  
  waiter.callback = callback
  
  return waiter  
end

return waitThen