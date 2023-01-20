local room = {}

--local layers = ProjectCore.modules.layers
--local utils = EngineCore.modules.utils

function room:enter(previous, ...)

end

function room:load()
    self.world:emit("load")  --вытащить это барахло отсюда и заменить его на промежуточный слой делающий emit множества функций 
end

function room:update(dt)
    self.world:emit("update",dt)
end

function room:draw()
    self.world:emit("draw")
end


function room:leave(next, ...)
    room:StartSave(true)
   -- loader.SaveData(room)
    self:DespawnObjects()
end


room.layers = layers.BuildList({[1] = "bottom",[2] = "upper"})
room.objects  = { 
    {object = "camera",params = {camera = { name = "first"},scriptable = {} }  }, 
    {object = "camera",params = {camera = { name = "second"}, scriptable = {} , position = {x = -250,y =-300} }  },
    {object = "sphere",params = {hierarchy = { name = "a", parent = "b"}, position = {x = 0,y =0} ,scriptable = { {script_path = "elevator"}    }  }  },
    {object = "sphere2",params = {hierarchy = { name = "b", parent = "c"}, position = {x = 0,y =0} ,scriptable = { {script_path = "elevator"}    }  }  },
    {object = "sphere2",params = {hierarchy = { name = "c", parent = "d"}, position = {x = 0,y =0}, velocity = { velocity_x = 0  }  ,scriptable = { {script_path = "elevator"}    }  }  },
    {object = "sphere2",params = {hierarchy = { name = "d", parent = "e"}, position = {x = 0,y =0}  ,scriptable = { {script_path = "elevator"}    } }  },
    {object = "sphere2",params = {hierarchy = { name = "e", parent = "f"}, position = {x = 0,y =0} ,scriptable = { {script_path = "elevator"}    } }  },
    {object = "sphere2",params = {hierarchy = { name = "f"}, position = {x = 0,y =0} ,scriptable = { {script_path = "elevator"}    }  }  },
}

--

utils.TestSpawnII(room.objects,10);


--utils.TestSpawnII(room.objects,1000);
--utils.TestSpawnII(room.objects,5000);
return room;