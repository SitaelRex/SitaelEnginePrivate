--TODO свойства слоя (параллакс и т.д)
include("utils")
local layers_default = {[999999] = "front_layer"}
local front_layer = "front_layer"
local layers = {}

--local utils = EngineCore.modules.utils

function layers.GetFrontLayer() 
  return front_layer
end;

function layers.Draw(self)
  for layer_name, layer in pairs(self.draw_queue) do
    for z_index, z_index_pool in pairs(layer) do
      for _, func in pairs(z_index_pool) do --здесь нужно группировать объекты по типу 
        func()
      end;
      
    end;
  end;
  self:clearQueue()
end;

--function layers.GetLayerIndexByName(self,name)
--  for key,layer_name in pairs(self.layers_list) do
--  end;
--  
--end;



function layers.clearQueue(self)
  self.draw_queue = {}
end;
function layers.pushQueue(self,e,render) 
  local queue_layer_index = self.named_layers_list[e.drawable.layer]
  
  --print(queue_layer_index)
  if not self.draw_queue[queue_layer_index]  then
    self.draw_queue[queue_layer_index] = {}
    
  end;
  if not self.draw_queue[queue_layer_index][e.drawable.z_index] then

      self.draw_queue[queue_layer_index][e.drawable.z_index] = {}
  end;
  
  table.insert(self.draw_queue[queue_layer_index][e.drawable.z_index],render)  --здесь нужно группировать объекты по типу 
  --sorted_draw_queue[e.drawable.layer][e.drawable.layer] = 1
end;

function layers.BuildList(layers_list)
  local result = {}
  result.layers_list = utils.DeepCopy(layers_default)
  for key,layer_name in pairs(layers_list) do
    result.layers_list[key] = layer_name
  end;
  result.named_layers_list = utils.InverseIndexing( result.layers_list)
  result.draw_queue = {}
  result.Draw = layers.Draw
  result.pushQueue = layers.pushQueue
  result.clearQueue = layers.clearQueue
  result.GetLayerIndexByName = layers.GetLayerIndexByName
  return result
end;

return layers