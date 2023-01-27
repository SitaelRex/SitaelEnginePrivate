---
-- @module Concord

local PATH = (...):gsub('%.init$', '')

local Concord = {
   _VERSION     = "3.0",
   _DESCRIPTION = "A feature-complete ECS library",
   _LICENCE     = [[
      MIT LICENSE

      Copyright (c) 2020 Justin van der Leij / Tjakka5

      Permission is hereby granted, free of charge, to any person obtaining a
      copy of this software and associated documentation files (the
      "Software"), to deal in the Software without restriction, including
      without limitation the rights to use, copy, modify, merge, publish,
      distribute, sublicense, and/or sell copies of the Software, and to
      permit persons to whom the Software is furnished to do so, subject to
      the following conditions:

      The above copyright notice and this permission notice shall be included
      in all copies or substantial portions of the Software.

      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
      OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
      MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
      IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
      CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
      TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
      SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
   ]]
}

Concord.entity     = require(PATH..".entity")
Concord.component  = require(PATH..".component")
Concord.components = require(PATH..".components")
Concord.system     = require(PATH..".system")
Concord.world      = require(PATH..".world")
Concord.utils      = require(PATH..".utils")

Concord.componentSetupStorage = {}
Concord.componentDestroyStorage = {}
Concord.entitySetupStorage = {}
Concord.entityDestroyStorage = {}


------------------------------------------------------------------------------------------------------------------------------------
--libs/concord/world/366 --использование хранилища добавить сюда функции --вынести это в отдельный конкорд модуль, или в concord.utils
Concord.OnEntitySetup = function(e)
  local entity_name = ( e.hierarchy and e.hierarchy.entity_type ) and e.hierarchy.entity_type or "unnamed_entity_type"
 -- print(entity_name)
  local onEntitySetupList = ecs.entitySetupStorage[entity_name] or {}
  
  for i = 1, #onEntitySetupList do
    onEntitySetupList[i](e)
  end;
  
  local components = e:getComponents()
  for d,_ in pairs(components) do
    ecs.componentSetupStorage[d] = ecs.componentSetupStorage[d] or {}
    for i = 1, #ecs.componentSetupStorage[d] do
      ecs.componentSetupStorage[d][i](e)
    end;
  end;
end;

Concord.OnEntityDestroy = function(e)
  local entity_name = e.hierarchy.entity_type or "unnamed_entity_type"
  local onEntityDestroyList = ecs.entityDestroyStorage[entity_name] or {}
  for i = 1, #onEntityDestroyList do
    onEntityDestroyList[i](e)
  end;
  
  local components = e:getComponents()
  for d,_ in pairs(components) do
    ecs.componentDestroyStorage[d] = ecs.componentDestroyStorage[d] or {}
    for i = 1, #ecs.componentDestroyStorage[d] do
      ecs.componentDestroyStorage[d][i](e)
    end;
  end;
end;

Concord.AddComponentSetupFunc = function(component_name,func )
  ecs.componentSetupStorage[component_name] = ecs.componentSetupStorage[component_name] or {}
  table.insert(ecs.componentSetupStorage[component_name], func)
end;

Concord.AddComponentDestroyFunc = function(component_name,func )
  ecs.componentDestroyStorage[component_name] = ecs.componentDestroyStorage[component_name] or {}
  table.insert(ecs.componentDestroyStorage[component_name], func)
end;

Concord.AddEntitySetupFunc = function(entity_name,func ) --для всех объектов 
  
 -- ecs.entitySetupStorage = ecs.entitySetupStorage or {}
  ecs.entitySetupStorage[entity_name] = ecs.entitySetupStorage[entity_name] or {}
  table.insert(ecs.entitySetupStorage[entity_name], func)
end;

Concord.AddEntityDestroyFunc = function(entity_name,func ) --для всех объектов
  --ecs.entityDestroyStorage = ecs.entityDestroyStorage or {}
  ecs.entityDestroyStorage[entity_name] = ecs.entityDestroyStorage[entity_name] or {}
  table.insert(ecs.entityDestroyStorage[entity_name], func)
end;
------------------------------------------------------------------------------------------------------------------------------------
Concord.GetSpriteType = function(e) --бардак
  return e.drawable.sprite_type;
end;

local ecs = require(PATH..".setup")(Concord)



return ecs;
