local component_name = "rotation"
local inheritanceMode = "addition"
local component = ecs.component(component_name, function(c, params,e)
    local params = params[component_name] or {}
    c.angle = params.angle or 0
end,inheritanceMode)

return component