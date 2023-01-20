

local func = function(engineEvent)
    engineEvent:CreateOnceEmited("ObjectsSpawned") --used by roomy
    engineEvent:CreateOnceEmited("SystemPoolUpdated")
    engineEvent:CreateOnceEmited("OnLoadEnd") --used by roomy
    engineEvent:CreateOnceEmited("OnSaveEnd") 
end;

return func