drawable_storage = {}

local function SetSprite(e)
  --  print("!!",e)
  local c = e.drawable
  
  local drawable_type = ecs.GetSpriteType(e)
  local target_index = 1 --заглушечный индекс
  
 
  
  c.sprite =  drawable_storage[drawable_type][target_index].sprite --это заглушка
  c.sprite_size = drawable_storage[drawable_type][target_index].info.size--{ w = c.sprite:getPixelWidth( ), h = c.sprite:getPixelHeight( )} --добавить инфу о каждом спрайте?
  e.anchors.offset = {x = c.sprite_size.w * ((e.anchors.x/2) + 0.5) , y = c.sprite_size.h * ((e.anchors.y/2) + 0.5)} --расчитываем смещение от якорей
end;

local DrawSystem = ecs.system({
    pool = {"drawable","position","anchors" } --пул с комопнентами, объект должен содержать весь этот пул, чтобы пойти в отрисовку
})


local current_camera = nil; --вынести все что связано с камерой в модуль камеры вслед за списком рендера


function DrawSystem:setupSystem(...)
  self:update(...)
end;

function DrawSystem:update(dt)
  --  if true then return end
 -- local camera = ProjectCore.modules.camera
  current_camera = camera:GetCurrentCamera()--pool[camera.currentCameraName]
 -- print("____________IN DRAW SYSTEM",self.pool)
  --for _,e in ipairs(self.pool)  do
  for e in self.pool:SortedPool() do--ipairs(self.pool) do
 -- for e in self.pool:SortedPool() do--ipairs(self.pool) do
    SetSprite(e)
  end
end

local function render(e,objects_count)
  --финальные координаты с учетом основной позиции, и позиции камеры
    local AbsolutePosition = e:GetAbsolute("position")
    local final_cords = { x =  AbsolutePosition.x - current_camera.position.x ; y = AbsolutePosition.y - current_camera.position.y}
   -- local final_cords = { x =  e.position.x - current_camera.position.x ; y = e.position.y - current_camera.position.y}
  --финальные координаты с учетом якоря
  local anchored_final_cords = { x =  final_cords.x - e.anchors.offset.x ; y = final_cords.y - e.anchors.offset.y} 
  love.graphics.draw(e.drawable.sprite, anchored_final_cords.x, anchored_final_cords.y) -- а эту функцию мы отправляем в очередь в систему слоев
 -- debuger.AddPoint(final_cords,objects_count)
end;

function DrawSystem:draw()
   -- local room = ProjectCore.modules.roomManager
   -- if true then return end
    local objectsCount = #self.pool
    local layers = room:getCurrentRoom().layers 
  
    for e in self.pool:SortedPool() do -- пробегаемся по пулу подходящих объектов
        layers:pushQueue(e,function() render(e,objectsCount) end) -- пихаем их рендер в очередь
    end
    
    layers:Draw() -- рисуем объекты
end

return DrawSystem