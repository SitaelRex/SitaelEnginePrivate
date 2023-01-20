local Interface = {}
local proxyStorage = {}
-----------------------------------private
--операции с прокси интерфейса
local GetProxy = function(interface)
    return proxyStorage[interface]
end;

local SetProxy = function(interface,proxy)
    proxyStorage[interface] = proxy
end;
-----------------------------------public
function Interface.Connect (interface,mod) --подрубает модуль

    local proxy = GetProxy(interface)
    proxy.mod = mod
end;

function Interface:Disconnect() 
end;

function Interface.Destroy(interface) 
    proxyStorage[interface] = nil
    interface = nil
end;

function Interface.AddMethod (interface,name,dummyMethod) 
 --   print("New Method", name)
    interface.methods[name] = dummyMethod
end;

function Interface:RemoveMethod (name) 
    self.methods[name] = nil
end;

function Interface.new(_,ownerCore, name)
    local resultInterface = {}
    resultInterface.methods = {} -- сюда вписываются методы, добавленные функцией add, здесь они ищутся, и если  находятся - пытаются вызвать такой же метод из прокси
    resultInterface.owner = ownerCore
    resultInterface.isInterface = true
    local resultProxy = {}
    resultProxy.mod = nil -- сonnected
    SetProxy(resultInterface,resultProxy)
    
    
    local connected = resultProxy.mod and type(resultProxy.mod) == "table"
    local moduleCall = connected and getmetatable(resultProxy.mod) or nil
    
    setmetatable(resultInterface,{
        __call = function(self,...) 
            local tableConnected = resultProxy.mod and type(resultProxy.mod.source) == "table"
            local functionConnected = resultProxy.mod and type(resultProxy.mod.source) == "function"
            
            local moduleCall = tableConnected and getmetatable(resultProxy.mod.source).__call or ( functionConnected and resultProxy.mod.source )
            return moduleCall(...)
        end,
        __index = function(_,k)  
        local connected = resultProxy.mod
        local result = connected and resultProxy.mod[k] or nil
        
        if type(result) == "function" then
            
            local aresult = function(maybeSelf,...)
                local isSelfCall = type(maybeSelf) == "table" and maybeSelf.isInterface
                if isSelfCall then -- прорверка на вызов через двоеточие
                    local realSelf = resultProxy.mod.source --self модуля из прокси, который мы пытаемся вызвать через интерфейс
                    return result(realSelf,...)
                else
                    local firstArg = maybeSelf
                    return result(firstArg,...)  --если вызов без двоеточия
                end
            end
            return aresult
        end;
        
        if result then
            return result
        else
            return resultInterface.methods[k]
        end;
        
    end})
    return resultInterface
end

return setmetatable(Interface, {
   __call = function(...)
      return Interface.new(...)
   end,
})

------------------------------
--local world = ecs.world:New() -- в коде проекта используется поиск через метатаблицы
--include(ecs) -- внутри модуля для объявления зависимости