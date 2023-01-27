


script_load = function(owner) 
    --[[
    load будто-бы выполняется только один раз и сразу для всех объектов, содержащих скрипт
    сделать отдельную функцию load выполняющуюся для всех объектов
    ]]

    a = 100
    hyper_game_info  = {} --к созданию таблиц тоже отнести !
    hyper_game_info.a = 1
    hyper_game_info.b = 100
   -- hyper_game_info.a = 2
end;
--print(script_load,script.script_load)
--print("PRELOAD 2")

function update(dt,owner,params)
   -- _local.position = owner-- _local.position  or { x = 0, y = 0}
    --print(_local.position.x,position.y )
  hyper_game_info.a = hyper_game_info.a +1
  
 -- if input:pressed("camera1") then camera.GoToCamera("first") end
 -- if input:pressed("camera2") then camera.GoToCamera("second") end
 -- if input:pressed("test") then print(owner.scriptable.id,"saved data",hyper_game_info.a,hyper_game_info.b)  end
  
  --if not camera then print("camera fuckup") return end
 -- print(owner.camera,owner.camera.name)
  local target_camera =  owner.camera and owner.camera.name or nil --почему-то в овнере НЕТ КАМЕРЫ НА МОМЕНТ первого ВЫПОЛНЕНИЯ СКРИПТА
  --print(owner.obj_type,target_camera,camera.IsCurrent(target_camera),camera.IsCurrent())
  --print(owner.scriptable.script_path)
   for k,v in pairs(owner) do
       -- print(k,v)
    end;

  ----if not camera.IsCurrent(target_camera) then return end
  --
  --local x, y = input:get 'move'
  --local camera_move_speed = 1000
  ----print(camera.currentCameraName)
  --local player =  room:getCurrentRoom():GetEntityByName("player") --or {position = {x = 0 , y = 0} }
 ---- if owner.camera.name == "first" and player then
 ----   
 ----   owner.position.x = 0--player.position.x - 400
 --   owner.position.y =0-- player.position.y - 300
 --   
 --    _local.position = { x = owner.position.x, y = owner.position.y}
 -- end;
  
  
  
  
  
end;

function draw(owner,params)
  
end;

--print("CAMERA SCRIPT IS INIT")

--return script