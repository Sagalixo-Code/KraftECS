local MovementSystem = {}

local Position = 2
local Velocity = 3

function MovementSystem:PreInit(world)
	print("1")
end

function MovementSystem:Init(world)
	print("2")
end

function MovementSystem:Start(world)
	print("3")
end

function MovementSystem:Update(world, dt)
	for entity, position, velocity in world:query(Position, Velocity) do
		world:set(entity, Position, position + velocity * dt)
	end
end

return MovementSystem
