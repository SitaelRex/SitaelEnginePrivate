local entity_name = "object"
local function object(e,params)
    local params = params or {}
    params = SetEntityType(entity_name,params)
    
  --  e.obj_type =  e.obj_type or "object"  --модифицируемое имя объекта --испольхуется для сохранения --не должно тут храниться, вынести в другой компонент
    e
    :give("hierarchy", params, e)
    :give("scriptable", params, e)
end;
return object;