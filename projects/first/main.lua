
ProjectCore = nil
ProjectCore = Core(EngineCore,EngineCore.modules.pathManager.projectPath) 
setmetatable(_G, {__index = function(_,key)  return ProjectCore:IndexInterface(key) end })
ProjectCore:LoadModules() 

local r =   ProjectCore:AddInterface("room")
local i =   ProjectCore:AddInterface("input")
local l =   ProjectCore:AddInterface("loader")
local s =   ProjectCore:AddInterface("scripts")
local la =  ProjectCore:AddInterface("layers")
local ca =  ProjectCore:AddInterface("camera")

Interface.Connect(la,ProjectCore:IndexModule("layers"))
Interface.Connect(r,ProjectCore:IndexModule("roomManager"))
Interface.Connect(i,ProjectCore:IndexModule("input"))
Interface.Connect(l,ProjectCore:IndexModule("dataLoader"))
Interface.Connect(s,ProjectCore:IndexModule("scripts"))
Interface.Connect(ca,ProjectCore:IndexModule("camera"))
 
setmetatable(_G, {
    __index = function(_,key) 
        local sourceInfo =  debug.getinfo(2,"S").source 
        local sourceModule,a = sourceInfo:find("modules/") 
        if not sourceModule  then  
            -- if 
            return ProjectCore:IndexInterface(key) --указываем самое высокоуровневое ядро, через которое будет начинаться поиск
        else 
            local sourceInfo = sourceInfo:sub(a+1) 
            sourceInfo = sourceInfo:sub(0,sourceInfo:find("/")-1 ) 
            if sourceInfo == key or ( included[sourceInfo] and included[sourceInfo][key]  ) then
                return ProjectCore:IndexInterface(key) 
            end;
            --  print(sourceInfo)
        end 
    end 
}) 
--
ProjectCore.Update =  Pipeline()
--    
local FuncUpdateInput = function()
    local curRoom = room:getCurrentRoom()
    input:update()
    if not input:Blocked() then
        if input:pressed("room1") then room:GoTo("extra")end
        if input:pressed("room2") then room:GoTo("main_menu") end
        if input:pressed("room3") then room:GoTo("options") end
        if input:pressed("save") then curRoom:StartSave(false) end--loader:SaveDataInProgress(curRoom) end
        if input:pressed("spawn") then  Spawn("sphere",{velocity = {velocity_x = 10,velocity_y = 100} }) end
        if input:pressed("despawn") then  Despawn(  room:getCurrentRoom():GetFirstEntityByID("sphere") or room:getCurrentRoom():GetFirstEntityByID("sphere2") or room:getCurrentRoom():GetFirstEntityByID("sphere3")  ) end --нужно добавить хранение объектов по типу, а не только по имени 
    end;
end

local FuncUpdateSaving = function()
    local loaderStatus, isBlockingSave = loader:Update(curRoom)
    local curRoom = room:getCurrentRoom()
    if loaderStatus == true then
        if curRoom.name ~= "saving" and isBlockingSave then 
            room:push("saving")
        end
    else
        local curRoom = room:getCurrentRoom() 
        if curRoom.name == "saving"  then -- покидаем сейв экран
            room:pop(false)
        end;
    end;
end;

local FuncUpdateRoom = function()
    local dt = love.timer.getDelta( )
    room:emit("update",dt)
end

ProjectCore.Update:Insert(FuncUpdateInput,"inputUpdate")
ProjectCore.Update:Insert(FuncUpdateSaving,"saveUpdate")
ProjectCore.Update:Insert(FuncUpdateRoom,"systemsUpdate")

SetEntityType = function(entity_name,params) --используется в hierarchy
    local room = ProjectCore.modules.roomManager
    local currentRoom = room:getCurrentRoom()
    local result = currentRoom.hierarchy.SetEntityType(entity_name,params)
    -- print("set entity type",entity_name,params)
    return result
end

-------setup draw pipeline

ProjectCore.Draw = Pipeline()
local FuncDrawRoom = function()
    room:emit("draw")
    loader:draw()
end;

ProjectCore.Draw:Insert(FuncDrawRoom,"draw")
------------------начало load
loader:Start()
loader:KillSaveFiles()
room.storage:Load()
room:enter("extra") --комната по-умолчанию
room:emit("load")