## Example

```lua
local entity = world:spawn()

world:set(entity, Position, Vector3.zero)
world:set(entity, Velocity, Vector3.new(10, 0, 0))

for entity, position, velocity in world:query(Position, Velocity) do
	position += velocity
end
```
