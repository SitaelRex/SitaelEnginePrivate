local PATH = (...):gsub('%.init$', '')
local baton = require(PATH..".baton")

local input_config = {
  controls = {
    left = {'key:left', 'key:a', 'axis:leftx-', 'button:dpleft'},
    right = {'key:right', 'key:d', 'axis:leftx+', 'button:dpright'},
    up = {'key:up', 'key:w', 'axis:lefty-', 'button:dpup'},
    down = {'key:down', 'key:s', 'axis:lefty+', 'button:dpdown'},
    action = {'key:x', 'button:a'},
    camera1 = {'key:o'},
    camera2 = {'key:p'},
    room1 = {'key:k'},
    room2 = {'key:l'},
    room3 = {'key:;'},
    save = {'key:n'},
    spawn = {'key:j'},
    despawn = {'key:h'},
    test =  {'key:t'}
    
    
  },
  pairs = {
    move = {'left', 'right', 'up', 'down'}
  },
  joystick = love.joystick.getJoysticks()[1],
}


local input = baton.new(input_config)

input.blocked = false
input.Block = function() input.blocked = true end
input.Unblock = function() input.blocked = false end

input.Blocked = function() return input.blocked end
return input