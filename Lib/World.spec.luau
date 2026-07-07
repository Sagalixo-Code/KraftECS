local World = require(script.Parent.World)

return function()
	describe("World", function()
		describe("Creation", function()
			it("creates an empty world", function()
				local world = World.new()

				expect(world._archetypes).to.be.ok()
				expect(world._scheduler).to.be.ok()
			end)
		end)

		describe("Entities", function()
			it("spawns valid entities", function()
				local world = World.new()

				local entity = world:spawn()

				expect(world:exists(entity)).to.equal(true)
			end)

			it("creates unique entities", function()
				local world = World.new()

				local a = world:spawn()
				local b = world:spawn()

				expect(a).never.to.equal(b)
			end)

			it("despawn invalidates entity", function()
				local world = World.new()

				local entity = world:spawn()

				world:despawn(entity)

				expect(world:exists(entity)).to.equal(false)
			end)
		end)

		describe("Components", function()
			it("sets and retrieves components", function()
				local world = World.new()

				local entity = world:spawn()

				world:set(entity, 1, "Hello")

				expect(world:get(entity, 1)).to.equal("Hello")
			end)

			it("detects components", function()
				local world = World.new()

				local entity = world:spawn()

				expect(world:has(entity, 10)).to.equal(false)

				world:set(entity, 10, true)

				expect(world:has(entity, 10)).to.equal(true)
			end)

			it("removes components", function()
				local world = World.new()

				local entity = world:spawn()

				world:set(entity, 1, 123)

				world:remove(entity, 1)

				expect(world:has(entity, 1)).to.equal(false)

				expect(world:get(entity, 1)).to.equal(nil)
			end)

			it("migrates entity between archetypes", function()
				local world = World.new()

				local entity = world:spawn()

				world:set(entity, 1, "A")
				world:set(entity, 2, "B")

				expect(world:get(entity, 1)).to.equal("A")

				expect(world:get(entity, 2)).to.equal("B")

				world:remove(entity, 1)

				expect(world:has(entity, 1)).to.equal(false)

				expect(world:get(entity, 2)).to.equal("B")
			end)

			it("preserves components after migration", function()
				local world = World.new()

				local entity = world:spawn()

				world:set(entity, 1, {
					Value = 100,
				})

				world:set(entity, 2, 500)

				expect(world:get(entity, 1).Value).to.equal(100)

				expect(world:get(entity, 2)).to.equal(500)
			end)
		end)

		describe("Queries", function()
			it("finds entities with matching components", function()
				local world = World.new()

				local a = world:spawn()
				local b = world:spawn()

				world:set(a, 1, "A")
				world:set(a, 2, "B")

				world:set(b, 1, "C")

				local query = world:query(1, 2)

				local found = {}

				while true do
					local entity = query()

					if not entity then
						break
					end

					found[entity] = true
				end

				expect(found[a]).to.equal(true)

				expect(found[b]).to.equal(nil)
			end)

			it("supports without filters", function()
				local world = World.new()

				local a = world:spawn()
				local b = world:spawn()

				world:set(a, 1, true)
				world:set(a, 2, true)

				world:set(b, 1, true)

				local query = world:query(1):without(2)

				local entity = query()

				expect(entity).to.equal(b)
			end)
		end)

		describe("Observers", function()
			it("fires onChange listeners", function()
				local world = World.new()

				local entity = world:spawn()

				local called = false

				world:onChange(5, function(e, value)
					called = true

					expect(e).to.equal(entity)

					expect(value).to.equal(999)
				end)

				world:set(entity, 5, 999)

				expect(called).to.equal(true)
			end)
		end)

		describe("Scheduler", function()
			it("registers systems", function()
				local world = World.new()

				local system = {}

				world:addSystem(system)

				expect(#world._scheduler._systems).to.equal(1)
			end)

			it("runs lifecycle", function()
				local world = World.new()

				local calls = {}

				local system = {}

				function system:PreInit()
					table.insert(calls, "PreInit")
				end

				function system:Init()
					table.insert(calls, "Init")
				end

				function system:Start()
					table.insert(calls, "Start")
				end

				world:addSystem(system)

				world:startSystems()

				expect(calls[1]).to.equal("PreInit")

				expect(calls[2]).to.equal("Init")

				expect(calls[3]).to.equal("Start")
			end)

			it("updates systems", function()
				local world = World.new()

				local updated = false

				local system = {}

				function system:Update(_, dt)
					updated = true

					expect(dt).to.equal(1 / 60)
				end

				world:addSystem(system)

				world:update(1 / 60)

				expect(updated).to.equal(true)
			end)
		end)
	end)
end
