local entity_name = "sprite"
local function sprite(e,params)
    local params = params or {}
    params = SetEntityType(entity_name,params)
    params.drawable.sprite_type = params.drawable.sprite_type or "none_typed_sprite" --забыл зачем это было нужно
    e
    :assemble(ecs.entity_storage.object,params)
    :give("anchors", params,e)
    :give("position", params,e)
    :give("rotation", params,e)
    :give("drawable", params,e)
end;
return sprite;