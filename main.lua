local bump = require 'libs.bump'
local lua = require 'lua'
local BPlayer = require 'player'
local BBGum = require 'bubblegum'

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

function drawGameBar()
  love.graphics.print(
    ("Items: %d, Life: %d"):format(#capturedItems, lifeCount),
    ScreenWidth - 100, 15)
end

QUAD_NAMES = {
  [1]="filling",
  [2]="floor",
  [3]="floor-low",
  [4]="floor-edge-left",
  [5]="floor-edge-right",
  [6]="water-concave-left",
  [7]="water-concave-right",
  [8]="water-full",
  [9]="bubblegum-left",
  [10]="bubblegum-full",
  [11]="bubblegum-left",
}

function readMap(m)
  for rowIndex, row in ipairs(m.board) do
    for columnIndex, quadIndex in ipairs(row) do
      if quadIndex > 0 then
        local block = m.tileset:drawQuad(quadIndex, columnIndex, rowIndex)
        local name = QUAD_NAMES[quadIndex]
        block.name = name
        block.index = quadIndex
        block.isBubblegum = lua.sswith(name, 'bubblegum')
        block.isWater = lua.sswith(name, 'water')
        theWorld:add(block, block.x, block.y, block.w, block.h)
        table.insert(m.blocks, block)
      end
    end
  end
end

function drawMap(m)
  local img = m.tileset.image
  local quads = m.tileset.quads
  for _, block in ipairs(m.blocks) do
    love.graphics.draw(img, quads[block.index], block.x, block.y)
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
  {2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0},
  {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0},
  {1, 0, 0, 0, 0, 0, 0, 0, 4, 2, 2, 5, 0, 0, 0, 0, 1, 0, 0, 0},
  {1, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 2},
  {1, 0, 1, 1, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 0, 0, 1, 1, 1, 1},
  {1, 2, 1, 1, 6, 7, 1, 2, 2, 2, 2, 2, 1, 8, 8, 8, 1, 1, 1, 1}
}

function startGameState()
  lifeCount = 3
  gameOver = false
  local bbx, bby = theWorld:toWorld(2, 14)
  local gum = BBGum.create("bubblegum.png", 24, 24, bbx+4, bby+10)
  gum:spawn(theWorld)
  availableItems = { gum }
  capturedItems = {}
  theHero:spawn(theWorld)
end

function drawItems()
  for _, item in ipairs(availableItems) do
    item:draw()
  end
end

function updateItems(dt, w)
  for i, item in ipairs(availableItems) do
    item:update(dt, w)
    if not theWorld:hasItem(item) then
      table.insert(capturedItems, item)
      availableItems[i] = nil
    end
  end
end

function dropItem()
  if #capturedItems < 1 then return end
  local item = table.remove(capturedItems)
  local padding = 5
  if theHero.direction > 0 then
    item.x = theHero.x + (theHero.w + padding)
  else
    item.x = theHero.x - ((theHero.w * 2) + padding)
  end
  item.y = theHero.y + (theHero.h / 4)
  table.insert(availableItems, item)
  item:spawn(theWorld)
end

function love.keypressed(k)
  if k == "escape" then
    love.event.quit()
  elseif k == "i" then
    dropItem()
  elseif k == "r" and gameOver then
    startGameState()
  end
end

function love.load()
  love.window.setMode(ScreenWidth, ScreenHeight)
  theWorld = bump.newWorld(TileSize)
  theHero = BPlayer.create("hero.png", 12, 32)
  theMap = {
    tileset = BTileSet.create("tileset.png", TileSize, TileSize),
    board = ABoard,
    blocks = {}
  }
  readMap(theMap)
  startGameState()
end

function love.update(dt)
  -- We're done here
  if gameOver then return end

  updateItems(dt, theWorld)

  if theHero:below(ScreenHeight) then
    theHero:die(theWorld)
    lifeCount = lifeCount - 1
    if lifeCount > 0 then
      theHero:spawn(theWorld)
    else
      gameOver = true
    end
  else
    theHero:update(dt, theWorld)
  end
end

function love.draw()
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)

  if gameOver then
    love.graphics.print("YOU SO DEAD :(", ScreenWidth / 2 - 50, ScreenHeight / 2)
    love.graphics.print("Press 'r' to restart", ScreenWidth / 2 - 50, ScreenHeight / 2 + 20)
    love.graphics.print("Or 'Esc' to quit", ScreenWidth / 2 - 50, ScreenHeight / 2 + 40)
  else
    drawMap(theMap)
    drawGameBar()
    drawItems()
    theHero:draw()
  end
end
