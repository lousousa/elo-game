require 'src/ui/slots-thumbnails'
require 'src/ui/dialog'

require 'src/controllers/player'
require 'src/controllers/checkpoint'
require 'src/controllers/ally'

local function handleInput()
  if Input:down 'up' then
    playerController:move{ x = 0, y = -1 }
    playerController.animation = playerController.animations.walking.up
  end

  if Input:down 'right' then
    playerController:move{ x = 1, y = 0 }
    playerController.animation = playerController.animations.walking.right
  end

  if Input:down 'left' then
    playerController:move{ x = -1, y = 0 }
    playerController.animation = playerController.animations.walking.left
  end

  if Input:down 'down' then
    playerController:move{ x = 0, y = 1 }
    playerController.animation = playerController.animations.walking.down
  end
end

function states.gameLevel:enter()
  world = WF.newWorld()
  camera = Camera()
  map = STI('assets/maps/predio.lua')

  opacity = 0

  world:addCollisionClass('Player')
  world:addCollisionClass('Checkpoint')
  world:addCollisionClass('Ally')
  world:addCollisionClass('Trigger-Gate')

  slotsThumbnails = SlotsThumbnails:new{}
  dialog = Dialog:new{}

  playerObj = map.layers['player'].objects[1]

  if GAME_IS_READY == false then
    PLAYER_SPAWN_POSITION.x = playerObj.x
    PLAYER_SPAWN_POSITION.y = playerObj.y
  end

  playerController = PlayerController:new{}

  checkpointObj = map.layers['checkpoint'].objects[1]
  checkpointController = CheckpointController:new{
    position = {
      x = checkpointObj.x,
      y = checkpointObj.y
    }
  }

  CHECKPOINT_POSITION.x = checkpointObj.x
  CHECKPOINT_POSITION.y = checkpointObj.y

  local triggerGate = map.layers['trigger-portao'].objects[1]
  local triggerGateCollider = world:newRectangleCollider(triggerGate.x, triggerGate.y, triggerGate.width, triggerGate.height)
  triggerGateCollider:setType('static')
  triggerGateCollider:setCollisionClass('Trigger-Gate')

  slotsByAlly = {
    { 'S', 'I' },
    { 'O', 'N', 'V' },
    { 'E', 'I', 'V' },
    { 'E', 'N' },
    { 'G', 'U', 'M' }
  }

  allyControllers = {}

  if map.layers['allies'] then
    for i, obj in pairs(map.layers['allies'].objects) do
      local ally = AllyController:new{ idx = i, position = { x = obj.x, y = obj.y }, slots = slotsByAlly[i] }
      table.insert(allyControllers, ally)
    end
  end

  GAME_IS_READY = true

  mapW = map.width * map.tilewidth
  mapH = map.height * map.tileheight

  local boundaries = {
    world:newRectangleCollider(0, -2, mapW, 1),
    world:newRectangleCollider(mapW + 1, 0, 1, mapH),
    world:newRectangleCollider(0, mapH + 1, mapW, 1),
    world:newRectangleCollider(-2, 0, 1, mapH)
  }

  for _, boundary in ipairs(boundaries) do
    boundary:setType('static')
  end

  if map.layers['blocks'] then
    for _, obj in pairs(map.layers['blocks'].objects) do
      local block = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
      block:setType('static')
    end
  end

  musicManager:stopAll()
  musicManager.list.mainTheme:play()
  musicManager.list.mainTheme:setLooping(true)
end

function states.gameLevel:draw()
  love.graphics.setColor(1, 1, 1, opacity)

  camera:attach()
    map:drawLayer(map.layers['layer1'])
    map:drawLayer(map.layers['layer2'])
    map:drawLayer(map.layers['layer3'])
    map:drawLayer(map.layers['layer4'])
    checkpointController:draw()

    for _, controller in ipairs(allyControllers) do
      controller:draw()
    end

    playerController:draw()
    dialog:draw()

    -- world:draw()
  camera:detach()

  slotsThumbnails:draw()
end

function states.gameLevel:update(dt)
  if opacity < 1 then
    opacity = opacity + .01
  end

  handleInput()

  checkpointController:update()
  dialog:update(dt)

  for _, controller in ipairs(allyControllers) do
    controller:update()
  end

  playerController.position.x = playerController.collider:getX()
  playerController.position.y = playerController.collider:getY() - playerController.height / 4
  camera:lookAt(playerController.position.x, playerController.position.y)

  local w = love.graphics.getWidth()
  local h = love.graphics.getHeight()

  -- top
  if camera.y <= h/2 then
    camera.y = h/2
  end

  -- right
  if camera.x >= mapW - w/2 then
    camera.x = mapW - w/2
  end

  -- bottom
  if camera.y >= mapH - h/2 then
    camera.y = mapH - h/2
  end

  -- left
  if camera.x <= w/2 then
    camera.x = w/2
  end

  playerController:update(dt)

  world:update(dt)
end
