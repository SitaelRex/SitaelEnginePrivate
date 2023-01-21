local libPath = (...):gsub('%.[^%.]+$', '');
local room    =  require(libPath ..".room"); 

--local pathManager = EngineCore.modules.pathManager
local scripts_folder = pathManager.GetProjectPath().."assets/scripts/"

local storage = {};
storage.defaultSearchPath =  pathManager.GetProjectPath().."assets/layouts";
storage.room_list = {};

storage.Load = function(self,path)
    storage.room_list = {};
  local path = path or storage.defaultSearchPath;
  local roomList = love.filesystem.getDirectoryItems(path);
  for _,val in pairs(roomList) do
    local room_name = val:cut(".lua");
    self.room_list[room_name]  = room:new(path,room_name)
   -- print()
    --self.room_list[key] = require(path.."/"..room_name);
  end;
end;
--storage:Load()
return storage;