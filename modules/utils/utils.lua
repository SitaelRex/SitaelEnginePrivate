------------------------------------------------Utils
--[[]]
------------------------------------------------Utils Global (call without prefix utils.)
local List = EngineCore.modules.List
local engineEvent = EngineCore.modules.engineEvent

local utils = {}


utils.IsMeta = function(key)
    return key:find("__")
end;

utils.BackInTime = function()
    reversed = not reversed
    info("Time is moving ".. (reversed and "back" or "forward"))
end;

utils.ZAWARUDO = function()
    paused = not paused
    info("Time ".. (paused and "Paused" or "Released"))
end;


utils.SetObject = function(object, params)
    local obj = type(object) == "string" and utils.GetObject(object) or object
    for componentName, componentTable in pairs(params) do
        for varName, value in pairs(componentTable) do
            if obj[componentName] and obj[componentName][varName] then
                obj[componentName][varName] = value
            end;
            
        end;
    end;
end;

utils.GetObject = function(objectName)
    local room = ProjectCore.modules.roomManager
    return room:getCurrentRoom():GetEntityByName(objectName) 
end;
utils.GetParentName = function(objectOrName)
    local obj = type(objectOrName) == "string" and utils.GetObject(objectOrName) or objectOrName
    local result = obj.hierarchy and obj.hierarchy.parent_name
    return result
end;

local PushLayer
PushLayer = function(world,e, layer)
   -- local systemPoolLayer = parent.hierarchy.level + 1
  -- print("PUSH LAYER",layer, e.hierarchy.object_name)
    e.hierarchy.old_level = e.hierarchy.level 
    e.hierarchy.level = layer--systemPoolLayer
    
    for i = 1,#world.__systems do
        world.__systems[i]:__updatePool(e)
    end;
    e.hierarchy.old_level = nil
     
   -- e:updatePoolLayer()
    for i = 1, #e.hierarchy.childs_names do
       -- print("update child")
        local child = utils.GetObject( e.hierarchy.childs_names[i] )
        assert(child and child.hierarchy , "child of child is nil or not hierarchy component in child!")
        
        PushLayer(world,child,layer+1)
    end;
end;
--Attach("powerfull","mighty");Attach("mighty","beautifull");Attach("theGreat","powerfull");Attach("player","theGreat");Detach("powerfull");Attach("unique","player");
utils.PrintChilds = function(objectName)
    local obj = utils.GetObject(objectName)
    assert(obj and obj.hierarchy , "obj is nil or not hierarchy component in child!")
    print("_____________________")
    print("Childs of",obj.hierarchy.object_name)
    for i = 1,  obj.hierarchy.childs_names.size do
        print(obj.hierarchy.childs_names[i])
    end;
    print("_____________________")
end;

utils.PrintParent = function(objectName)
    local obj = utils.GetObject(objectName)
    assert(obj and obj.hierarchy , "obj is nil or not hierarchy component in child!")
    print("_____________________")
    print("Parent of",obj.hierarchy.object_name,"is",obj.hierarchy.parent_name or "nobody")
    print("_____________________")
end;


utils.Detach = function(objectOrName)
   -- print(422,objectName)
    local child = type(objectOrName) == "string" and utils.GetObject(objectOrName) or objectOrName
    child:updatePoolLayer()
    
    local function func(world)
      --  print(422,objectName)
        assert(child and child.hierarchy , "child is nil or not hierarchy component in child!")
        local oldParent = utils.GetObject(child.hierarchy.parent_name)
        
        --if not oldParent then return end
        assert(oldParent and oldParent.hierarchy, "oldParent is nil or not hierarchy component in parent!")
            -- if oldParent then
        List.remove( oldParent.hierarchy.childs_names, objectName)
        --end;
        child.hierarchy.parent_name = nil
    
        PushLayer(world,child, 1)
    end
    engineEvent:SubscribeOnceEmited("SystemPoolUpdated",func)
end;

local RecursiveCheckChilds

RecursiveCheckChilds = function(child,parentName)
    local result = List.has(child.hierarchy.childs_names,parentName)
    
    if  result then
        return result
    else
        for i = 1, #child.hierarchy.childs_names do
             local child = utils.GetObject( child.hierarchy.childs_names[i] )
             result = RecursiveCheckChilds(child,parentName)
             if result then return result,child end
        end;
    
    end;
    
   
end;

utils.Attach = nil
utils.Attach = function(objectName,parentName)
    
    if not parentName or parentName == objectName then err("Try To Attach object to himself!") error() return end;
    
    local child = utils.GetObject(objectName)
    
    child:updatePoolLayer()  
    local tryAttachChild,nearestChild = RecursiveCheckChilds(child,parentName)
   -- print(tryAttachChild,nearestChild)
    if tryAttachChild then
        err("Try To Attach parent to child!")
        error()
        return
    end;
        
    
    
    local function func(world)
        
        
         
        if not parentName then return end;
        local parent = utils.GetObject(parentName)
        assert(child and child.hierarchy , "child is nil or not hierarchy component in child!")
        
        local oldParent = utils.GetObject(child.hierarchy.parent_name)
            if oldParent then
                child.hierarchy.parent_name = nil
                List.remove( oldParent.hierarchy.childs_names, child)
            end;
        
            List.add( parent.hierarchy.childs_names,child.hierarchy.object_name)
        
        
            child.hierarchy.parent_name = parent.hierarchy.object_name
        
            PushLayer(world,child, parent.hierarchy.level + 1)
    end;
    
    engineEvent:SubscribeOnceEmited("SystemPoolUpdated",func)
    
