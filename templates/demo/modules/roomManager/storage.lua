local libPath = (...):gsub('%.[^%.]+$', '');
local room    =  require(libPath ..".room"); 

--local pathManager = EngineCore.modules.pathManager
local scripts_folder = pathManager.GetProjectPath().."assets/scripts/"

local storage = {};
storage.defaultSearchPath =  pathManager.GetProjectPath() .."assets/layouts";

storage.room_list = {};

storage.Load = function(self,path)
  storage.room_list = {};
  local path =storage.defaultSearchPath
	local oldIdentity = love.filesystem.getIdentity()
	love.filesystem.setIdentity("Sitael",false)
	--print(path)
	-- path or storage.defaultSearchPath;
	--print(111222,storage.defaultSearchPath)
	--local existInfo = love.filesystem.getInfo(storage.defaultSearchPath)
	--
	--print(1212,existInfo)
	--for k,v in pairs(existInfo) do
	--	print(")))",k,v)
	--end

  local roomList = love.filesystem.getDirectoryItems(path);

  for _,val in pairs(roomList) do
    local room_name = val:cut(".lua");
		print(13, room_name)
    self.room_list[room_name]  = room:new(path,room_name)
		
   -- print()
    --self.room_list[key] = require(path.."/"..room_name);
  end;
	
	love.filesystem.setIdentity(oldIdentity,false)
end;
--storage:Load()
return storage;