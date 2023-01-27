local component_name = "velocity"
local inheritanceMode = "ignore"
local component = ecs.component(component_name, function(c, params,e)
    local params = params[component_name] or {}
    c.x = params.velocity_x  or 0
    c.y = params.velocity_y  or 0
    
    c.setup_completed = true
end,inheritanceMode)

return component