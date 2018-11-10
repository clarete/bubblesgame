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
local BTileSet = {}
BTileSet.__index = BTileSet

-- BTileSet.create Parameters:
-----------------------------:
--- * file: Path to the image
--- * tileWidth:
--- * tileHeight:
function BTileSet.create(file, tileWidth, tileHeight)
  local ts = setmetatable({}, BTileSet)
  ts.file = file
  ts.tileWidth = tileWidth
  ts.tileHeight = tileHeight
  ts.image = love.graphics.newImage(file)
  ts.quads = {}
  local tsWidth, tsHeight = ts.image:getWidth(), ts.image:getHeight()
  local columns, rows = (tsWidth / tileWidth), (tsHeight / tileHeight)
  local quadCount = 1
  for i = 1, rows do
    for j = 1, columns do
      local x, y = (j-1) * tileHeight, (i-1) * tileWidth
      ts.quads[quadCount] = love.graphics.newQuad(
        x, y, tileWidth, tileHeight, tsWidth, tsHeight)
      quadCount = quadCount + 1
    end
  end
  return ts
end

-- BTileSet:drawQuad Parameters:
-------------------------------:
-- * index:
-- * row:
-- * col:
function BTileSet.drawQuad(self, index, r, c)
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
    tileset = BTileSet.create("tileset.png", TileSize, TileSize),
    board = ABoard
  }
end

function love.draw()
  drawMap(TheMap)
end
