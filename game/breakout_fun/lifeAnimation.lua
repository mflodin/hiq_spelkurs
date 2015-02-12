local Imagelib = require("lib/imagelib")
local WaitThen = require("lib/waitThen")
local Tween = require("lib/tween")

-- A system of waitThens and Tweens that animates a ball jumping up and down.
local Lives = {}

--local param_example = {
--  image = "gfx/ball.png",
--  scale = { 2, 2 },
--  position = { x = 100, y = 100 },
--  jumpAtTime = 2,
--  timeOffsetAtStartInSeconds = 0,  
--  jumpHeightInPixels = 50,
--}

Lives.new = function(scene, params)
  
  local life = {}   
  life.image = Imagelib.getImage(params.image)
  life.scale = params.scale
  life.position = { x = params.position.x, y = params.position.y } --notice that we're copying these values from the position parameter
                                                                   --this is so that we can reset the position from the new jump later, 
                                                                   --to avoid collisions with a tween thats finishing
  life.jumpAtTime = params.jumpAtTime
  life.jumpHeightInPixels = params.jumpHeightInPixels
  
  life.jump = function()

    -- Jump up tween
    local upTime = 0.3
    local newPosition = { x = params.position.x, y = params.position.y - life.jumpHeightInPixels }
    local tweenUp = Tween.new(upTime, life.position, newPosition, "inOutQuad")
    scene.addTween(tweenUp)
    
    -- Fall down tween afterwards
    local downTime = 0.5
    local waitThenDown = WaitThen.new(upTime, 
      function() 
        local downPosition = { x = life.position.x, y = life.position.y + life.jumpHeightInPixels }
        local tweenDown = Tween.new(downTime, life.position, downPosition, "outBounce")

        scene.addTween(tweenDown) 
      end
    )
    scene.addWaitThen(waitThenDown)

    -- When we're done, add the next jump. 
    local waitThenJumpAgain = WaitThen.new(upTime + downTime + life.jumpAtTime, life.jump)
    scene.addWaitThen(waitThenJumpAgain)
    
  end  
  
  life.draw = function()
    love.graphics.draw(life.image, life.position.x, life.position.y, 0, life.scale[1], life.scale[2])
  end
  
  local waitThen = WaitThen.new(life.jumpAtTime + params.timeOffsetAtStartInSeconds, life.jump)
  scene.addWaitThen(waitThen)
  
  return life
end
  
return Lives
