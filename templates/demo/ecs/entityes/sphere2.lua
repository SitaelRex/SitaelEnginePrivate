local entity_name = "sphere2"
local function sphere2(e,params)
    local params = params or {}
    params = SetEntityType(entity_name,params)
    params.drawable = params.drawable or {}
    params.drawable.sprite_path = "assets/sprites/sphere-02-export.png"
    params.drawable.layer = "upper"
    params.drawable.sprite_type = "sphere2"
   -- params.scriptable = params.scriptable or {}
   -- params.scriptable[1] = {}
   -- params.scriptable[1].script_path = "elevator"
    
   -- e.obj_type =  e.obj_type or "sphere2"
    e
    :assemble(ecs.entity_storage.sprite,params)
    :give("velocity", params)
end;
return sphere2;