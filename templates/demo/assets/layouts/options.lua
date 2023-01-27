local room = {}



function room:load()
  self.world:emit("load")
end

function room:update(dt)
  self.world:emit("update",dt)
end

function room:draw()
  --local sorted_draw_queue = 
  self.world:emit("draw")
  --room.layers:Draw(sorted_draw_queue)
end

function room:leave(next, ...)
  room:StartSave(true)
  self:DespawnObjects()
	-- destroy entities and cleanup resources
end

room.scripts = {}
room.layers = layers.BuildList({[1] = "bottom",[2] = "upper"})
room.objects  = { --params.scriptable.script_path = "line"
  {object = "camera",params = {camera = { name = "first"},scriptable = { script_path = "camera" } }  }, --нужно прописать некоторые объекты по-умолчанию
  {object = "camera",params = {camera = { name = "second"}, scriptable = { script_path = "camera" } , position = {x = 400,y =200} }  },
  {object = "sphere",params = {hierarchy = { name = "player"}, position = {x = 0,y =0}, velocity = { velocity_y = 1000,velocity_x =  100  } ,scriptable = { {script_path = "elevator"}    } }  }
}

utils.TestSpawnII(room.objects,500);
--utils.TestSpawn(room.objects,100);


return room;