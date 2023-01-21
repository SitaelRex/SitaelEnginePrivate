--[[
Загружает в пустое окружение скрипта все базовые функции lua + все доступные библиотеки движка
]]

local builder = {}



builder.baseFuncs = {}
builder.baseLibs = EngineCore.modules -- для построения окружения скрипта
builder.baseLibs.math = math


for k,v in pairs(_G) do
    if type(v) == "function" or v == "math" then
        builder.baseFuncs[k] = _G[k]
        --print(k,v)
    end;
end;




builder.CreateScript = function(self)
   -- local scripts = ProjectCore.modules.scripts
    
    local result = {}
    for k,v in pairs(builder.baseFuncs) do
        --print(k)
        result[k] = v
    end;
    
    for k,v in pairs(builder.baseLibs) do
        --print(k)
        result[k] = v
    end;
    
    result._local = {}
    --result._local._variable_storage = {}
   -- result._local._reserved = {} --для хранения информации о скрипте
   
    
    local mt = {
        __newindex = function(t,k,v) 
            local scriptInfo = scripts:GetCurrentRun() 
           -- local scriptIdx = scriptInfo.scriptIdx
           -- local currentEntity = scriptInfo.currentEntity
            
            scriptInfo.currentEntity.scriptable.scripts_storage[scriptInfo.scriptIdx]._local[k] = v
           -- utils.PrintTable(t) 
          --  print( scriptInfo.currentEntity,k,v) 
        end,
        
        __index = function(t,k,v) 
            local scriptInfo = scripts:GetCurrentRun() 
            return scriptInfo.currentEntity.scriptable.scripts_storage[scriptInfo.scriptIdx]._local[k]
        end
        }
    setmetatable(result._local,mt)
    
    return result
end;


builder.IsBaseFunc = function(self,funcName)
    return builder.baseFuncs[funcName] and true or false
end;


return builder