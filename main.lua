
SetEntityType = function(entity_name,params) --используется в hierarchy
    --local room = ProjectCore.modules.roomManager
    local currentRoom = room:getCurrentRoom()
    local result = currentRoom.hierarchy.SetEntityType(entity_name,params)
    -- print("set entity type",entity_name,params)
    return result
end

----------------------------
---------------------------------------------------------------Global Engine Utils
function string:cut(reference) --сокращенный вырезатель gsub
    return self:gsub(reference, "")
end;

included = {}

function include(mod,addLayer) -- для связи между модулями
    local _,name = debug.getlocal(4,3)
    print("module ",name," include inreface ",mod)
    included[name] = included[name] or {}
    included[name][mod] = true
    
end;

Core = require 'libs/core'
Interface = require 'libs/interface'
UI = require 'libs/ui'
--pathManager = require 'modules/pathManager' -- нельзя вынести в интерфейс, потому что важен порядок инициализации. 
-- room.storage(как и прочие модули) нуждаются в path manager-e
--engineEvent =  require 'modules/engineEvent'

------------------------------------------------MAIN
function love.load()
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

   
    ProjectCore = Core(EngineCore,EngineCore.modules.pathManager.projectPath) -- создаем  ядро проекта (должно подгружаться из проекта)
 
    setmetatable(_G, {__index = function(_,key) 
                local core = ProjectCore
        local sourceInfo =  debug.getinfo(2,"S").source 
        local sourceModule,a = sourceInfo:find("modules/") 
        if not sourceModule  then  
           -- if 
            return core:IndexInterface(key) --указываем самое высокоуровневое ядро, через которое будет начинаться поиск
        else 
            local sourceInfo = sourceInfo:sub(a+1) 
            sourceInfo = sourceInfo:sub(0,sourceInfo:find("/")-1 ) 
            if sourceInfo == key or ( included[sourceInfo] and included[sourceInfo][key]  ) then
                return core:IndexInterface(key) 
            end;
          --  print(sourceInfo)
        end 
    end 
    }) 
-----   -- setmetatable(_G,{index = function(...) print(...,_G) end})
-----    -- можно сделать хранилище ядер
-----    -- при создании ядра хранить его в определнном слое таблицы с ядрами
-----    -- если про создании ядра фигурирует parent - слой ядра = слой родителя + 1
-----    -- при поиске двигаемся перебором с самого верхнего уровня, до самого нижнего

-----    ------setup update pipeline
    Pipeline = EngineCore.modules.Pipeline
   
end;

function love.textinput(t)
    --console(t)
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
end;

function love.draw() --Тут происходит заметная просадка FPS
    
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.4, 0.4, 0.4, 0.4)
        
    if ProjectCore.Draw then
        ProjectCore.Draw:Do()
    end
    love.graphics.setCanvas()
    
    UI.Draw()
end;


function love.quit()
    imgui.ShutDown();
end

-- User inputs

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
