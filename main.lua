local bump = require 'libs.bump'
local BPlayer = require 'player'

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
  local columns, rows = tsWidth / tileWidth, tsHeight / tileHeight
  for i = 1, rows do
    for j = 1, columns do
      local x, y = (j-1) * tileHeight, (i-1) * tileWidth
      table.insert(ts.quads, love.graphics.newQuad(
                     x, y, tileWidth, tileHeight,
                     tsWidth, tsHeight))
    end
  end
  return ts
end

-- BTileSet:drawQuad Parameters:
-------------------------------:
-- * index:
-- * row:
-- * col:
function BTileSet:drawQuad(index, r, c)
  local x, y = (r-1) * self.tileWidth, (c-1) * self.tileHeight
  love.graphics.draw(self.image, self.quads[index], x, y)
  return {x=x, y=y, w=self.tileWidth, h=self.tileHeight}
end

function drawMap(m)
  for rowIndex, row in ipairs(m.board) do
    for columnIndex, quadIndex in ipairs(row) do
      if quadIndex > 0 then
        local block = m.tileset:drawQuad(quadIndex, columnIndex, rowIndex)
        theWorld:add(block, block.x, block.y, block.w, block.h)
      end
    end
  end
end

ABoard = {
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 3, 3, 2, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 6, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 3},
  {3, 3, 2, 0, 0, 6, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 1, 1},
  {1, 1, 1, 3, 3, 1, 1, 3, 3, 3, 3, 3, 3, 4, 5, 3, 3, 1, 1, 1}
}

function love.keypressed(k)
  if k == "escape" then
    love.event.quit()
  end
end

function love.load()
  love.window.setMode(ScreenWidth, ScreenHeight)
  theWorld = bump.newWorld(TileSize)
  theHero = BPlayer.create("hero.png", TileSize, TileSize)
  theHero:addToWorld(theWorld)
  theMap = {
    tileset = BTileSet.create("tileset.png", TileSize, TileSize),
    board = ABoard
  }
end

function love.update(dt)
  theHero:update(dt, theWorld)
end

function love.draw()
  drawMap(theMap)
  theHero:draw()
end
