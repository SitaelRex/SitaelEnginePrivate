--модуль для получения абсолютных значений компонентов

local utils = EngineCore.modules.utils


local absoluteStorage = {} -- таблица с абсолютными значениями компонентов всех объектов
setmetatable( absoluteStorage , { __mode = "k" } )

local InheritModes = {}
InheritModes.addition = function(childVar,parentVar)
    return childVar + parentVar
end;
InheritModes.multiply = function(childVar,parentVar)
    return childVar * parentVar
end;
InheritModes.ignore = function(childVar,parentVar)
    return childVar
end;

local function Log()
    print(GetTableLenght(absoluteStorage))
end-- количество позиций в таблице

local function Inherit(childComponent,parentComponent)
    local result = {}
    local mode = childComponent.__inheritanceMode
    for k, v in pairs(childComponent) do
        if  utils.IsMeta(k) then goto continue end
        result[k] =  InheritModes[mode](v,parentComponent[k])
        ::continue::
    end;
    return result
end;

local function Get(owner,component)
    local componentTable = owner[component]
    if not componentTable then
        error("Owner not contains component '"..component.."'",2) 
    end;
    local result 
    local parentName =  utils.GetParentName(owner)--owner.hierarchy.parent_name
    if  parentName then
       -- print(parentName)
        local parentTable = utils.GetObject(parentName)   
        local parentAbsolueTable = absoluteStorage[parentTable] or nil
        result = parentAbsolueTable and Inherit(componentTable,parentAbsolueTable) or componentTable --error(":(") --componentTable
        absoluteStorage[owner] = result
       -- if not parentAbsolueTable then  --если родителя не существует в absolute table, значит он удален
       --     Despawn(owner)
       -- end;
        return result
    end;
    
    result = componentTable
    absoluteStorage[owner] = result
    return result
end;

    
local componentInherit = {}

componentInherit.Log = Log
componentInherit.GetAbsolute = Get

return componentInherit