end;





utils.SetEntityType = function(entity_name,params) --используется в hierarchy
    local currentRoom = room:getCurrentRoom()
    local result = currentRoom.hierarchy.SetEntityType(entity_name,params)
   -- print("set entity type",entity_name,params)
    return result
end;

utils.PrintTable = function(t)
   -- print(11)
    for k,v in pairs(t) do
        if not scripts.builder:IsBaseFunc(k) and type(v) == "function" then
            print("PrintTable",k,v)
        end;
    end;
end;

utils.ExpandMetatable = function(t,params) 
--[[
    добавляет дополнительный путь поиска к параметру __index
]]  
--print(11)
    local t = t or {}
    local current_metatable = getmetatable(t)
    if current_metatable then 
        current_metatable.__index = current_metatable.__index --or {}
        local old_index = current_metatable.__index
        local new_index = params.__index
        --if  old_index == new_index then error(1) end
        setmetatable(new_index,{__index = old_index})
        setmetatable(t,{__index = new_index})
    else
        assert(params, "not params in ExpandMetatable")
        setmetatable(t, params)
    
    end;
    
    return t
end;

function utils.ModuleEnvInit()  --возвращает шаблон модуля
    local module_table = {}
    ExpandMetatable(module_table,{__index = _G,})
    setfenv(1, module_table) --работает только в пределах модуля, в котором вызывается функция
    return module_table
end;

--local current_module = ModuleEnvInit()


function utils.Spawn(obj_type,params) --отлично работает
    room:getCurrentRoom():SpawnEntity(obj_type,params)
end;

local RecursiveDespawn
local function RecursiveDespawn(entity)
    
    if entity.hierarchy then
        for _, childName in pairs(entity.hierarchy.childs_names) do
            if type(childName) ~= "string" then goto continue end
          --  print(childName)
          --print("~~~~",childName)
            local e = utils.GetObject(childName)
            RecursiveDespawn(e)
            ::continue::
        end;
        
        
    end;
    entity:destroy()
end;


function utils.Despawn(entityOrName)
    local entity = type(entityOrName) == "string" and utils.GetObject(entityOrName) or entityOrName
    --entity:destroy()
    RecursiveDespawn(entity)
   
end;


function string:cut(reference) --сокращенный вырезатель gsub
    return self:gsub(reference, "")
end;

function utils.get_source_code(f) --возвращает код функции в виде строки
    local t = debug.getinfo (f)
    if t.linedefined < 0 then print("source",t.source); return end
    local name = t.source:gsub("^@","")
    local i = 0
    local text = {}
    for line in io.lines(name) do
        i=i+1
        if i >= t.linedefined then text[#text+1] = line end
        if i >= t.lastlinedefined then break end
    end
    return table.concat(text,"\n")
end
------------------------------------------------Utils Module
--local current_module = ModuleEnvInit()

utils.InverseIndexing = function(table) --возвращает новыю таблицу, где делает индексы исходной таблицы- значениями, а значения - индексами
    local result_table = {}
    for key,val in pairs(table) do
        result_table[val] = key
    end;
    return result_table
end;

utils.GetFirstIndex = function(tab)
  for idx,_ in pairs(tab) do 
     -- print(111,idx,_)
      return idx;
  end;
end

utils.RequireFolderToTable = function(table,path_to_folder)
end;

utils.GetTableLenght = function(table)
    local result = 0
    for _,_ in pairs(table) do
        result = result + 1 
    end;
    return result
end;

utils.generated_names = {}
utils.GenerateName = function(object_type)
    if not utils.generated_names[object_type] then utils.generated_names[object_type] = 0 end
    utils.generated_names[object_type] = utils.generated_names[object_type]+1
    local result = "unnamed_"..object_type.."_"..tostring(utils.generated_names[object_type])
    return result
end;

function utils.DeepCopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[utils.DeepCopy(orig_key, copies)] = utils.DeepCopy(orig_value, copies)
            end
            setmetatable(copy, utils.DeepCopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end  

function utils.TestSpawnII(objects_table,dummy_count) --тест производительности ecs и системы слоев --вынести в библиотеку тестов
    local x_diapozone = {min = 100, max = 800}
    local y_diapozone = {min = 100, max = 800}
    local velocity_y_diapozone = {min = 100, max = 800}
    local velocity_x_diapozone = {min = 100, max = 800}
    for i = 1, dummy_count do
        local rand = love.math.random(1,3)
        local obj_type = (rand > 2) and "sphere" or ((rand > 1) and  "sphere2" or "sphere3")
        local dummy = {object = obj_type, params = { position = { x = 0, y = 0 }, velocity = { velocity_y = 0,velocity_x =0  } }}
        dummy.params.position.x = love.math.random(x_diapozone.min,x_diapozone.max)--*(love.math.random(-1,1) > 0 and 1 or 0 )
        dummy.params.position.y = love.math.random(y_diapozone.min,y_diapozone.max)--*(love.math.random(-1,1) > 0 and 1 or 0 )
        dummy.params.velocity.velocity_y = love.math.random(velocity_y_diapozone.min,velocity_y_diapozone.max)
        dummy.params.velocity.velocity_x = love.math.random(velocity_x_diapozone.min,velocity_x_diapozone.max)
        
        dummy.params.scriptable = { {script_path = "wrapToScreen"}    } 
    
        table.insert(objects_table,dummy)
    end;
end;



return utils