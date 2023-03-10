require "imgui"
imgui.SetReturnValueLast(false)
------------------------------imgui stuff
--
--local showTestWindow = false
--local showAnotherWindow = false
--local floatValue = 0;
--local sliderFloat = { 0.1, 0.5 }
--local clearColor = { 0.2, 0.2, 0.2 }
--local comboSelection = 1
--local textValue = "text"
----------------------------
---------------------------------------------------------------Global Engine Utils
function string:cut(reference) --сокращенный вырезатель gsub
    return self:gsub(reference, "")
end;

included = {}

function include(mod) -- для связи между модулями
    local _,name = debug.getlocal(4,3)
    print("module ",name," include inreface ",mod)
    included[name] = included[name] or {}
    included[name][mod] = true
    
end;

Core = require 'libs/core'
Interface = require 'libs/interface'
--pathManager = require 'modules/pathManager' -- нельзя вынести в интерфейс, потому что важен порядок инициализации. 
-- room.storage(как и прочие модули) нуждаются в path manager-e
--engineEvent =  require 'modules/engineEvent'

------------------------------------------------MAIN
function love.load()
   --  local joysticks = love.joystick.getJoysticks()
   -- joystick = joysticks[1]
    --joystick:setVibration(1, 1 )
    EngineCore = Core() -- создаем ядро движка
    
    local ee =      EngineCore:AddInterface("engineEvent") --создаем интерфейсы движка
    local pm =      EngineCore:AddInterface("pathManager")
    local u  =      EngineCore:AddInterface("utils")
    local li  =     EngineCore:AddInterface("List")
    local con =      EngineCore:AddInterface("console")
    EngineCore:LoadModules() --загружаем модули
    
    
      
    Interface.Connect(pm,EngineCore:IndexModule("pathManager")) -- подключаем модули движка к интерфейсам движка
    Interface.Connect(ee,EngineCore:IndexModule("engineEvent"))
    
    Interface.Connect(li ,EngineCore:IndexModule("List"))

    Interface.Connect(u ,EngineCore:IndexModule("utils"))
    Interface.Connect(con ,EngineCore:IndexModule("console"))
   -- Interface.AddMethod(r,"getCurrentRoom", function() print(42) return "options" end) --приоритет ниже чем у вызова через прокси
   -- Interface.AddMethod(r,"enter", function() print(1)  end) 
   --[[ интерфейсы существуют для двух целей
    1. дать возможность легко задизайнить систему в целом, и отслеживать взаимосвязи
    2. гарантировать, что при коннекте модуль точно соответсвует требования интерфейса (интерфейс должен проверять наличие в модуле всего, что имеется в интерфейсе)
   ]]

   
    ProjectCore = Core() -- создаем  ядро проекта (должно подгружаться из проекта)
-----    
-----    setmetatable(_G, {__index = function(_,key)  return ProjectCore:IndexInterface(key) end }) -- настраиваем индекс, чтобы модули проекта могли обращатсья к модулям движка во время require (правильно ли это?)
-----   -- print("utils",utils)
-----    
-----    ProjectCore:LoadModules() 
-----  --   print("utils",utils)
-----    --  print(pathManager)
-----    local r =   ProjectCore:AddInterface("room")
-----    local i =   ProjectCore:AddInterface("input")
-----    local l =   ProjectCore:AddInterface("loader")
-----    local s =   ProjectCore:AddInterface("scripts")
-----    local la =  ProjectCore:AddInterface("layers")
-----    local ca =  ProjectCore:AddInterface("camera")
-----    
-----    Interface.Connect(la,ProjectCore:IndexModule("layers"))
-----    Interface.Connect(r,ProjectCore:IndexModule("roomManager"))
-----    Interface.Connect(i,ProjectCore:IndexModule("input"))
-----    Interface.Connect(l,ProjectCore:IndexModule("dataLoader"))
-----    Interface.Connect(s,ProjectCore:IndexModule("scripts"))
-----    Interface.Connect(ca,ProjectCore:IndexModule("camera"))
-----    
-----    setmetatable(_G, {__index = function(_,key) 
-----        local sourceInfo =  debug.getinfo(2,"S").source 
-----        local sourceModule,a = sourceInfo:find("modules/") 
-----        if not sourceModule  then  
-----           -- if 
-----            return ProjectCore:IndexInterface(key) --указываем самое высокоуровневое ядро, через которое будет начинаться поиск
-----        else 
-----            local sourceInfo = sourceInfo:sub(a+1) 
-----            sourceInfo = sourceInfo:sub(0,sourceInfo:find("/")-1 ) 
-----            if sourceInfo == key or ( included[sourceInfo] and included[sourceInfo][key]  ) then
-----                return ProjectCore:IndexInterface(key) 
-----            end;
-----          --  print(sourceInfo)
-----        end 
-----    end 
-----    }) 
-----   -- setmetatable(_G,{index = function(...) print(...,_G) end})
-----    -- можно сделать хранилище ядер
-----    -- при создании ядра хранить его в определнном слое таблицы с ядрами
-----    -- если про создании ядра фигурирует parent - слой ядра = слой родителя + 1
-----    -- при поиске двигаемся перебором с самого верхнего уровня, до самого нижнего
-----    
----- 
-----    ------setup update pipeline
    Pipeline = EngineCore.modules.Pipeline

