require "imgui"
imgui.SetReturnValueLast(false)
local font = imgui.AddFontFromFileTTF("resources/unifont.ttf",16,nil,ranges)
local openManager = false
local openProjectsCreator = false
local openProjectNaming = false
local function SetFileManagerOpen(status)
    openManager = status
end
local function SetProjectCreatorOpen(status)
    openProjectsCreator = status
end;
local function SetProjectNamingOpen(status)
    openProjectNaming = status
end;
local function LinkCore(Core) -- генерирует интерфейсы и их связи из linkConfig.txt
    local projectPath = pathManager.GetProjectPath() --хрнаить путь к проекту в ядре
    local linkConfigPath = projectPath.."linkConfig.txt"
    local interfacesConnect = {}
    local function isComment(line)
        local startLine = line:sub(0,2)
        return startLine == "--"
    end;
    local function CreateInterface(line)
        local interfaceName = line:sub(0, line:find("{")-1 )
        interfacesConnect[interfaceName] =   Core:AddInterface(interfaceName)
    end;
    local function ConfigInterface(line)
        --создание заглушечных функций интерфейсов внутри скобок
    end;
    local function LinkModule(line)
        local interfaceName = line:sub(0, line:find("{")-1 )
        local moduleName = line:sub(line:find("}")+1,-2 ) -- -2 because line has "." in the end
        Interface.Connect(interfacesConnect[interfaceName],Core:IndexModule(moduleName))
    end;
    for line in love.filesystem.lines(linkConfigPath) do
        if not isComment(line) then
            CreateInterface(line)
            LinkModule(line)
        end
    end
    interfacesConnect = nil
end;
local function OpenProject(projectName)
    pathManager.SetProject(projectName)
    local fullPath = pathManager.GetProjectPath()
    local setupPath = fullPath.."main.lua"
    local  chunk, errormsg = love.filesystem.load( setupPath )
    if not errormsg then
        ProjectCore = nil
        ProjectCore = Core(EngineCore,EngineCore.modules.pathManager.GetProjectPath()) 
        setmetatable(_G, {__index = function(_,key)  return ProjectCore:IndexInterface(key) end })
        ProjectCore:LoadModules() 
        LinkCore(ProjectCore)
        setmetatable(_G, {
            __index = function(_,key) 
            local sourceInfo =  debug.getinfo(2,"S").source 
            local sourceModule,a = sourceInfo:find("modules/") 
            if not sourceModule  then  
                return ProjectCore:IndexInterface(key) --указываем самое высокоуровневое ядро, через которое будет начинаться поиск
            else 
                local sourceInfo = sourceInfo:sub(a+1) 
                sourceInfo = sourceInfo:sub(0,sourceInfo:find("/")-1 ) 
                if sourceInfo == key or ( included[sourceInfo] and included[sourceInfo][key]  ) then
                    return ProjectCore:IndexInterface(key) 
                end;
            end 
        end 
        }) 
        chunk() -- содержимое main файла проекта
    else
        error(errormsg)
    end
end
local aa = true
local sdw = false -- showDemoWindow
local function RecursiveCopy(templatePath,path,projectType)
    local templateFiles = love.filesystem.getDirectoryItems(templatePath)
    for _,name in pairs(templateFiles) do
        local filename = templatePath.."/"..name
        local info = love.filesystem.getInfo(filename)
        if info then
            if info.type == "file" then
                love.filesystem.write(path.."/"..name,love.filesystem.read(templatePath.."/"..name))
            elseif  info.type == "directory" then
                love.filesystem.createDirectory(path.."/"..name)
                RecursiveCopy(templatePath.."/"..name,path.."/"..name,projectType)
            end
        end;
        print(projectType,_,name)
    end;
end;
local function CreateProject(projectName,projectType)
    local oldIdentity = love.filesystem.getIdentity()
    love.filesystem.setIdentity("Sitael",false)
    local path = "projects/"..projectName
    local templatePath = "templates/"..projectType
    local succes = love.filesystem.createDirectory(path)
    RecursiveCopy(templatePath,path,projectType)
    OpenProject(projectName)
    love.filesystem.setIdentity(oldIdentity,false)
end;
local str = ""
local function OpenProjectNaming(projectType)
    if openProjectNaming then
        imgui.OpenPopup("ProjectNaming")
        if  imgui.BeginPopupModal("ProjectNaming",nil,{ "ImGuiWindowFlags_NoResize"})  then
            local _, textboxText =  imgui.InputText("project name", "",255)
            str = #textboxText > 0 and textboxText or  str
            imgui.Separator();
            if imgui.Button("cancel",80,0) then openProjectNaming = false; imgui.CloseCurrentPopup()  end
            imgui.SameLine()
            if imgui.Button("open",80,0) then openProjectNaming = false; openProjectsCreator = fasle ; imgui.CloseCurrentPopup() ; CreateProject(str,projectType) end
            imgui.EndPopup();
            imgui.SetWindowSize("ProjectNaming",200,200)
        end;
    end
