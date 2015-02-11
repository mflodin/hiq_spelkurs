
-- number_string
-- String input example = 3413
-- returns { 3, 4, 1, 3 },
-- Discards non numbers
-- 
-- min_stringLength - optional
-- min_stringLength adds 0's to the front of the list if the resulting list is shorter than the value of min_stringLength
-- example, function(23419, 8) would return { 0, 0, 0, 2, 3, 4, 1, 9 }

return function(number_string, min_stringLength)
  min_stringLength = min_stringLength or string.len(number_string)
  local list = {}
  
  --make list
  number_string:gsub(".", function(c)    
    local n = tonumber(c)
    if n then 
      table.insert(list, n)
    end
  end)

  --add 0's
  if #list < min_stringLength then
    for i = 1, (min_stringLength - #list) do
      table.insert(list, 1, 0)
    end
  end
  
  return list
end