local Interface = require 'libs/interface'

local Core = {}

local CoreEvent = {}

-------------------------module section
local Module = {}

function Module.new(_, ownerCore, name, path)
    local resultModule = {}
    local name = name
    resultModule.owner = ownerCore
    resultModule.name = name

    resultModule.source = require(path) -- source --require(path)

    local moduleCallable = getmetatable(resultModule.source) and
                               getmetatable(resultModule.source).__call or nil
    local moduleMtt = {
        -- __index =  resultModule.source

        __call = moduleCallable, -- если убрать , вызов модулей-функций ломается, почему?
        __index = resultModule.source
    }
    return setmetatable(resultModule, moduleMtt)
end

---------------------------------------

local function LoadModule(self, moduleName, curModulePath)
    local moduleOwner = self
    local _
    self.modules[moduleName] = self.modules[moduleName] or
                                   Module.new(_, moduleOwner, moduleName,
                                              curModulePath) -- require(curModulePath) -- если модуль ещё не загружен
end

function Core:LoadModules()
    local modulesPath = self.rootPath .. "modules"
    local files = love.filesystem.getDirectoryItems(modulesPath)

    for k, v in pairs(files) do
        local moduleName = v:cut(".lua")

        local curModulePath = modulesPath .. "/" .. moduleName
        local reqFilePath = curModulePath .. "/requirements.txt"
        local reqExists = love.filesystem.getInfo(reqFilePath)
        if reqExists then
            for line in love.filesystem.lines(reqFilePath) do
                LoadModule(self, line, modulesPath .. "/" .. line)
            end
        end

        LoadModule(self, moduleName, curModulePath)
    end
end

local function AddInterface(self, name)
    local result = Interface(self, name)
    self.interfaces[name] = result

    return result
end

local function RemoveInterface(self, name)
    local targetInterface = self.interfaces[name]
    Interface:Destroy(targetInterface)
end

local function ConnectInterface(self, inerfaceName, moduleName) end

local function DisconnectInterface(self, inerfaceName) end

local function IndexInterface(self, key)
    local result = self.interfaces[key] -- or self.modules[key]

    if result then
        return result
    else
        if self.parent then
            --   print(11)
            return self.parent:IndexInterface(key)
        else
            -- print(key,"(")
            return nil -- error(":(")
        end
    end
end

local function IndexModule(self, key)
    local result = self.modules[key]
    if result then
        return result
    else
        return nil
    end
end

local function Destroy(self)
    for name, v in pairs(self.interfaces) do
        RemoveInterface(self, name)
        --  Interfece.Destroy(v)
    end
end

function Core.new(_g, parent, path)
    local result = {}
    setmetatable(result, {})
    local mt = getmetatable(result)

    if parent then
        result.parent = parent
    else
        -- mt.__index = _G
    end

    result.rootPath = path or ""
    result.modules = {}
    result.interfaces = {}
    result.events = {}

    result.LoadModules = Core.LoadModules -- зугружать модули в прокти, чтобы нельзя было обращатсья к ним напрямую
    result.GetModulesList = nil -- должен возвращать просто список из названий модулей в прокси
    result.AddInterface = AddInterface
    result.RemoveInterface = RemoveInterface

    result.ConnectInterface = ConnectInterface
    result.DisconnectInterface = DisconnectInterface
    result.IndexInterface = IndexInterface
    result.IndexModule = IndexModule

    result.Destroy = Destroy

    -- set
    ------------------------------------------------------------------------------ подключение модулей
    -- print("load modules__________________")
    -- local modulesPath = result.rootPath.."/modules"
    -- local files = love.filesystem.getDirectoryItems(modulesPath)
    --
    -- for k,v in pairs(files) do
    --     local moduleName = v:cut(".lua")
    --     result.modules[moduleName] = require(modulesPath.."/"..moduleName)
    --     print(moduleName)
    -- end;

    -------------------------------------------------------------------------------

    return result
end

return setmetatable(Core, {__call = function(...) return Core.new(...) end})
