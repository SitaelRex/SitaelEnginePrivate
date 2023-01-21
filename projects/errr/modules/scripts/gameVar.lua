--создает хранилище переменных
local gameVar = {}

gameVar.variableStorage = { private = {} }
local variablesAddStack = {}

local AddToAddStack = function(key)
    table.insert(variablesAddStack,key)
end;

gameVar.ReleaseAddStack = function(self)
    for i = 1,#variablesAddStack do
        self.variableStorage[variablesAddStack[i]] = true
    end;
    
end;

gameVar.SetToPrivateStorage = function(key,val)
    gameVar.variableStorage.private[key] = val
end;

gameVar.GetFromPrivateStorage = function(self,key)
    local result = self.variableStorage.private[key]
    return result
end;

gameVar.GetLocalStorage = function(self)
    return self.variableStorage
end;

gameVar.GetGlobalStorage = function(self)
    return self.variableStorage
end;

gameVar.GetStorageToSave = function(self)
    local result = {}
    for key,val in pairs(self:GetStorage()) do
        result[key] = _G[key] or val  --приватная часть хранилища переменных
    end;
    return result
end;

gameVar.LoadSavedVariables = function (data)
    for key,val in pairs(data) do
        if key == "private" then
            gameVar.variableStorage.private = val --or {}
        else
            gameVar.variableStorage[key] = val--true
        end;
    end;
end;

gameVar.GetStorage = function(self)
    return self.variableStorage
end;

local InsertGlobalValue = function(t,key,val)
    local is_script_load =  string.find(debug.traceback(),"script_load") and true or false
    local not_tracked = not gameVar.variableStorage[key]
    _G[key] = (not is_script_load or not_tracked )  and val or _G[key] --если переменная выставляется в загрузке, то функция пропускает только первое объявление
    AddToAddStack(key)
    return not_tracked
end;

gameVar.GetValue = function(self,t,key)
    local scripts = ProjectCore.modules.scripts
    
    local result = self.variableStorage[key] --ищем в глобальном хранилище
    if not result then --если не нашли, ищем в локальном
        local scriptInfo = scripts:GetCurrentRun() 
        if scriptInfo then
            return scriptInfo.currentEntity.scriptable.scripts_storage[scriptInfo.scriptIdx]._local[key]
        end;
    end;
    return result
end;

gameVar.DeclareGlobalVariable = function(self,t,key,val) --
    self.variableStorage[key]  = val --true
end;

local moduleSetup = function() 
    return gameVar
end;

return moduleSetup()