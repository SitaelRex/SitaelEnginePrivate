local Debug = {}
return debug
--local current_module = ModuleEnvInit()
--local maximum_unpack_size = 7999 --максимальное количество аргументов для unpack()
-----------------------------------------------------
--mailbox = {} --хранит значения присылаемые извне
--function MailboxClear()
--  mailbox = {}
--end;
--
--function MailboxPush(idx,data)
--  mailbox[idx] = data
--end;
--
--function MailboxGet(idx)
--  return  mailbox[idx] or "NOT_DATA"
--end;
--  
--
-----------------------------------------------------
--
--function Activate()
--  debug.active = true
--end;
--function Deactivate()
--  debug.active = false
--end;
--
--debug_points = {}
--
--function AddPoint(cords,objects_to_draw)
--  if objects_to_draw <= math.floor( maximum_unpack_size / 2 ) then
--    table.insert(debug_points,cords.x)
--    table.insert(debug_points,cords.y)
--  end;
--end;
--
--function DrawPoints()
--  love.graphics.setColor( 1, 0, 0)
--  love.graphics.setPointSize( 4 )
--  love.graphics.points(unpack(debug_points))
--  love.graphics.setPointSize( 1 )
--  love.graphics.setColor( 1, 1, 1)
--  debug_points = {}
--end;
--
--function Draw()
--  if not debug.active then return end
--  DrawPoints()
--  ------------------------------------------------------print
--  love.graphics.print(love.timer.getFPS().." FPS")
--  
--  local mem_usage_kb = collectgarbage("count")
--  love.graphics.print((math.floor(mem_usage_kb*1000/1024)/1000) .." MB memory",0,20)
-- 
--  local current_room_name = room.current_room or room.data_manager.null_room
--  love.graphics.print( #room.storage.room_list[room.current_room].world:getEntities() .." objects spawned",0,40)
--  
--  local stats = love.graphics.getStats()
--  love.graphics.print(  stats.drawcalls .." drawcalls "  ,0,60)
--  
--  --love.graphics.print(  loader.GetSaveMode() .." savemode "  ,200,0 )
-- -- love.graphics.print(  "savespeed "..MailboxGet("savespeed")  ,400,0 )
--  
--end;
--
--
--return current_module