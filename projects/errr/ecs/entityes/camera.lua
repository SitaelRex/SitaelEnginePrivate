local entity_name = "camera"
--local utils = EngineCore.modules.utils

--error(room)



local camera = function (e,params)  
    local params = params or {}
    params = SetEntityType(entity_name,params)
    
   -- e.obj_type =  e.obj_type or "camera" 
    e
    :assemble(ecs.entity_storage.object,params)
    :give("position", params,e)
    :give("camera", params,e)
end;
return camera