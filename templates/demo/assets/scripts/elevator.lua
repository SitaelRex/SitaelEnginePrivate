
script_load = function(owner) 

end

function update(dt,owner,params) --поменять местами силь описания локальных и глобальных переменный
    _local.timer =  _local.timer or  0  --создать лоад, выполняющийся для каждого объекта
    _local.r =  _local.r or 150 - (15*owner.hierarchy.level)
    _local.mode = owner.hierarchy.level%2 == 0 and 1 or -1
    
    _local.timer = _local.timer + ( (-1+owner.hierarchy.level)/20 *  _local.mode * owner.hierarchy.level ) *dt
    if _local.timer >= 1 then _local.timer = 0 end
    
   local a = timer * (math.pi*2)
   owner.position.x =   _local.r * math.cos (a)
   owner.position.y =   _local.r * math.sin (a)
end;

--function draw() end --без этой функции все почеу-то ломается

