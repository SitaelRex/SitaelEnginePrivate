local component_name = "scriptable"
local inheritanceMode = "ignore"


--error(scripts)
 
local component = ecs.component(component_name, function(c, params,e)
        
 --local scripts = ProjectCore.modules.scripts
 
    local params = params[component_name] or {}
    c.scripts_storage = {} --params
   -- с:Serializable().scripts_storage = {}
   --Serializable function return {}    mt = {__index  = function() set to serializable global end}
   
    for i = 1, #params do
        c.scripts_storage[i] = {}
        c.scripts_storage[i].script_path =  params[i].script_path or scripts.GetDefaultDummyScriptPath()
        c.scripts_storage[i].script_fullpath = scripts.GetFullScriptPath(c.scripts_storage[i].script_path)
        c.scripts_storage[i].setup_completed = true
        c.scripts_storage[i]._local = {}
    end;
end,inheritanceMode)

ecs.AddComponentSetupFunc(component_name,function(e)  scripts:Setup(e) end )
return component