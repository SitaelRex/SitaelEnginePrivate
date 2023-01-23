--private methods
local saveProcess = {}
local NewSaveProcess
local libPath = (...):gsub('%.saveProcess$', '');
local persistence   = require (libPath..'.persistence' );
saveProcess.__mt = {
    __index = saveProcess
}

function saveProcess:Continue()
    local ok,progress = coroutine.resume( self.coroutine ,self.path ,self.data)
    if ok then
        self.progress = progress
        local coroutineIsDead = progress >= 100
        return coroutineIsDead
    else
        error("saveProvess.lua "..progress)
    end
end;

NewSaveProcess = function(_,owner,data,save_path,mode)
    local process = {}
    process.owner = owner
    process.data = data
    process.path = save_path
    process.mode = mode
    process.progress = 0
   -- print()
    
    --local threadCode = [[
    --    path,data =  ... 
    --  --  persistence.store(path,data)
    --]]
    --local thread = love.thread.newThread( threadCode )
    --thread:start( path,data)
    process.coroutine = coroutine.create(persistence.store)
    return setmetatable(process, saveProcess.__mt)
end;


return setmetatable(saveProcess, {
    __call = function(...)
        return NewSaveProcess(...)
    end,
})