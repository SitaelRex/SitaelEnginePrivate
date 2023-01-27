local entity_name = "sphere3"
local function sphere3(e,params)
    local params = params or {}
    params = SetEntityType(entity_name,params)
    params.drawable = params.drawable or {}
    params.drawable.sprite_path = "assets/sprites/sphere-03-export.png"
    params.drawable.sprite_type = "sphere3"
   -- params.scriptable = params.scriptable or {}
    --params.scriptable.script_path = "line"
    
    
    --e.obj_type =  e.obj_type or "sphere3"
    e
    :assemble(ecs.entity_storage.sprite,params)
    :give("velocity", params)
end;
return sphere3;