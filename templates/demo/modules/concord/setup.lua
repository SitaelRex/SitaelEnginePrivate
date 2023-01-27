
--local pathManager = EngineCore.modules.pathManager


local getEntityes = function(ecs_path,ecs_table)
  local indexed_entityes_list = love.filesystem.getDirectoryItems( ecs_path.."entityes" );
  local named_entityes_list = {};
  for idx,ent_name in pairs(indexed_entityes_list) do
    local entity_name = ent_name:cut(".lua");
    local entity_path = ecs_path.."entityes/"..entity_name;
    named_entityes_list[entity_name] = require(entity_path);
  end;
  return named_entityes_list;
end;

local getComponents = function(ecs_path,ecs_table)
  local components_list = love.filesystem.getDirectoryItems( ecs_path.."components" );
  for idx,comp_name in pairs(components_list) do
    components_list[idx] = require(ecs_path.."components/"..comp_name:cut(".lua"));
  end;
  return components_list;
end;

local getSystems = function(ecs_path,ecs_table)
  local systems_list = love.filesystem.getDirectoryItems( ecs_path.."systems" );
  for idx,sys_name in pairs(systems_list) do
    systems_list[idx] = require(ecs_path.."systems/"..sys_name:cut(".lua"));
  end;
  return systems_list;
end;

local setup = {};
--local ecs_table = nil
setup.Start = function(parent,path)
    --local path =
  local ecs_default_path = pathManager.GetProjectPath().."ecs/";
  local ecs_path = path or ecs_default_path;
  local ecs_table = parent;
  ecs = ecs_table
  local result = parent
  result.entity_storage = getEntityes(ecs_path,ecs_table)
  result.component_storage = getComponents(ecs_path,ecs_table)
  result.system_storage = getSystems(ecs_path,ecs_table)
  result.defaultWorld = ecs_table.world();
  result.defaultWorld:addSystems(unpack(result.system_storage))
  
  return result;
end;
return setup.Start