include("utils")
include("engineEvent")
include("loader")
include("ecs")

local libPath = (...):gsub('%.init$', '');

--local loader = ProjectCore.modules.dataLoader

local roomManager = {};
roomManager.current_room = nil;


roomManager.room    =  require(libPath ..".room"); 
roomManager.manager =  require(libPath ..".roomy").new();
roomManager.storage =  require(libPath ..".storage"); 


roomManager.enter = function (self,room_name)
  if false then
    print("Illegal Methtod, please use ':GoTo'") return
  end
 -- if loader.HasActiveSaveProcess() then print("try go to room before end saving")  return end;
  self.current_room = room_name
  
  --update ecs
  local room = self.manager:enter(roomManager.storage.room_list[room_name])
  

end;

roomManager.GoTo = function (self,room_name)
  if loader.HasActiveSaveProcess() then print("try go to room before end saving")  return end;
  self.current_room = room_name
  --print(room_name)
  local room = self.manager:GoTo(roomManager.storage.room_list[room_name])
  --local room = self.manager:enter(room.storage.room_list[room_name])
end;


roomManager.push = function (self,room_name)
  --self.current_room = room_name
  --print(room_name)
  --update ecs
 -- local room = self.manager:push(roomManager.storage.room_list[room_name])
  self.manager:push(roomManager.storage.room_list[room_name])

end;

roomManager.emit = function(self,event,...)
    self.manager:emit(event,...)
end;

roomManager.pop = function (self)
   -- local room = self.manager:pop()
  --self.current_room = room_name
  
  --update ecs
  
    self.manager:pop()

end;

roomManager.getCurrentRoomName = function(self)
  return roomManager.storage.room_list[roomManager.current_room].name
end;

roomManager.getCurrentRoom = function (self)
  --  error(roomManager.current_room)
 -- print(111,roomManager.current_room)
  return roomManager.storage.room_list[roomManager.current_room] 
end;

--roomManager.storage:Load()
return roomManager;
--add roomManager.info