-----    ProjectCore.Update =  Pipeline()
-----    
-----    local FuncUpdateInput = function()
-----        local curRoom = room:getCurrentRoom()
-----        input:update()
-----        if not input:Blocked() then
-----            if input:pressed("room1") then room:GoTo("extra")end
-----            if input:pressed("room2") then room:GoTo("main_menu") end
-----            if input:pressed("room3") then room:GoTo("options") end
-----            if input:pressed("save") then curRoom:StartSave(false) end--loader:SaveDataInProgress(curRoom) end
-----            if input:pressed("spawn") then  Spawn("sphere",{velocity = {velocity_x = 10,velocity_y = 100} }) end
-----            if input:pressed("despawn") then  Despawn(  room:getCurrentRoom():GetFirstEntityByID("sphere") or room:getCurrentRoom():GetFirstEntityByID("sphere2") or room:getCurrentRoom():GetFirstEntityByID("sphere3")  ) end --нужно добавить хранение объектов по типу, а не только по имени 
-----        end;
-----    end
-----    
-----    local FuncUpdateSaving = function()
-----        local loaderStatus, isBlockingSave = loader:Update(curRoom)
-----        if loaderStatus == true then
-----            if curRoom.name ~= "saving" and isBlockingSave then 
-----                room:push("saving")
-----            end
-----        else
-----            local curRoom = room:getCurrentRoom() 
-----            if curRoom.name == "saving"  then -- покидаем сейв экран
-----                room:pop(false)
-----            end;
-----        end;
-----    end;
-----    
-----    local FuncUpdateRoom = function()
-----        local dt = love.timer.getDelta( )
-----        room:emit("update",dt)
-----    end
-----    
-----    
-----    ProjectCore.Update:Insert(FuncUpdateInput,"inputUpdate")
-----    ProjectCore.Update:Insert(FuncUpdateSaving,"saveUpdate")
-----    ProjectCore.Update:Insert(FuncUpdateRoom,"systemsUpdate")
-----  
-----    SetEntityType = function(entity_name,params) --используется в hierarchy
-----        local room = ProjectCore.modules.roomManager
-----        local currentRoom = room:getCurrentRoom()
-----        local result = currentRoom.hierarchy.SetEntityType(entity_name,params)
-----        -- print("set entity type",entity_name,params)
-----        return result
-----    end
-----    
-----    --------setup draw pipeline
-----    
-----    ProjectCore.Draw = Pipeline()
-----    local FuncDrawRoom = function()
-----        room:emit("draw")
-----    end;
-----    
-----     ProjectCore.Draw:Insert(FuncDrawRoom,"draw")
-----    
-----
-----    -------------------начало load
-----    
-----    loader:KillSaveFiles()
-----    loader:Start()
-----    room.storage:Load()
-----    room:enter("extra") --комната по-умолчанию
-----    room:emit("load")
   
end;

function love.textinput(t)
    console(t)
 --   EngineCore.modules.console(t)
end
--paused = true
local startTime = 0 --= love.timer.getTime()
local updateTime = 0
local drawTime = 0

function love.update(dt)
    
    if not paused and ProjectCore.Update then
        ProjectCore.Update:Do()
    end
    imgui.NewFrame()
  --print(aa)
end;

--local font = love.graphics.newFont("resources/unifont.ttf")



local font = imgui.AddFontFromFileTTF("resources/unifont.ttf",16,nil,ranges)
local openManager = false

local function SetFileManagerOpen(status)
    openManager = status
end

local function OpenProject(projectName)
    local fullPath = "projects/"..projectName
    local setupPath = fullPath.."/setup.lua"
    local  chunk, errormsg = love.filesystem.load( setupPath )
    if not errormsg then
        chunk()
    else
        error(errormsg)
    end
