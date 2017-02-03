-- Police Turtle Bob 5
-- The Turtle gets a gig
-- Code by Billy art by Scarlet
-- 12/29/2016

-- module includes
Camera = require "hump.camera"
local anim8 = require 'anim8'
local bump = require 'bump'
local sti = require 'sti'
local image, animation

-- Initialize some stuff, window size, bump world, set gravity, load the level and set the collision layer.
love.window.setMode(600, 400)
local world = bump.newWorld(50)
grav = 20 
map = sti("level.lua", { "bump"})
map:bump_init(world)

-- Start the "birdject" here.  This is a class to encapculate bad guys.
npc = {}
npc.__index = npc

function npc.new(x, y, dx, dy, faceRight, jumpAccel, accel, dccel)
  self = setmetatable({}, npc)
  self.x = x
  self.y = y
  self.dx = dx
  self.dy = dy
  self.faceRight = faceRight
  self.jumpAccel = jumpAccel
  self.accel = accel
  self.dccel = dccel
  return self
end

-- Move NPC move while detecting collisions
function npc:move(dt) 
    local cols
    self.x, self.y, cols, cols_len = world:move(self.flyAnim, self.x, self.y + ((self.dy + grav) * dt))
    if cols_len > 0 then self.dy = 0 end
    self.x, self.y, cols, cols_len = world:move(self.flyAnim, self.x + (self.dx*dt), self.y)
end

function npc:init()
  self.image = love.graphics.newImage('bird.png')
  self.g = anim8.newGrid(32, 32, self.image:getWidth(), self.image:getHeight())
  self.flyAnim = anim8.newAnimation(self.g('1-8', 1), .05)
--  world:add(self.runAnim, self.x, self.y, 32, 32)
end

wildBird = npc:new(100, 100, 0, 0, false, 0, 0, 0)
-- Start the "Bobject" here.  This is the encapculation of the player.
bob = {}
bob.x = 0
bob.y = 0
bob.dx = 0
bob.dy = 0
bob.faceRight = false
bob.accel = 60
bob.dccel = 10
bob.jumpAccel = 900
bob.mx = 200

-- Find out of Bob can jump
function bob:canJump()
  local cols
  self.x, self.y, cols, cols_len = world:check(self.runAnim, self.x, self.y+1)  
  if cols_len > 0 then
    self.dy = 0
    return true
  else
    return false
  end
end

-- Move Bob while detecting collisions
function bob:move(dt) 
    local cols
    self.x, self.y, cols, cols_len = world:move(self.runAnim, self.x, self.y + ((self.dy + grav) * dt))
    if cols_len > 0 then self.dy = 0 end
    self.x, self.y, cols, cols_len = world:move(self.runAnim, self.x + (self.dx*dt), self.y)
end

function bob:init()
  self.image = love.graphics.newImage('bob.png')
  self.g = anim8.newGrid(32, 32, self.image:getWidth(), self.image:getHeight())
  self.runAnim = anim8.newAnimation(self.g('1-11', 1), .05)
  world:add(self.runAnim, self.x, self.y, 32, 32)
  camera = Camera(self.x, self.y) 
end


-- Input code
-- todo:  Turn this into a keyboard input pump and move the logic to the bobject
function getCmd()
  if bob:canJump() and love.keyboard.isDown("up") then
    bob.dy = - bob.jumpAccel 
  elseif not bob:canJump() then
    bob.dy = bob.dy + grav
  end

  if love.keyboard.isDown("left") then
    if bob.faceRight then
      bob.runAnim:flipH() 
      bob.faceRight = false
    end
    bob.dx = math.max(bob.dx - bob.accel, - bob.mx)
  elseif love.keyboard.isDown("right") then
    if not bob.faceRight then
      bob.runAnim:flipH()
      bob.faceRight = true
    end
    bob.dx = math.min(bob.dx + bob.accel, bob.mx)
  else
    if bob.dx > 0 then
      bob.dx = bob.dx - bob.dccel
    elseif bob.dx < 0 then
      bob.dx = bob.dx + bob.dccel 
    end
  end
end

-- Obligatory get out of dodge code
function love.keypressed(k)
  if k=="escape" then love.event.quit() end
end

-- These are the love callbacks!!!!!!!!!!!!!!!!!!
function love.load()
  bob:init()
  wildBird:init()
end

function love.update(dt)
  getCmd()
  bob:move(dt)
  camera:lookAt(bob.x, bob.y)
  map:update(dt)
  if bob.dx ~= 0 then
    bob.runAnim:update(dt)
  end
  world:update(bob.runAnim, bob.x, bob.y, 32, 32)
  world:update(wildBird.flyAnim, wildBird.x, wildBird.y, 32, 32)
end

function love.draw()
  camera:attach()
  map:draw()
  bob.runAnim:draw(self.image, bob.x, bob.y)
  wildBird.flyAnim:draw(self.image, wildBird.x, wildBird.y)
  camera:detach()
end
