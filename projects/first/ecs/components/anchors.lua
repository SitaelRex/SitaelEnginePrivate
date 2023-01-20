local component_name = "anchors"
local inheritanceMode = "ignore"

local component = ecs.component(component_name, function(c,params,e) 
    --local owner = e
    local params = params[component_name] or {}
    
    c.x = params.x or 0 
    c.y = params.y or 0
    c.offset = { x = 0 , y = 0 } --значения изменяются в DrawSystem --что это?
    
    c.setup_completed = true
end,inheritanceMode)

return component