end
local templates = love.filesystem.getDirectoryItems("templates") --перенести папку в appData --{"empty", "demo", "2DPlatformer", "AAA", "JRPG", "TurnBased", "RTS", "Clicker"} -- directory items from /templates
local selected = ""
local function OpenProjectCreator()
    if openProjectsCreator then
        imgui.OpenPopup("ProjectCreate")
        local open, close = imgui.BeginPopupModal("ProjectCreate",nil,{ "ImGuiWindowFlags_NoResize"})
        if  open and not close then
            for i = 1, #templates do
                local templateName = templates[i]
                local buttonCheck = imgui.Button(templateName, 200,200)
                if buttonCheck or openProjectNaming then
                    if buttonCheck then
                         selected = templateName
                    end
                    SetProjectNamingOpen(true)
                end
                if i ~= 3 and i ~= 6 and i ~= 9 and i ~= #templates then
                    imgui.SameLine()
                end
            end;
            OpenProjectNaming(selected)
            imgui.SetWindowSize("ProjectCreate",700,600)
            imgui.Separator()
            if imgui.Button("cancel") then
                openProjectsCreator = false; imgui.CloseCurrentPopup(); selected = ""
            end
            imgui.EndPopup();
        end
    end;
end;
local pselect = pselect or {}
local selected = 1
local function OpenFileManger()
    if openManager then
        local oldIdentity = love.filesystem.getIdentity()
        love.filesystem.setIdentity("Sitael",false)
        imgui.OpenPopup("ProjectSelect")
        if imgui.BeginPopupModal("ProjectSelect",nil,{ "ImGuiWindowFlags_NoResize", "ImGuiWindowFlags_NoClose"}) then
            imgui.Text("выбери проект")
            imgui.Separator();
            local projectsList =love.filesystem.getDirectoryItems( "projects" ) --"projects" 
            local _
            _,selected = imgui.ListBox("",selected,projectsList,#projectsList,4)--,1,love.filesystem.getDirectoryItems( "projects" ),3)
            imgui.Separator();
            if imgui.Button("cancel",80,0) then openManager = false; imgui.CloseCurrentPopup() end
            imgui.SameLine()
            if imgui.Button("open",80,0) then openManager = false; imgui.CloseCurrentPopup(); OpenProject(projectsList[selected]) end
            imgui.EndPopup();
            imgui.SetWindowSize("ProjectSelect",200,200)
        end
        love.filesystem.setIdentity(oldIdentity,false)
    end
end;
canvas = love.graphics.newCanvas(800, 600)
local docks = {
        {name = "Hierarchy", dock = "ImGuiDockSlot_Right", view = true},
        {name = "FileManager", dock = "ImGuiDockSlot_Right" , view = true},
        {name = "Viewport", dock = "ImGuiDockSlot_Top", view = true},
        {name = "Inspector", dock = "ImGuiDockSlot_Right", view = true},
    }
local function draw()
    imgui.NewFrame()
    
    if imgui.BeginMainMenuBar() then
        if imgui.BeginMenu("Engine") then
            imgui.EndMenu()
        end
        if imgui.BeginMenu("Project") then
            if imgui.MenuItem("New") then
                SetProjectCreatorOpen(true)
            end
            if imgui.MenuItem("Open") then
                SetFileManagerOpen(true)
            end;
            if imgui.MenuItem("Close", nil,false,true) then --label,  shortcut, bool selected, bool enabled
               ProjectCore = Core(EngineCore,EngineCore.modules.pathManager.projectPath) --доступ к project core
            end;
            imgui.EndMenu()
        end
        if imgui.BeginMenu("Settings") then
            imgui.EndMenu()
        end;
        if imgui.BeginMenu("View") then
            for k,v in pairs(docks) do
                if imgui.MenuItem(v.name) then
                     v.view = not v.view
                end;
                imgui.SameLine() 
                imgui.Checkbox("", v.view) 
            end;
            imgui.EndMenu()
        end;
        if imgui.Checkbox("Show Demo",sdw) then
            sdw = not sdw
        end;
        imgui.EndMainMenuBar()
    end
    
    ---------------------------------
 --   InterfaceUnit(UI.Source,imgui.BeginMainMenuBar,{}, function(self)  childs:Do(); imgui.EndMainMenuBar() end)
    
    --------------------------------
    OpenFileManger()
    OpenProjectCreator()
    if sdw then
        showTestWindow = imgui.ShowDemoWindow(false)
    end
    IMAGE = canvas
    imgui.SetNextWindowPos(0, 10)
    imgui.SetNextWindowSize(love.graphics.getWidth(), love.graphics.getHeight()-10)
    if imgui.Begin("DockArea", nil, { "ImGuiWindowFlags_NoTitleBar", "ImGuiWindowFlags_NoResize", "ImGuiWindowFlags_NoMove", "ImGuiWindowFlags_NoBringToFrontOnFocus" }) then
        imgui.BeginDockspace()
        for k,v in pairs (docks) do
            if v.view then
                imgui.SetNextDock(v.dock);
                if imgui.BeginDock(v.name,true) then
                    if v.name == "Viewport" then
                        imgui.Image(IMAGE, 800, 600)
                    end
                end
                imgui.EndDock()
            end
        end
        imgui.EndDockspace()
    end
    imgui.End()
    imgui.Render();
end
-----------------------------------------------------------------------------------------------------------
local UI = {}
-----------------------------------------------------------------------------------------------------------
local interfaceUnitTags = {}

local InterfaceUnit = {}

InterfaceUnit.new = function(parent, interfaceFunc, funcArgs, funcBody, interfaceTag) -- parent, imgui.something, args, function
   -- print(...)
    local result = {}
    result.prev = parent or nil
    result.pool = {} -- pool of 'next' units
    
    result.interfaceFunc = interfaceFunc
    result.funcArgs = funcArgs or {}
    result.funcBody = funcBody or function() end;
    result.interfaceTag = interfaceTag
    
    local parentUnit = result.prev
    if parentUnit then
        parentUnit.pool[result] = result
    end
    
    if interfaceTag then -- insert in tags storage
        if not  interfaceUnitTags[interfaceTag] then
            interfaceUnitTags[interfaceTag] = {}
        end
        interfaceUnitTags[interfaceTag][result] = true
    end
    
    local resultMT = {__index = InterfaceUnit, mode = "k"}
    
    setmetatable(result, resultMT)
    
    return result
end;

InterfaceUnit.destroy = function(unit)
    local parentUnit = unit.prev
    if parentUnit then --destroy childs
        for key,childUnit in pairs(unit.pool) do
          --  print(childUnit,"destroy")
            childUnit:destroy()
        end;
        parentUnit.pool[unit] = nil
    end;
    
    local interfaceTag = unit.interfaceTag
    if interfaceTag then
        interfaceUnitTags[interfaceTag][unit] = nil
    end
    
    unit = nil;
end;

local function emptyUnit()
    return true
end;


InterfaceUnit.ChildsDo = function(self)
    print(1)
    for key,childUnit in pairs(self.pool) do
       -- childUnit:Do()
    end;
end;

InterfaceUnit.Do = function(self)
    local interfaceFunc = self.interfaceFunc or emptyUnit
    local funcArgs = self.funcArgs
    local funcBody = self.funcBody
    
    local isEmited,changed = interfaceFunc(unpack(funcArgs))
    
    if isEmited then
        funcBody(self)
        
       -- for key,childUnit in pairs(self.pool) do
       --      childUnit:Do()
       -- end;
    end
end;

InterfaceUnit.log = function(self)
    local function printUnit(unit,level)
        print(string.rep("\t",level),unit)
        for key,unit in pairs(unit.pool) do
            printUnit(unit,level+1)
        end;
    end;
    printUnit(self,0)
end


local InterfaceUnitMT = {__call = function(self,...) return InterfaceUnit.new(...) end}

setmetatable(InterfaceUnit, InterfaceUnitMT)
-----------------------------------------------------------------------------------------------------------
UI.Source = InterfaceUnit()
--a = InterfaceUnit(
--    UI.Source,
--    imgui.Begin,
--    {"DockArea", nil, { "ImGuiWindowFlags_NoTitleBar", "ImGuiWindowFlags_NoResize", "ImGuiWindowFlags_NoMove", "ImGuiWindowFlags_NoBringToFrontOnFocus" }},
--    function(self)
--        imgui.BeginDockspace()
--       -- self:ChildsDo()
--        --for k,v in pairs (docks) do
--        --    if v.view then
--        --        imgui.SetNextDock(v.dock);
--        --        if imgui.BeginDock(v.name,true) then
--        --            if v.name == "Viewport" then
--        --          --      imgui.Image(IMAGE, 800, 600)
--        --            end
--        --            imgui.EndDock()
--        --        end
--        --      
--        --    end
--        --end
--        imgui.EndDockspace()
--    end
--)
--b = InterfaceUnit(
--    UI.Source,
--    imgui.BeginDock,
--    {"aa"},
--    function(self)
--        print(11)
--        imgui.EndDock()
--    end
--)
----b = InterfaceUnit(UI.Source)
--c = InterfaceUnit(a)
--d = InterfaceUnit(a)
--e = InterfaceUnit(c)
--
--a:destroy(a)

UI.Source:log()

UI.Draw = function()
   -- imgui.NewFrame()
   -- 
   -- --imgui.SetNextWindowPos(0, 10)
   -- --imgui.SetNextWindowSize(love.graphics.getWidth(), love.graphics.getHeight()-10)
   -- 
   -- UI.Source:Do()
   -- 
   -- imgui.End()
   -- imgui.Render();
    draw()
end;

return UI