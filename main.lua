local Class = require 'hump.class'

-- Globals:
----------:
ScreenWidth = 640
ScreenHeight = 480
TileSize = 32

-- BTileSet Fields:
------------------:
--  * file: Path that points to the png file
--  * tileWidth:
--  * tileHeight:
--  * image:
--  * quads:
local BTileSet = Class{}

-- BTileSet.create Parameters:
-----------------------------:
--- * file: Path to the image
--- * tileWidth:
--- * tileHeight:
function BTileSet:init(file, tileWidth, tileHeight)
  self.file = file
  self.tileWidth = tileWidth
  self.tileHeight = tileHeight
  self.image = love.graphics.newImage(file)
  self.quads = {}
  local selfWidth, selfHeight = self.image:getWidth(), self.image:getHeight()
  local columns, rows = (selfWidth / tileWidth), (selfHeight / tileHeight)
  local quadCount = 1
  for i = 1, rows do
    for j = 1, columns do
      local x, y = (j-1) * tileHeight, (i-1) * tileWidth
      self.quads[quadCount] = love.graphics.newQuad(
        x, y, tileWidth, tileHeight, selfWidth, selfHeight)
      quadCount = quadCount + 1
    end
  end
end

-- BTileSet:drawQuad Parameters:
-------------------------------:
-- * index:
-- * row:
-- * col:
function BTileSet:drawQuad(index, r, c)
  local x, y = (r-1) * self.tileWidth, (c-1) * self.tileHeight
  love.graphics.draw(self.image, self.quads[index], x, y)
end

function drawMap(m)
  for rowIndex, row in ipairs(m.board) do
    for columnIndex, quadIndex in ipairs(row) do
      m.tileset:drawQuad(quadIndex, columnIndex, rowIndex)
    end
  end
end

ABoard = {
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 1, 1, 1, 1, 1, 1},
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1},
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
  {1, 1, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2},
  {2, 2, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2},
  {2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 2, 2, 2, 2, 2, 1}
}

function love.load()
  love.window.setMode(ScreenWidth, ScreenHeight)
  TheMap = {
    tileset = BTileSet("bubbles1.png", TileSize, TileSize),
    board = ABoard
  }
end

function love.draw()
  drawMap(TheMap)
end
