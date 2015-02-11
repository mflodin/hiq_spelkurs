local tweenChain = {}

tweenChain.new = function(tweenList)
  
  local chain = {}
  
  chain.update = function(chain, deltaTime)
    
    if tweenList[1]:update(deltaTime) then
      table.remove(tweenList, 1)
    end
    
    return #tweenList == 0
  end
  
  return chain
end

return tweenChain