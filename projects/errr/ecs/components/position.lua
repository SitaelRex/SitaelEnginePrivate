local component_name = "position"
local inheritanceMode = "addition"
local component = ecs.component(component_name, function(c, params,e)
    local params = params[component_name] or {}
    c.x = params.x  or 0
    c.y = params.y  or 0
end,inheritanceMode)

return component