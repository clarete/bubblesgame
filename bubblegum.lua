-- Libraries
local anim8 = require 'libs.anim8'
local lua = require 'lua'

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
  bbgum.animation = anim8.newAnimation(grid('1-3', 1), 0.2)
  bbgum.image = image
  bbgum.isItem = true
  return bbgum
end

function BBGum:update(dt, w)
  self.animation:update(dt)
  local _, _, _, len = w:move(self, self.x, self.y)
  if len > 0 then self:capture(w) end
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
