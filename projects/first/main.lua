
ProjectCore.Update =  Pipeline() --IN GUI
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

-------setup draw pipeline
ProjectCore.Draw = Pipeline()

local FuncDrawRoom = function()
    room:emit("draw")
    loader:draw()
end;

--------------------------------------

ProjectCore.Update:Insert(FuncUpdateInput,"inputUpdate")
ProjectCore.Update:Insert(FuncUpdateSaving,"saveUpdate")
ProjectCore.Update:Insert(FuncUpdateRoom,"systemsUpdate")
ProjectCore.Draw:Insert(FuncDrawRoom,"draw")
------------------начало load
loader:Start()
--loader:KillSaveFiles()
room.storage:Load()
room:enter("extra") --комната по-умолчанию
room:emit("load")