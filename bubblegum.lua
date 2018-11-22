-- Libraries
local anim8 = require 'libs.anim8'
local lua = require 'lua'
local constants = require 'constants'

-- The bubblegum abstraction
local BBGum = {}
BBGum.__index = BBGum

function BBGum.create(file, w, h, x, y)
  local image = love.graphics.newImage(file)
  local grid = anim8.newGrid(w, h, image:getWidth(), image:getHeight())
  local bbgum = setmetatable({}, BBGum)
  -- basic box
  bbgum.x = x or 0
  bbgum.y = y or 0
  bbgum.w = w
  bbgum.h = h
  -- movement
  bbgum.yvel = 0
  bbgum.ymov = false
  bbgum.speed = 1000
  -- graphics
  bbgum.animation = anim8.newAnimation(grid('1-3', 1), 0.2)
  bbgum.image = image
  bbgum.isItem = true
  return bbgum
end

function BBGum:physics(dt)
  self.yvel = self.yvel + GRAVITY * dt
end

function BBGum:move(dt)
  self.y = self.y + self.yvel * dt
end

function BBGum:update(dt, w)
  self:physics(dt)
  self:move(dt)
  self.animation:update(dt)
  self.x, self.y, cols, len = w:move(self, self.x, self.y)
  for i, v in ipairs(cols) do
    if v.other.isPlayer then
      self:capture(w)
      break
    end
    if v.normal.y == -1 then
      self.yvel = 0
      self.ymov = false
    end
  end
end

function BBGum:draw()
  self.animation:draw(self.image, self.x, self.y)
end

function BBGum:spawn(w)
  w:add(self, self.x, self.y, self.w, self.h)
end

function BBGum:capture(w)
  w:remove(self)
end

return BBGum
