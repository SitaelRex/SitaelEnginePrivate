local room = {}



function room:enter(previous, ...)

  --self:SpawnObjects()
	-- set up the level
end

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
 -- loader.SaveData(room)
  self:DespawnObjects()
	-- destroy entities and cleanup resources
end

room.scripts = {}
room.layers = layers.BuildList({[1] = "bottom",[2] = "upper"})
room.objects  = { --params.scriptable.script_path = "line"
    {object = "camera",params = {camera = { name = "first"},scriptable = { {script_path = "camera"}  } }  }, --нужно прописать некоторые объекты по-умолчанию
   -- {object = "camera",params = {camera = { name = "second"}, scriptable = {  {script_path = "camera"} ,{script_path = "elevator"}    } , position = {x = -300,y =-200} }  },
    --{object = "sphere",params = {hierarchy = { name = "player"}, position = {x = 100,y =100}, velocity = { velocity_y = 0,velocity_x =  0   },  scriptable = {  {script_path = "wrapToScreen"}  }  }  },
  --  {object = "sphere2",params = {hierarchy = { name = "unique"}, position = {x = 0,y =0}, velocity = { velocity_y = 100,velocity_x =  100  }  }  }
}

--utils.TestSpawnII(room.objects,500);
--utils.TestSpawn(room.objects,100);


return room;