end

local aa = true
local function OpenFileManger()
   -- openManager = true
    if openManager then
        if imgui.Begin("File Manager", false,{ "ImGuiWindowFlags_NoResize"},200,200) then
            local files = love.filesystem.getDirectoryItems( "projects" )
         --   local check = {}
            for k,v in pairs(files) do
                --local check = {}
                if imgui.Checkbox(v,aa) then
                   -- for k,vv in pairs(files)
                    aa = not aa
                end;
                
               -- if imgui.BeginMenu(v) then
               --     imgui.SetWindowSize(v,200,200)
               --     imgui.EndMenu()
               -- end
            end;
           if imgui.Button("Open") then
                if aa then
                    OpenProject("first")
                end
           end;
           
           -- imgui.Text("Hello, world!")
           -- imgui.Text("Hello, world!")
            imgui.End();
        end
        
        imgui.SetWindowSize("File Manager",200,200)
    end
end;

function love.draw() --Тут происходит заметная просадка FPS
    --love.graphics.setFont(font)
   
    

    -- drawTime = (love.timer.getTime()- startTime - updateTime  ) 
    -- local totalFrameTime = ( drawTime+updateTime ) 
    -- love.graphics.print("update "..string.format("%.5f", updateTime*1000).." ms \t", 60,0)
    -- love.graphics.print("draw "..string.format("%.5f", drawTime*1000).." ms \t", 200,0)
    -- local fps = 1/totalFrameTime
    -- love.graphics.print("total "..string.format("%.5f", totalFrameTime*1000).." ("..string.format("%.1f",fps).." FPS)", 350,0)
    -- debuger:Draw()
    -- loader:draw()
    -- 
    -- local procs = love.system.getProcessorCount( )
    -- love.graphics.print("procs "..procs, 0,300)
    
    
    -- Menu
  --if imgui.Begin("Dock Demo") then
  --     imgui.BeginDockspace(true)
  --     imgui.DockDebugWindow()
  --     for i = 1, 10 do
  --         if imgui.BeginDock("dock"..i)  then
  --             imgui.Text("Hello, dock "..i);
  --         end
  --         imgui.EndDock()
  --     
  --     end
  --     imgui.EndDockspace()
  --     imgui.End();
  -- end
  -- love.graphics.clear(clearColor[1], clearColor[2], clearColor[3])
    if imgui.BeginMainMenuBar() then
        if imgui.BeginMenu("Engine") then
            imgui.EndMenu()
        end
        if imgui.BeginMenu("Project") then
            imgui.MenuItem("New")
            if imgui.MenuItem("Open") then
                SetFileManagerOpen(true)
            end;
            
            if imgui.MenuItem("Close") then
                ProjectCore:Destroy() --= nil
              --  collectgarbage()
               ProjectCore = Core()
            end;
            
            
            imgui.EndMenu()
        end
        
        local a,b,c,d = imgui.BeginMenu("Текст на Русском, Охуеть")
        if a then  imgui.EndMenu() end
        
        if imgui.BeginMenu("Settings") then
            imgui.EndMenu()
        end;
        --print(a,b,c,d)
        imgui.EndMainMenuBar()

    end

OpenFileManger()
     --showTestWindow = imgui.ShowDemoWindow(true)
    imgui.Render();
   
    if ProjectCore.Draw then
        ProjectCore.Draw:Do()
    end
    
end;

--local startDock =  imgui.BeginDock
--imgui.BeginDock = function(name,...)
--    startDock(name ...)
--    return true
--end


function love.quit()
    imgui.ShutDown();
end

--
-- User inputs
--
function love.textinput(t)
    imgui.TextInput(t)
    if not imgui.GetWantCaptureKeyboard() then
        -- Pass event to the game
    end
end

function love.keypressed(key)
    imgui.KeyPressed(key)
    if not imgui.GetWantCaptureKeyboard() then
        -- Pass event to the game
    end
end

function love.keyreleased(key)
    imgui.KeyReleased(key)
    if not imgui.GetWantCaptureKeyboard() then
        -- Pass event to the game
    end
end

function love.mousemoved(x, y)
    imgui.MouseMoved(x, y)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end

function love.mousepressed(x, y, button)
    imgui.MousePressed(button)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end

function love.mousereleased(x, y, button)
    imgui.MouseReleased(button)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end

function love.wheelmoved(x, y)
    imgui.WheelMoved(y)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end

--for k,v in pairs( imgui) do
--    if k:find("Active") then
--        print(k)
--    end
--end