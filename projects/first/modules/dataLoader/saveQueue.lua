--private methods

--local utils = EngineCore.modules.utils

--print("utils",utils)

local saveQueue = {}
local libPath = (...):gsub('%.saveQueue$', '');
local saveProcess   = require (libPath..'.saveProcess' );
local NewSaveQueue --приватные методы
local queueCount = 0 --проверяет что очередь создана в единственном экземпляре

--local List = EngineCore.modules.List

saveQueue.__mt = {
    __index = saveQueue
}

function saveQueue:Insert(data,save_path,mode)
    local newProcess = saveProcess(self,data,save_path,mode)
    self:Add(newProcess)
end;

function saveQueue:GetCurrentProcess(...)
  --  print("utils",utils)
  --  print(11,self,self.list)
    local idx = utils.GetFirstIndex(self.list)
    
    for k,v in pairs(self.list) do
       -- print (k,v)
        end
   -- print(12,idx)
    return self:Get(idx)
end;

function saveQueue:Get(...)
    return self.list:get(...)
end;

function saveQueue:Add(saveProcess)
    local path = saveProcess.path
    local alreadyExsist = self.unique[path]
    --print("check",path, alreadyExsist )
    if not alreadyExsist then
        self.list:add( saveProcess )
        self.unique[path] = true
        --print("set",path, self.unique[path] )
        --print("check",path, self.unique[path] )
    end;
end;

function saveQueue:Remove(saveProcess)
    local path = saveProcess.path
    self.unique[path] = nil
    self.list:remove(saveProcess)
end;

function saveQueue:Continue()
    local currentSaveProcess = self:GetCurrentProcess()
    local dead = currentSaveProcess:Continue()
    if dead then self:Remove(currentSaveProcess) end
end;

NewSaveQueue = function(_,data,save_path,mode)
    if queueCount == 0 then
        local queue =  {}--List()
       
        queue.list = List()
        queue.unique = {}
        queueCount = queueCount + 1
        
        return setmetatable(queue, saveQueue.__mt)
    else
        error("saveQueue should be a singleton.")
    end;
end;

return setmetatable(saveQueue, {
    __call = function(...)
        return NewSaveQueue(...)
    end,
})