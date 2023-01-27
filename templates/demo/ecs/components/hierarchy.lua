local component_name = "hierarchy"
local inheritanceMode = "ignore"


local component = ecs.component(component_name, function(c, params,e)
    local params = params[component_name] or {}
    c.object_name = params.name or utils.GenerateName(params.entity_type)---utils.GenerateName(e:GetObjType())--"generated_name" --нужно гененировать имя по типу "objtype_"..#storage[objtype]
    c.parent_name = params.parent or nil
    c.childs_names = List()
    
    c.level = 1-- Attach(c.object_name,c.parent_name) --math.floor(math.random(1,5))--1 -- PARENT.HIERARCHY.LEVEL + 1
    c.entity_type = params.entity_type or "unnamed_entity_type"

   
    if c.parent_name   then
        engineEvent:SubscribeOnceEmited("ObjectsSpawned", function(...) print("attach after objects spawned",c.object_name,c.parent_name)  utils.Attach(c.object_name,c.parent_name) end)
    end

    
    --c.__index = getAbdoluteValue(c) для записи c.position.absolute.x
  --  c.setup_completed = true
end,inheritanceMode)

ecs.AddComponentSetupFunc(component_name,function(e) room:getCurrentRoom():InsertEntityToNamedList(e) end ) -- добавляем объект в именованый пул
ecs.AddComponentSetupFunc(component_name,function(e) room:getCurrentRoom():InsertEntityToTypedList(e) end )
ecs.AddComponentDestroyFunc(component_name, function(e) room:getCurrentRoom():RemoveEntityFromNamedList(e) end) -- удаляем объект из именованого пула
ecs.AddComponentDestroyFunc(component_name, function(e) room:getCurrentRoom():RemoveEntityFromTypedList(e) end)
--удаляем объект из пула групп объектов

return component