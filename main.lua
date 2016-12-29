Camera = require "hump.camera"
local anim8 = require 'anim8'
local bump = require 'bump'
local sti = require 'sti'
local image, animation

love.window.setMode(600, 400)
local world = bump.newWorld(50)
x = 0 
y = 0
dx = 0
dy = 0
faceRight = false
accel = 60
dccel = 10
jumpAccel = 900
grav = 20 
mx = 200 

function canJump()
  local cols
  x, y, cols, cols_len = world:check(animation, x, y+1)  
  if cols_len > 0 then
    dy = 0
    return true
  else
    return false
  end
end

function getCmd()
  if canJump() and love.keyboard.isDown("up") then
    dy = - jumpAccel 
  elseif not canJump() then
    dy = dy + grav
  end

  if love.keyboard.isDown("left") then
    if faceRight then
      animation:flipH() 
      faceRight = false
    end
    dx = math.max(dx - accel, - mx)
  elseif love.keyboard.isDown("right") then
    if not faceRight then
      animation:flipH()
      faceRight = true
    end
    dx = math.min(dx + accel, mx)
  else
    if dx > 0 then
      dx = dx - dccel
    elseif dx < 0 then
      dx = dx + dccel 
    end
  end
end

function moveBird(dt) 
    local cols
    x, y, cols, cols_len = world:move(animation, x, y + ((dy + grav) * dt))
    if cols_len > 0 then dy = 0 end
    x, y, cols, cols_len = world:move(animation, x + (dx*dt), y)
end

function love.keypressed(k)
  if k=="escape" then love.event.quit() end
end

function leftRight()
  if dx > 0 then
  elseif dx < 0 then
  end
end
    
map = sti("level.lua", { "bump"})
map:bump_init(world)

function love.load()
  camera = Camera(x, y)
  image = love.graphics.newImage('bob.png')
  local g = anim8.newGrid(32, 32, image:getWidth(), image:getHeight())
  animation = anim8.newAnimation(g('1-11', 1), .05)
  world:add(animation, x, y, 32, 32)
end

function love.update(dt)
  getCmd()
  moveBird(dt)
  camera:lookAt(x, y)
  map:update(dt)
  if dx ~= 0 then
    animation:update(dt)
  end
  world:update(animation, x, y, 32, 32)
end

function love.draw()
  camera:attach()
  map:draw()
  animation:draw(image, x, y)
  camera:detach()
end
