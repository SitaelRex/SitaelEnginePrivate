--Camera Init
-- к камере можно подключать постпроцессинг и шейдеры (например освещение)
--local ecs = ecs;

local camera = {};
camera.currentCameraName = {nil};
camera.pool = {};

camera.GetCurrentCameraName = function(self)
    return camera.currentCameraName[1]
end;

camera.GetCurrentCamera = function(self)
    return self.pool[camera.currentCameraName[1]]
end;

camera.AddToPool = function(name,object)
  assert(not camera.pool[name], "camera '"..name.."' already exists")
  camera.pool[name] = object;
end;

camera.RemoveFromPool = function(name)
  camera.pool[name] = nil;
end;

camera.GoToCamera = function(name)
  assert(camera.pool[name], "camera '"..name.."' not exist!")
  camera.currentCameraName = {name};
end;

camera.IsCurrent = function(camera_name)
    if camera_name then
        return camera.currentCameraName[1] == camera_name
    else
        return camera.currentCameraName[1]
    end;
end

--function ecs.entity_storage.camera(e,params) -- попробуй написать функцию ecs:AddEntity()
--  local params = params or {}
--  e
--  :assemble(ecs.entity_storage.object,params)
--  :give("position", params,e)
--  :give("camera", params,e)
--end;
 
--local component_name = "camera"
--local cameraComponent = ecs.component(component_name, function(c, params,e) -- попробуй написать функцию ecs:AddComponent()
--    local params = params.camera or {}
--    local default_name = "default_camera"
--    c.name = params.name or default_name;
--end)
--
--ecs.AddComponentSetupFunc(component_name,function(e) local name = e.camera.name; camera.AddToPool(name,e); camera.GoToCamera(name) end  )
--ecs.AddComponentDestroyFunc(component_name, function(e) camera.RemoveFromPool(e.camera.name) end)

return camera;