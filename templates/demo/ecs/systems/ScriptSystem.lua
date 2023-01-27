--local input =  EngineCore.modules.input


local System = ecs.system({
    pool = {"scriptable"}
})
function System:load(on_room_enter)
    if not on_room_enter then return end
    for e in self.pool:SortedPool() do
        scripts:Setup(e)
    end
end;

function System:setupSystem(on_room_enter,...)
    --теперь это делается через scripts:Setup(e) вызываемый в создании компонента
    --self:load(on_room_enter,...)
end;

function System:update(dt)
   -- local scripts = ProjectCore.modules.scripts
   -- if true then return end
   -- for _,e in ipairs(self.pool)  do
    for e in self.pool:SortedPool()  do
        local scripts_storage = e.scriptable.scripts_storage
        for script_idx, script_table in pairs(scripts_storage) do --пробегаем по всем имеющимся скриптам
            scripts:SetCurrentRun(e,script_idx)
            local script_name = script_table.script_fullpath
            local script =  scripts:GetScript(script_name) 
            if script.update then
                
                
                script.update(dt,e, script_table.script.params)
                
            end;
            scripts:ResetCurrentRun()
        end;
        
    end;
end;

function System:draw()
  --  local scripts = ProjectCore.modules.scripts
    
  --   if input:released("test") and not  input:Blocked() then  print("______________")end
    for e in self.pool:SortedPool() do
        
       -- if input:released("test") and not  input:Blocked() then  print(e.hierarchy.level,e.hierarchy.object_name )end
        
        local scripts_storage = e.scriptable.scripts_storage
        for script_idx, script_table in pairs(scripts_storage) do --пробегаем по всем имеющимся скриптам
            scripts:SetCurrentRun(e,script_idx)
            local script_name = script_table.script_fullpath
            local script =  scripts:GetScript(script_name) 
            if script.draw then
                
                script.draw(dt,e, script_table.script.params)
                
            end;
            scripts:ResetCurrentRun()
        end;
        
        
        --if e.scriptable.script.draw then
        --e.scriptable.script.draw(e, e.scriptable.script.params)
        --end;
    end;
end;

return System