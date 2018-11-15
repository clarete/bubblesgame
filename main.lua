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

function drawLifeBar()
  love.graphics.print(
    ("Life: %d"):format(lifeCount),
    ScreenWidth - 50, 15)
end

function spawnHero()
  theHero = BPlayer.create("hero.png", TileSize, TileSize)
  theHero:addToWorld(theWorld)
end

-- Tiles that are not supposed to have colision (water tiles)
NONO = {
  [4]=true,
  [5]=true,
  [8]=true,
}

function drawMap(m)
  for rowIndex, row in ipairs(m.board) do
    for columnIndex, quadIndex in ipairs(row) do
      if quadIndex > 0 then
        local block = m.tileset:drawQuad(quadIndex, columnIndex, rowIndex)
        if not NONO[quadIndex] then
          theWorld:add(block, block.x, block.y, block.w, block.h)
        end
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
  {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0},
  {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0},
  {1, 0, 0, 0, 0, 0, 0, 0, 6, 3, 3, 2, 0, 0, 0, 0, 1, 0, 0, 0},
  {1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 3, 3, 3},
  {1, 3, 1, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1},
  {1, 1, 1, 1, 4, 5, 1, 3, 3, 3, 3, 3, 3, 8, 8, 8, 1, 1, 1, 1}
}

function love.keypressed(k)
  if k == "escape" then
    love.event.quit()
  end

  if k == "r" then
    gameOver = false
    lifeCount = 3
    spawnHero()
  end
end

function love.load()
  love.window.setMode(ScreenWidth, ScreenHeight)
  theWorld = bump.newWorld(TileSize)
  theMap = {
    tileset = BTileSet.create("tileset.png", TileSize, TileSize),
    board = ABoard
  }

  -- Game state
  spawnHero()
  lifeCount = 3
  gameOver = false
end

function love.update(dt)
  if theHero == nil then
    return
  elseif theHero.y + theHero.h > ScreenHeight then
    theHero:die(theWorld)
    theHero = nil

    -- Decrement life and maybe declare game over
    lifeCount = lifeCount - 1
    if lifeCount == 0 then
      gameOver = true
    else
      spawnHero()
    end
  else
    theHero:update(dt, theWorld)
  end
end

function love.draw()
  if gameOver then
    love.graphics.print("YOU SO DEAD :(", ScreenWidth / 2 - 50, ScreenHeight / 2)
    love.graphics.print("Press 'r' to restart", ScreenWidth / 2 - 50, ScreenHeight / 2 + 20)
  else
    drawMap(theMap)
    drawLifeBar()
    theHero:draw()
  end
end
