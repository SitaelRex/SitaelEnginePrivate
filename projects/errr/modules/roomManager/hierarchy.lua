--модуль для работы с room.lua и ecs component hiearachy 
local module = {}

--local utils = EngineCore.modules.utils

local function GetEntityType(entity)
    return entity.hierarchy.entity_type
end;

local function GetEntityIdx(entity)
    return entity.hierarchy.idx 
end;

local function SetEntityIdx(entity,idx)
    entity.hierarchy.idx = idx
end;

local function GetNewIndex(type_list, nil_list)
    local fount_nil = nil
    for key,_ in pairs(nil_list) do
        fount_nil = key
        break;
    end;
    local idx = fount_nil or #type_list + 1
    return idx
end;

module.SetEntityType = function(entity_name,params) -- перенести в модуль hierarchy
    params.hierarchy = params.hierarchy or {}
    params.hierarchy.entity_type = params.hierarchy.entity_type or entity_name
    return params
end;

module_methods = {} --local table
module_methods.InsertEntityToTypedList = function(self,entity)
    local entity_type = GetEntityType(entity)
    self.typedEntityList[entity_type] = self.typedEntityList[entity_type]  or {}
    self.typedEntityListNils[entity_type] = self.typedEntityListNils[entity_type] or {}
    
    local idx = GetEntityIdx(entity) or GetNewIndex(self.typedEntityList[entity_type],self.typedEntityListNils[entity_type]) --#self.typedEntityList[entity_type] + 1
    self.typedEntityListNils[entity_type][idx] = nil
    SetEntityIdx(entity,idx)
    
    self.typedEntityList[entity_type][idx] = entity
end;

module_methods.RemoveEntityFromTypedList = function(self,entity)
    local entity_type = GetEntityType(entity)
    local idx = GetEntityIdx(entity)
    self.typedEntityList[entity_type] = self.typedEntityList[entity_type] or {}
    self.typedEntityList[entity_type][idx] = nil
    
    self.typedEntityListNils[entity_type] = self.typedEntityListNils[entity_type] or {}
    self.typedEntityListNils[entity_type][idx] = true
end;

--------------------------------------------
module_methods.GetEntityByID = function(type,id)
    return self.typedEntityList[type].id
end;

module_methods.GetFirstEntityByID = function(self,type)
    local targetList = self.typedEntityList[type]
    local result = nil
    for key,entity in pairs(targetList) do
        result = entity
        break
    end;
    return result
end;

module_methods.InsertEntityToNamedList = function(self,entity)
    local index = entity.hierarchy.object_name
    self.namedEntityList[index] = entity
end;

module_methods.RemoveEntityFromNamedList = function(self,entity)
    local index = entity.hierarchy.object_name
    self.namedEntityList[index] = nil
end;

module_methods.GetEntityByName = function(self,name)
    return self.namedEntityList[name]
end;

module_methods.PrintPool = function(self,pool_name)
    print("__________________________________________")
    self.typedEntityList[pool_name] = self.typedEntityList[pool_name] or {}
    for key,entity in pairs(self.typedEntityList[pool_name]) do
        print(key,GetEntityIdx(entity))
    end;
end;

module.Setup = function(self,room)
    room.namedEntityList = {}
    room.typedEntityListNils = {}
    room.typedEntityList = {}
    room.InsertEntityToTypedList = module_methods.InsertEntityToTypedList
    room.RemoveEntityFromTypedList = module_methods.RemoveEntityFromTypedList
    room.GetEntityByID = module_methods.GetEntityByID
    room.GetFirstEntityByID = module_methods.GetFirstEntityByID
    room.InsertEntityToNamedList = module_methods.InsertEntityToNamedList
    room.RemoveEntityFromNamedList = module_methods.RemoveEntityFromNamedList
    room.GetEntityByName = module_methods.GetEntityByName
    room.PrintPool = module_methods.PrintPool

   -- utils.ExpandMetatable(room,{ __index = module_methods})
    return room
end;

return module