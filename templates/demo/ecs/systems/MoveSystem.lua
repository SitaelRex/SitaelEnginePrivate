local MoveSystem = ecs.system({
    pool = {"position", "velocity"}
})

--local zone_diapozone = {
--  x = {min = 0, max = 100},
--  y = {min = 0, max = 100},
--}
--
--local timer_value = 0
--local timer_value_inc = 1
--local timer_value_abs_max = 200

function MoveSystem:update(dt)
 -- print(timer_value)
  --  if true then return end
 -- timer_value = timer_value+100*(timer_value_inc*dt)
   -- for _,e in ipairs(self.pool)  do
    for e in self.pool:SortedPool()  do
        --local vectorX,vectorY = 1,1
        
        --if timer_value >= timer_value_abs_max then
        --  timer_value_inc = -1
        --end;
        --
        --if timer_value <= -timer_value_abs_max then
        --  timer_value_inc = 1
        --end;
        --
        --
        --
        --if (e.position.x < zone_diapozone.x.min + timer_value  and e.velocity.x < 0) or (e.position.x > zone_diapozone.x.max - timer_value and e.velocity.x > 0) then
        --  e.velocity.x = -e.velocity.x
        --end
        --
        --if (e.position.y < zone_diapozone.y.min + timer_value and e.velocity.y < 0 ) or (e.position.y > zone_diapozone.y.max - timer_value and  e.velocity.y > 0) then
        --  e.velocity.y = -e.velocity.y
        --end
      
        e.position.x = e.position.x + (e.velocity.x * dt)
        e.position.y = e.position.y + (e.velocity.y * dt)
  end
end

return MoveSystem