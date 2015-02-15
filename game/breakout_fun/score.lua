local numberToList = require("lib/numberToList")
local Generic = require("lib/generic")
local Quad = require("lib/quad")

local Score = {}

--local params_example = {
--  start_score = 0,
--  numbers_max = 5,
--  color = { 255, 0, 0, 255 },
--  position = { x = 200, y = 450 },
--  numbersQuad = {
--    image = "gfx/numbers_inv.png",
--    rows = 10, 
--    columns = 1, 
--    scale = {30, 30},
--  },  
--}

Score.new = function(params)
  
  local score = {}
  score.score = params.start_score  
  score.numbers = params.numbers_max
  score.values = {} -- will contain the numbers in an indexed list, if score is 1500 then this = { 0, 0, 0, 0, 1, 5, 0, 0 }. Determined by score.numbers
  score.color = params.color
  score.position = params.position
  score.numberGfx = {}
  
  -- setup numbers for rendering
--  local quadParams = { image = "gfx/numbers_inv.png", rows = 10, columns = params.numbersQuad.columns, scale = params.numbersQuad.scale }
  local quad = Quad.new(params.numbersQuad)  
  for i = 0, 9 do
    table.insert(score.numberGfx, quad.getRenderable(i, 0))
  end

  score.addPoint = function()
    score.score = score.score - score.score % 10
    score.score = score.score + math.random(2,9)
    score.update()
  end

  score.addArrow = function()
    local lastDigit = score.score % 10
    if (score.score > 10) -- ensure we don't get an arrow at the front
      then
        score.score = (score.score - lastDigit + 1) -- replace last digit with 1 (arrow)
    end
    score.score = score.score * 10 -- shift left
    score.score = score.score + lastDigit -- reattach last digit
    score.update()
  end
  
  score.remove = function(points)
    score.score = score.score - points
    score.update()
  end
  
  score.update = function()
    -- Concatenate number to string and convert it to array. Unclean and inefficient. Refactor.
    score.values = numberToList("" .. score.score, score.numbers)
  end
  
  score.draw = function()
    love.graphics.setColor(score.color)

    local xDist = (params.numbersQuad.size[1] or 4) * params.numbersQuad.scale[1]
    for i = 1, #score.values do
      local numIndex = score.values[i] + 1
      local extraLetterDistance = (xDist * (i - 1))
      score.numberGfx[numIndex].draw(score.position.x + extraLetterDistance, score.position.y)
    end
    love.graphics.setColor(255, 255, 255, 255)
  end
  
  score.getGeneric = function()
    return Generic.new(score.draw, score.update)
  end
  
  --Set score display
  score.update()

  return score  
end

return Score