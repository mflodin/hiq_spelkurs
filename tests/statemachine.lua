local Statemachine = require("lib/statemachine")

return function()
  
  print("running function")
  
  --Just have them toss the machine around, and state where they are 
  local aCount = 0
  local bCount = 0
  
  local A = function()
    print("A ran, resetted bCount")
       
    aCount = aCount + 1
    
    if aCount < 3 then
      bCount = 0
      return "B"
    end
    
    print("run completed!")
    
    return
  end
  
  
  local B = function()
    print("B ran, added to bCount")
    
    bCount = bCount + 1 
    
    if bCount > 3 then
      return "C"
    end
    
    return
  end
  
  local C = function()
    print("C ran")
    
    if math.random(10) % 2 == 0 then
      print("C went to D!")
      
      return "D"
    end
    
    print("C went to A!")
    
    return "A"  
  end
  
  local D = function()
    print("D ran, went to A!")
    
    return "A"
  end
  
  local s = Statemachine.new()
  s.addState("A", A)
  s.addState("B", B)
  s.addState("C", C)
  s.addState("D", D)
  s.setCurrentState("A")
  
  for i = 1, 20 do
    print(i)
    s.update()
  end
  
end
