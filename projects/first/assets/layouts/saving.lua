local room = {}



--local 

function room:enter(previous, ...)

 -- self:SpawnObjects()
	-- set up the level
end

function room:load()
  --self.world:emit("load")
end

function room:update(dt)
  --self.world:emit("update",dt)
end

function room:draw()
  love.graphics.setFont(room.font)
  love.graphics.print("saving...",350,250)
  love.graphics.setFont(room.fontd)
  --local sorted_draw_queue = 
  --self.world:emit("draw")
  --room.layers:Draw(sorted_draw_queue)
end

function room:leave(next, ...)
   -- print(11)
  --  ZAWARUDO()
  --self:DespawnObjects()
	-- destroy entities and cleanup resources
end

room.font = love.graphics.newFont(pathManager.GetProjectPath().."assets/fonts/Gouranga-Pixel.ttf",40)
room.fontd = love.graphics.newFont()

--room.scripts = {}
--room.layers = layers.BuildList({[1] = "bottom",[2] = "upper"})
--room.objects  = { --params.scriptable.script_path = "line"
--  {object = "camera",params = {camera = { name = "first"},scriptable = { script_path = "camera" } }  }, --нужно прописать некоторые объекты по-умолчанию
--  {object = "camera",params = {camera = { name = "second"}, scriptable = { script_path = "camera" } , position = {x = 400,y =200} }  }
--}
--
--utils.TestSpawnII(room.objects,1);
--utils.TestSpawn(room.objects,100);


return room;