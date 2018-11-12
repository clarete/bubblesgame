-- Libraries
local anim8 = require 'libs.anim8'

-- Constants
local GRAVITY = 9.8 * 64
local FRICTION = 10

-- The player abstraction
local BPlayer = {}
BPlayer.__index = BPlayer

function BPlayer.create(file, w, h, x, y)
  local image = love.graphics.newImage(file)
  local grid = anim8.newGrid(w, h, image:getWidth(), image:getHeight())
  local player = setmetatable({}, BPlayer)
  -- basic box
  player.x = x or 0
  player.y = y or 0
  player.w = w
  player.h = h
  -- Moviment
  player.xvel = 0
  player.yvel = 0
  player.xmov = false
  player.ymov = false
  player.speed = 1000
  player.direction = 1
  player.jump = 300
  -- Graphics
  player.image = image
  player.animations = {
    idle = anim8.newAnimation(grid('1-1', 1), 0.2),
    idleflip = anim8.newAnimation(grid('1-1', 1), 0.2):flipH(),
    walk = anim8.newAnimation(grid('1-3', 1), 0.15),
    walkflip = anim8.newAnimation(grid('1-3', 1), 0.15):flipH(),
  }
  player.animation = player.animations.idle
  return player
end

function BPlayer:draw()
  self.animation:draw(self.image, self.x, self.y)
end

function BPlayer:physics(dt)
  self.xvel = self.xvel * (1 - math.min(dt * FRICTION, 1))
  self.yvel = self.yvel + GRAVITY * dt
  self.xmov = math.floor(self.xvel) > 30
end

-- Add collision box to player
function BPlayer:addToWorld(w)
  w:add(self, self.x, self.y, self.w, self.h)
end

function anykey(...)
  local keys = {...}
  for i=1, #keys do
    if love.keyboard.isDown(keys[i]) then
      return true
    end
  end
  return false
end

function BPlayer:move(dt, w)
  local cols
  -- Handle Jump Request
  if anykey('w', 'up') then
    -- Only do something if we're not jumping already
    if not self.ymov then
      self.yvel = self.yvel - self.jump
      self.ymov = true
    end
  end
  -- Left and right
  if anykey('d', 'right') then
    self.xvel = self.xvel + self.speed * dt
    self.direction = 1
  elseif anykey('a', 'left') then
    self.xvel = self.xvel + self.speed * dt
    self.direction = -1
  end
  -- Limit speed
  self.xvel = math.min(self.xvel, self.speed)
  -- New x & y Coordinates
  self.x = self.x + self.direction * self.xvel * dt
  self.y = self.y + self.yvel * dt
  -- Apply collision detection
  self.x, self.y, cols = w:move(self, self.x, self.y)
  -- Check for collisions
  for i,v in ipairs(cols) do
    if cols[i].normal.y == -1 then
      self.yvel = 0
      self.ymov = false
    end
    if cols[i].normal.x ~= 0 then
      self.xvel = 0
    end
  end
end

function BPlayer:updateAnimation(dt)
  if self.xmov then
    if self.direction == -1 then
      self.animation = self.animations.walkflip
    else
      self.animation = self.animations.walk
    end
  else
    if self.direction == -1 then
      self.animation = self.animations.idleflip
    else
      self.animation = self.animations.idle
    end
  end
  self.animation:update(dt)
end

function BPlayer:update(dt, w)
  self:physics(dt)
  self:move(dt, w)
  self:updateAnimation(dt)
end
 
return BPlayer