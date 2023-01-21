local entity_name = "sphere"
local function sphere(e,params)
    local params = params or {}
    params = SetEntityType(entity_name,params)
    params.drawable = params.drawable or {}
    params.drawable.sprite_path = "assets/sprites/sphere-01-export.png"
    params.drawable.layer = "upper"
    params.drawable.sprite_type = "sphere"
    
   -- e.obj_type =  e.obj_type or "sphere"
    e
    :assemble(ecs.entity_storage.sprite,params)
    :give("velocity", params)
end;
return sphere;