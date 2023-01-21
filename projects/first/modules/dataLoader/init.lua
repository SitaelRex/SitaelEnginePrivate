--[[
V 1. позволить составлять очередь из сохранений. 
    V 1.1 представлять процесс сохранения как отдельный объект
    V 1.2 проверять , чтобы нельзя было добавить в очередь одну и ту же комнату несколько раз
V 2. сохранять common данные логически отдельно от комнаты
3. получать пути сохранения из модуля pathManager
4. вынести всю систему в другой поток--выполнять сохранение в другом потоке


интерфейс : TryLoad(), StartSave(),KillSaveFiles() : ,GetActiveSaveProcess() <-[GetSaveProgress,GetSaveMode]
]]
--local engineEvent = EngineCore.modules.engineEvent

include("engineEvent")
include("utils")

local libPath = (...):gsub('%.init$', '');
local persistence   = require (libPath..'.persistence' );
local saveQueue     = require (libPath..'.saveQueue' )();
local projectName = "project" --call from project manager . имя целевого проекта
local loader = {};
local saveMode = {blocking = "blocking",process = "process", notSave = "notSave"} -- что-то типа перечисления с возможными состояниями
local SaveResume --private methods

SaveResume = function()
    local save_mode = loader.GetSaveMode() 
    assert(save_mode ~= saveMode.notSave, "WTF, loader.SaveResume if not_save???")
    
    saveQueue:Continue()
end;

loader.Start = function(self) --нужно разобраться как менять целевой проект
    love.filesystem.setIdentity(projectName)
end;

loader.TryLoadCommon = function(self) --попробовать оъединить в одну функцию  TryLoadCommon TryLoadSave
    -- пытается вернуть common переменные
    return  persistence.load("save/room_common_save.lua") or {}
end;

loader.TryLoadSave = function(self,roomName) 
    -- пытается вернуть сейв комнаты
    if not loader.HasActiveSaveProcess() then
        local data,e = persistence.load("save/room_"..roomName.."_save.lua") --AppData
        local has_correct_saved_data = type(data) == "table"
        if has_correct_saved_data then 
            engineEvent:EmitOnce("OnLoadEnd")
            return data--true
        else
            return false
        end
    end
end;

loader.GetSaveProgress = function()
    if loader:HasActiveSaveProcess() then
        return saveQueue:GetCurrentProcess().progress
    else
        return 0
    end;
end

loader.GetSaveMode = function(self) --инфа
    --предоставляет информацию о текущем статусе сохранения
    if loader:HasActiveSaveProcess() then
        return  saveQueue:GetCurrentProcess().mode
    else
        return saveMode.notSave
    end;
end;

local function recursivelyDelete( item ) --вылет, если находишься в удаляемой папке во время удаления
    if love.filesystem.getInfo( item , "directory" ) then
        for _, child in ipairs( love.filesystem.getDirectoryItems( item )) do
            recursivelyDelete( item .. '/' .. child )
            love.filesystem.remove( item .. '/' .. child )
        end
    elseif love.filesystem.getInfo( item ) then
        love.filesystem.remove( item )
    end
    love.filesystem.remove( item )
end

loader.KillSaveFiles = function(self,...)
    local argList = {...}
    local targetList
    
    if #argList == 0 then --DeleteAll
        targetList = love.filesystem.getDirectoryItems("save/")
    else --DeleteFilesFromList
        targetList = argList
    end;
    
    for key,filename in pairs(targetList) do
        recursivelyDelete( "save/"..filename )
      --  love.filesystem.remove( "save/"..filename )
    end;
    print("save killed!")
end;

loader.StartSave = function(self,data,roomName,blocking)
    local mode = blocking and saveMode.blocking or saveMode.process
    local save_path = "save/room_"..roomName.."_save.lua" -- in AppData
    saveQueue:Insert(data,save_path,mode) 
    SaveResume()
end

loader.HasActiveSaveProcess = function()
    return saveQueue.list.size > 0 and true or false
end;

loader.Update = function(self,curRoom)
    local loaderStatus
    local isBlockingSave 
    if self:HasActiveSaveProcess()  then 
        SaveResume()
        loaderStatus = true
        isBlockingSave = loader.GetSaveMode() == saveMode.blocking
        return loaderStatus,isBlockingSave
    else
        engineEvent:EmitOnce("OnSaveEnd")
        loaderStatus = false
        return loaderStatus
    end;
end;

------------------------------------------------------------------------------------------------------------------- UI
local config = {
  icon_outer_radius = 40,
  icon_line_width = 8,
}
config.icon_inner_max_radius = config.icon_outer_radius-config.icon_line_width/2

--loader.Draw = function() --save/load icon
--    if loader.HasActiveSaveProcess() then
--        love.graphics.setLineWidth(config.icon_line_width)
--        love.graphics.circle("line",750,550,config.icon_outer_radius)
--        love.graphics.setLineWidth(1)
--        love.graphics.circle("fill",750,550,config.icon_inner_max_radius/100 * (100 - loader.GetSaveProgress () ) )
--    end;
--    
--    love.graphics.print("SaveProcessQueueLen: "..saveQueue.list.size, 0,100)
--end;

return loader;