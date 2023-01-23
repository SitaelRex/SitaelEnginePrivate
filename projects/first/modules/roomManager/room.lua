--local roomManager = room -- _G.room
local room = {}

room.ecs = ecs
print(11,ecs)
--local utils = EngineCore.modules.utils

room.world = utils.DeepCopy(ecs.defaultWorld)
local libPath = (...):gsub('%.room$', '');
room.hierarchy = require(libPath ..".hierarchy")

room.SpawnEntity = function(self,object,params)  --ссылаться на общую функцию ? или ссылаться сюда извне?
    params = params or {}
    params.room = self
    local entity = self.ecs.entity(self.world):assemble(ecs.entity_storage[object],params)
end;

room.Deserialize = function(self,data) --hide
    self.world:deserialize(data)
end;
room.Serialize = function(self) --hide
    return self.world:serialize()
end;

room.TryLoadSave = function(self)
    local loader = ProjectCore.modules.dataLoader
     
    local savedData =  loader:TryLoadSave(self.name)--loader.LoadSavedData(next)
    if savedData then
        self:Deserialize(savedData)
    else
        self:SpawnObjects()
    end;
end;

room.StartSave = function( self, blocking )
     local loader = ProjectCore.modules.dataLoader
    local scripts = ProjectCore.modules.scripts
    local data = {}
    data.world = self:Serialize() --room_save
    data.variables = scripts.gameVar:GetStorageToSave()
    loader:StartSave(data.world ,self.name,blocking)
    loader:StartSave(data.variables,"common",blocking)
   -- loader:StartSave(data.world ,self.name,blocking)
end;



room.SpawnObjects = function(self)
    local objectsList = self.objects
    for index, objectTable in pairs(objectsList) do
        self:SpawnEntity(objectTable.object,objectTable.params)
    end;
    return true
end;

room.DespawnObjects = function(self)
    self.world:clear()
end;

room.new = function(self,path,name)
    local roomInstance = require( path .. "/" .. name );--просто загрузка данных
    local roomMt = { __index = room };
    roomInstance.name = name
    roomInstance = room.hierarchy:Setup(roomInstance)  
    --здесь должен создаваться ecs объект для комнаты
  --  utils.ExpandMetatable(roomInstance,roomMt)
   roomInstance.ecs = ecs
  roomInstance.world = room.world
  roomInstance.hierarchy = room.hierarchy
  roomInstance.SpawnEntity  =   room.SpawnEntity 
  roomInstance.Deserialize  =   room.Deserialize 
  roomInstance.Serialize    =   room.Serialize   
  roomInstance.TryLoadSave  =   room.TryLoadSave 
  roomInstance.StartSave    =   room.StartSave   
  roomInstance.DespawnObjects = room.DespawnObjects
  roomInstance.SpawnObjects = room.SpawnObjects
  --roomInstance. = room.
 -- roomInstance. = room.
--  roomInstance. = room.
    return roomInstance;
end;

return room;