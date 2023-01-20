--попробуй сделать тут защиту
local Pipeline = {}
local PipelineStorage = {size = 0, unnamed = {}, emptyUnnamed = {}}
local nameBlackList = {size = true ,unnamed = true, emptyUnnamed = true }

local function NameIsLegal(name)
    return not nameBlackList[name]
end;

Pipeline.__mt = {
    __index = Pipeline
}
------------------------------------------
--Debug
local logParams = {}
logParams.size = function() print(PipelineStorage.size) end
logParams.unnamed = function() print(PipelineStorage.unnamedCount) end
logParams.list = function(curPipelineName,pipeline)
    if curPipelineName then
        local curPipeline =  pipeline or Pipeline:GetPipeline(curPipelineName)
        print("________ '"..curPipelineName.."' List_________")
        for i = 1, #curPipeline.storage do
            local key,funcName = i, curPipeline.storage[i]
            local func = curPipeline.pipeline[funcName]
            print(key,funcName,func)
        end;
        print("_______________________________")
    else
        print("________Pipelines List_________")
        for key,value in pairs(PipelineStorage) do
            if type(key) == "string" and NameIsLegal(key) then
                print(key,value)
            end;
        end;
        print("_______________________________")
    end;
end;

function Pipeline:Log(param,...)
    logParams[param](...)
end;
------------------------------------------ для каждого отдельного пайплайна
local function GetUnnamedIndex() --находит свободное имя
    if #PipelineStorage.emptyUnnamed > 0 then
        local result = PipelineStorage.emptyUnnamed[1]
        table.remove(PipelineStorage.emptyUnnamed,1)
        return result
    end;
    return #PipelineStorage.unnamed + 1
end;

local function AssignName(name)
    local isUnnamed = false
    if not name then 
        local unnamedIdx = GetUnnamedIndex()
        PipelineStorage.unnamed[unnamedIdx] = true
       -- PipelineStorage.unnamed[] = PipelineStorage.unnamedCount + 1;
        isUnnamed = unnamedIdx  
    else
        assert(NameIsLegal(name),"name '"..name.."' is reserved by Pipeline module.")
    end
    local name = name or "unnamedPipeline"..isUnnamed
    return name,isUnnamed
end;

local function Insert( self,func,name,idx )
    assert(type(func) == "function","Pipeline can store only functions! arg #2 must be a function.")
    assert(name, "Pipeline step must have name. arg #3 must be a string.")
    assert(not self.pipeline[name], "Pipeline step with name '"..name.."' already exists. arg #3 must be a unique name." )
    local maxIdx = #self.storage + 1
    local idx = ( idx and idx <=  maxIdx ) and idx or  maxIdx

    table.insert( self.storage, idx,name )
    self.storage[name] = idx --or #self.storage
    self.pipeline[name] = func 
    
    local changed = #self.storage - idx
    if changed > 0 then
        for i = idx, idx + changed do
            local name =  self.storage[i]
            self.storage[name] = self.storage[name] + 1
        end;
    end;
end;

local function Remove( self,idxOrName )
    local idx,name
    if type(idxOrName) == "number" then
        idx = idxOrName
        name = self.storage[idx]
    else
        idx = self.storage[idxOrName]
        name = idxOrName
    end;
    
    local changed = #self.storage - idx
    self.storage[name] = nil
    self.pipeline[name] = nil 
    
    if changed > 0 then
        for i = idx+1, idx + changed do
            local name =  self.storage[i]
            self.storage[name] = self.storage[name] - 1
        end;
    end;
    
    table.remove(self.storage,idx)
end

local function DestroyPipelineBase(self)
    for k,_ in pairs(self) do
        self[k] = nil
    end;
    
end;

local function Do( self )
    if not PipelineStorage[self] then self = DestroyPipelineBase(self) end
    assert(self,"Called Pipeline Was Deleted.")
    self.result = {}
    for i = 1, #self.storage do
        local stepName = self.storage[i]
        local func = self.pipeline[stepName]
        self.result[stepName] = func(self)
    end;
end;

local function GetResult(self,stepName)
    local result = self.result[stepName]
    assert(result,"No result in Pipeline step '".. stepName.."'")
    return result
end;

local function CreatePipelineBase(name,isUnnamed)
    local result = {}
    result.unnamed = isUnnamed
    result.assignedName = name
    result.storage = {}
    result.pipeline = {}
    result.result = {} --перезаписывается каждый вызов Do
    result.Insert = Insert
    result.Remove = Remove
    result.Do = Do
    result.GetResult = GetResult
    
    result.Log = function(self)
        Pipeline:Log("list",self.assignedName,self)
    end;
    
    return result
end;

local function NewPipeline(_,name)
    PipelineStorage.size = PipelineStorage.size + 1 --увеличиваем размер хранилища
    local pipelineName, isUnnamed = AssignName(name) --присваиваем пайплайну имя
    local pipelineBase = CreatePipelineBase(pipelineName,isUnnamed) -- создаем пайплайн
    
    PipelineStorage[pipelineName] = pipelineBase --своеобразный лист, где можно искать индекс по значению а значение - поиндексу
    PipelineStorage[pipelineBase] = pipelineName --
    
    return PipelineStorage[pipelineName]
end
------------------------------------------
function Pipeline:GetPipeline(name) --безопасный способ получения пайплайна
    assert(name and type(name) == "string" , "'"..name.."' is not a valid name of Pipeline.")
    local result =  PipelineStorage[name]
    assert(result,"Pipeline with name '"..name.."' is not exist.")
    return result
end;

function Pipeline:DeletePipeline(name) 
    if name and type(name) == "string"  then
        PipelineStorage.size = PipelineStorage.size - 1
        local unnamedIdx =  PipelineStorage[name].unnamed 
        if unnamedIdx then PipelineStorage.unnamed[unnamedIdx] = nil; table.insert(PipelineStorage.emptyUnnamed, unnamedIdx) end
        local pipeline = PipelineStorage[name]
        PipelineStorage[name] = nil  --просто удаляем все что есть в хранилище по значению и по индексу
        PipelineStorage[pipeline] = nil
    end;
end;

return setmetatable(Pipeline, {
    __call = function(...)
        return NewPipeline(...)
    end,
})