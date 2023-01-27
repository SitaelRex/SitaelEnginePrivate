--local loader = ProjectCore.modules.dataLoader

include("loader")

--в скриптах нет подписки на ивенты
local scripts_storage = {}
local id_storage = 0 --используется для присвоения уникальных id  
local current_run = nil -- используется для получения данных о текущем выполняемом скрипте и вызывающем его объекте



--local pathManager = EngineCore.modules.pathManager
local scripts_folder = pathManager.GetProjectPath().."assets/scripts/"


local engineEvent = EngineCore.modules.engineEvent

local libPath = (...):gsub('%.init$', '');

local scripts = {}

local scriptsLoadStack = {} -- для единичного выполнения функции load
scripts.gameVar = require(libPath ..".gameVar"); 
scripts.builder = require(libPath ..".scriptBuild"); 

scripts.SetCurrentRun = function(self,e,script_idx)
    current_run = {
        currentEntity = e,
        scriptIdx = script_idx
    }
end;

scripts.GetCurrentRun = function(self)
    local result = current_run
    assert(result ~= nil,"not running script")
    return result 
end;

scripts.ResetCurrentRun = function(self)
    current_run = nil
end;


scripts.GetDefaultDummyScriptPath = function() 
    return "default"
end;

scripts.GetFullScriptPath = function(local_path)
    
    return scripts_folder..local_path
end;

scripts.GetScriptID = function(self)
    id_storage = id_storage + 1
    return id_storage
end;

scripts.ResetScriptID = function(self)
    id_storage = 0
    return id_storage
end;

scripts.AddToLoadStack = function(self,key) 
    scriptsLoadStack[key] = true
    scripts.gameVar.SetToPrivateStorage("LOADSTACK",scriptsLoadStack)
end;

scripts.InLoadStack = function(self,key) --проверяет
    return scriptsLoadStack[key]
end;

scripts.GetScript = function(self,scriptName)
    local result = scripts_storage[scriptName]
    assert(type(result) == "table", "script type is not a table!")
    return result
end;


scripts.Setup = function(self,entity)
    entity.scriptable.scripts_storage = self.UpdateStorage(entity)
    for script_index,script_table in pairs(entity.scriptable.scripts_storage) do
        local script_name = script_table.script_path
        --[[    ВЫПОЛНЯЕТСЯ ТОЛЬКО ПРИ ИНИЦИАЛИЗАЦИИ ПЕРВОЙ ССЫЛКИ НА СКРИПТ И ТОЛЬКО ОДИН РАЗ!!!!!!    ]]
        local script_name = script_table.script_fullpath
        local script =  self:GetScript(script_name) 
      --  print("try script setup")
        if script.script_load and not self:InLoadStack(script_name) then 
        --     print(script_name)
            script.script_load()
            self:AddToLoadStack(script_name)
        end;
    end;
end;


local script_prefix = "--Script \nlocal script = {}" --\n  local _ENV = script \n\n"
local script_postfix = " \n return script"

local GenerateScriptPrefix = function(script_fullpath)
    return "--"..script_fullpath.. "\nlocal script = {}"
end;


scripts.UpdateStorage = function(owner_entity)--script_fullpath)
    
    local function SetScriptID(script_table) 
        --уникальный числовой идентификатор ссылки на скрипт
        script_table.id  = script_table.id  or scripts.GetScriptID()
    end;

    local GetVariable = function(t,k)
        local result =  scripts.gameVar:GetValue(t,k) 
        return result
    end;
    
    local DeclareLocalVariable = function(t,k,v)
    end;
    
    local DeclareVariable = function(t,k,v) --разные пути.
        if type(v) ~= "function" then
           --- print("declare",t,k,v) 
            scripts.gameVar:DeclareGlobalVariable(t,k,v) 
        else
            rawset(t,k,v)
        end;
    end;
    
    
    local function SetScriptMetatable(script_full_path)
        local mt = { 
        __index = function(...) return GetVariable (...)   end ,
        __newindex = function(...) DeclareVariable (...) end
        }
        setmetatable(scripts_storage[script_full_path], mt)
    end;
    
    local function TryUpdateScriptStorage(script_fullpath) --при загрузке скрипта
        --внесение скрипта в общее хранилище скриптов, чтобы он имелся в памяти только в одном экземпляре
				local oldIdentity = love.filesystem.getIdentity()
				love.filesystem.setIdentity("Sitael",false)
        
        if not scripts_storage[script_fullpath] then
            scripts_storage[script_fullpath]  = {}
            local final_script_fullpath = script_fullpath..".lua"
            local info = love.filesystem.getInfo( final_script_fullpath )
            
            if not info then
                error("script '"..final_script_fullpath.."' not exist!\nowner type: "..owner_entity.obj_type,0)
            end;
            local f = love.filesystem.load( final_script_fullpath )--io.open(final_script_fullpath)
            local loaded_script = love.filesystem.read( "string", final_script_fullpath )--f:read('*a')
            local final_script = GenerateScriptPrefix(script_fullpath)..loaded_script..script_postfix
            scripts_storage[script_fullpath] = scripts.builder:CreateScript()
            SetScriptMetatable(script_fullpath)
            local script_init_func = loadstring(final_script)
            setfenv(script_init_func, scripts_storage[script_fullpath])
            script_init_func()
            
            
            local common_variables = loader:TryLoadCommon()
            scripts.gameVar.LoadSavedVariables(common_variables) 
           -- loader:LoadCommonSave()
        end; 
				
					love.filesystem.setIdentity(oldIdentity,false)
    end;
    
    
    
    --local entity_scripts_storage = {}
    for script_index,script_table in pairs(owner_entity.scriptable.scripts_storage) do
        SetScriptID(script_table)
        local script_full_path = script_table.script_fullpath
        
        TryUpdateScriptStorage(script_full_path)
        
        SetScriptMetatable(script_full_path)
        script_table.script =  script_full_path--scripts_storage[script_full_path]  !!!!!!
       -- print(2,script_table.script,script_table.script_load)
        owner_entity.scriptable.scripts_storage[script_index] = script_table
       -- owner_entity.scriptable[script_index].script = scripts_storage[script_full_path] 
    end;
		
	
		
    return owner_entity.scriptable.scripts_storage
end;

local LoadEndFunc = function()
    scriptsLoadStack = scripts.gameVar:GetFromPrivateStorage("LOADSTACK")  or {}
end;


engineEvent:SubscribeOnceEmited("OnLoadEnd", LoadEndFunc)



local function Setup()
   -- print("SETUP")
   -- scriptsLoadStack = scripts.gameVar:GetFromPrivateStorage("LOADSTACK")  or {}
    
		 
    return scripts;
end;

return Setup()