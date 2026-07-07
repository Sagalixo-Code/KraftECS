local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ECS = require(ReplicatedStorage.Lib.World)

local Systems = {
	require(script.Parent.Systems.MovementSystem),
}
local Components = {
	Health = 1,
	Position = 2,
	Velocity = 3,
}

local World = ECS.new()

local start = os.clock()

World:addSystems(Systems)

for i = 1, 10000 do
	local e = World:spawn()

	World:set(e, Components.Health, 100)
	World:set(e, Components.Position, Vector3.zero)
	World:set(e, Components.Velocity, Vector3.one)

	World:onChange(Components.Position, function(entity, componentName, oldValue, newValue)
		if componentName == Components.Health then
			print("Entity", entity, "Health changed from", oldValue, "to", newValue)
		end
	end)

	local currentHealth = World:get(e, Components.Health)
	World:set(e, Components.Health, currentHealth - 10)
end

World:startSystems()

RunService.Heartbeat:Connect(function(dt)
	World:update(dt)
end)

print("Spawn time:", os.clock() - start)
print("Entities:", World:count())
