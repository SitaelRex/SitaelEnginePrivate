local room = {}

function room:enter(previous, ...)
	-- set up the level
end

function room:update(dt)
	-- update entities
end

function room:leave(next, ...)
	-- destroy entities and cleanup resources
end

function room:draw()
	-- draw the level
end

return room