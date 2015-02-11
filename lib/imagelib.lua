local ImageLib = {}

ImageLib.images = {}

ImageLib.getImage = function(imagePath)
  if ImageLib.images[imagePath] == nil then
    ImageLib.images[imagePath] = love.graphics.newImage(imagePath)
    ImageLib.images[imagePath]:setFilter("nearest", "nearest")
  end

  return ImageLib.images[imagePath]
end

return ImageLib