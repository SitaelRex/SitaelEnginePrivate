script_load = function(owner)  --почему-то обязательная функция

end

function update(dt,owner,params) --поменять местами силь описания локальных и глобальных переменный
    -- при 10 тысяч объектов фпс падает с 40 до 30
   -- _local.timer  =  _local.timer or  0 
   -- _local.timer = _local.timer + dt
   -- owner.position.x =   owner.position.x < 800 and owner.position.x or 0
   -- owner.position.y =   owner.position.y < 600 and owner.position.y or 0
    
  --  print(_local.timer) --working
end;