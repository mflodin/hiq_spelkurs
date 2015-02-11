local callbackChain = {}

callbackChain.new = function()  
  local chain = {}
  chain.callbacks = {}
  
  chain.setCallbackChain = function(callbacks)
    chain.callbacks = callbacks
  end
  
  chain.begin = function()
    assert(#chain.callbacks > 0, "No chain!")      
  end
    
  chain.next = function()
    table.remove(chain.callbacks, 1)
    
    if #chain.callbacks > 0 then
      chain.begin()
    end
  end
    
  return chain
end

return callbackChain