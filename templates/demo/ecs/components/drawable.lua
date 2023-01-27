--newImage должен фигурировать только в этом месте
--[[
TODO реальная адаптивность функции set sprite под любые возможные таблицы параметров
TODO реализовать в сущностях конструкторы такой таблицы
TODO разделить компонент на неделимые состовные части ничего не сломав
]]

--local pathManager = EngineCore.modules.pathManager



local component_name = "drawable"
local inheritanceMode = "ignore"
local default_drawable_path = pathManager.GetProjectPath().."assets/sprites/not_sprite.png"
local default_drawable = love.graphics.newImage(default_drawable_path) 

local function CreateAtlas(c) --это заглушка, здесь мы должны создавать атлас исходя из draw_params
	local oldIdentity = love.filesystem.getIdentity()
	love.filesystem.setIdentity("Sitael",false)
	
  local result = {}
  local params = c.sprite_draw_params
  local index = 1 --заглушечный индекс 
  result[index] = {} 
  --sprite
  result[index].sprite = love.graphics.newImage(pathManager.GetProjectPath()..params.drawable_asset) 
  --info
  result[index].info = {}
  result[index].info.size = {}
  result[index].info.size.w  = result[index].sprite:getPixelWidth( )
  result[index].info.size.h  = result[index].sprite:getPixelHeight( )
	
	love.filesystem.setIdentity(oldIdentity,false)
	
  return result
end;

local function UpdateSpriteStorage(e)
  local drawable_type = e.drawable.sprite_type
  local c = e[component_name]
  if drawable_storage[drawable_type] then 
    return --если атлас уже имеется
  else
    drawable_storage[drawable_type] = CreateAtlas(c) --создаем атлас
  end --если уже есть
  
end;



local component = ecs.component(component_name, function(c,params,e) 
    --    local layers =  ProjectCore.modules.layers
        
        
    local owner = e
    local params = params[component_name] or {}
    
    c.sprite_type = params.sprite_type or "none_typed_sprite"
  --  c.owner_object = owner --НЕЛЬЗЯ!!
    c.sprite = nil--default_drawable
    c.sprite_size = {w = 0, h = 0} --установится в SetSprite вызванном из DrawSystem:Update
    c.anchors = { x = params.anchor_x or 0 , y = params.anchor_y or 0}
    c.sprite_draw_params = {
      drawable_asset = params.sprite_path or default_drawable_path,
    }
    c.layer = params.layer  or layers.GetFrontLayer()
    c.z_index = params.z_index or 1
    
    c.setup_completed = true
end,inheritanceMode)

ecs.AddComponentSetupFunc(component_name,function(e) UpdateSpriteStorage(e) end ) --пытаемся закинуть атлас объекта в общее хранилище спрайтов при создании объекта


return component