local function handleInput()
end

function states.gameEnd:enter()
end

function states.gameEnd:draw()
  local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()

  love.graphics.printf('Paraboins,\nvc resolveu o puzzle!', 0, height / 2, width, 'center')
end

function states.gameEnd:update()
end