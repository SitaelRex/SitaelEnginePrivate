local PATH = (...):gsub('%.init$', '')

local onceEmitedEventsList = {}
local eventsList = {}

--setmetatable(eventsList,{__index = onceEmitedEventsList})
local engineEvent = {}

engineEvent.Create = function(self,eventName)
    assert(not eventsList[eventName],"Event '"..eventName.."' is Already Exist")
    eventsList[eventName] = {}
end;



engineEvent.Destroy = function(self,eventName)
    eventsList[eventName] = nil
end;



engineEvent.Emit = function(self,eventName,...)
    assert( eventsList[eventName],"Event '"..eventName.."' is Not Exist")
    for i = 1, #eventsList[eventName] do
        eventsList[eventName][i](...)
    end;
    
end;

engineEvent.Subscribe = function(self,eventName, event)
    assert( eventsList[eventName],"Event '"..eventName.."' is Not Exist" )
    assert( type(event) == "function", "event argument is not a Function")
    table.insert( eventsList[eventName],event)
end;

engineEvent.CreateOnceEmited = function(self,eventName)
    assert(not onceEmitedEventsList[eventName],"Event '"..eventName.."' is Already Exist")
    onceEmitedEventsList[eventName] = {}
end;

engineEvent.EmitOnce = function(self,eventName,...)
    if onceEmitedEventsList[eventName] then
        for i = 1, #onceEmitedEventsList[eventName] do
            onceEmitedEventsList[eventName][i](...)
            onceEmitedEventsList[eventName][i] = nil
        end;
    end
end;

engineEvent.SubscribeOnceEmited = function(self,eventName, event)
    assert( onceEmitedEventsList[eventName],"Event '"..eventName.."' is Not Exist" )
    assert( type(event) == "function", "event argument is not a Function")
    table.insert( onceEmitedEventsList[eventName],event)
end;

require(PATH..".defaultEvents")(engineEvent)

return engineEvent