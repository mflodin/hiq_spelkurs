local Statemachine = {}

Statemachine.new = function()
  
  local stateMachine = {}
  stateMachine.states = {}
  stateMachine.currentState = nil
  
  -- If a state is completed and wants to switch state, it needs to return the key of the new state  
  --  function example_stateA()
  --    return "example_stateB"
  --  end
  
  stateMachine.addState = function(key, callback) 
    stateMachine.states[key] = callback
  end
  
  stateMachine.setCurrentState = function(key)    
    
    if stateMachine.states[key] then
      stateMachine.currentState = key
    else
      stateMachine.currentState = nil -- Set current state to nil if it doesnt exist, because:
                                      -- We dont want the statemachine to keep running a state if we tried to switch, even if it doesnt exist
                                      -- It's easier to debug this way later if something goes wrong
    end
    
    -- We don't want to update the statemachine immediatly after setting a new state; 
    -- as it may cause an infinite loop if we're sloppy. (What if A links to B and then links to A?)
    -- Instead we're going to manually decide if we do that after the use of setCurrentState.    
  end
  
  stateMachine.update = function()
    
    if stateMachine.states[stateMachine.currentState] then
      local newState = stateMachine.states[stateMachine.currentState]()
      
      if newState then
        stateMachine.currentState = newState
      end
    end
  end
  
  return stateMachine;
  
end

return Statemachine