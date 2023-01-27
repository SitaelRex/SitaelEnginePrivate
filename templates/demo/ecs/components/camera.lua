


local component_name = "camera"
local inheritanceMode = "ignore"
local component = ecs.component(component_name, function(c, params,e) -- попробуй написать функцию ecs:AddComponent()
        -- local camera = ProjectCore.modules.camera
        -- error(camera)
         
    local params = params.camera or {}
    local default_name = "default_camera"
    c.name = params.name or default_name;
    c.camera_module = camera.currentCameraName
    c.setup_completed = true
end,inheritanceMode)

ecs.AddComponentSetupFunc(component_name,function(e) local name = e.camera.name; camera.AddToPool(name,e); camera.GoToCamera(name) end  )
ecs.AddComponentDestroyFunc(component_name, function(e)   camera.RemoveFromPool(e.camera.name) end)

return component