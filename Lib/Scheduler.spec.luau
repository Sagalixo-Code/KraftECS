--!strict

local Scheduler = require(script.Parent.Scheduler)

return function()
	describe("Scheduler", function()
		describe("Creation", function()
			it("creates empty scheduler", function()
				local scheduler = Scheduler.new()

				expect(#scheduler._systems).to.equal(0)
				expect(#scheduler._updateSystems).to.equal(0)
			end)
		end)

		describe("Registration", function()
			it("registers systems", function()
				local scheduler = Scheduler.new()

				local system = {}

				scheduler:scheduleSystem(system)

				expect(#scheduler._systems).to.equal(1)
				expect(scheduler._systems[1]).to.equal(system)
			end)

			it("does not register duplicate systems", function()
				local scheduler = Scheduler.new()

				local system = {}

				scheduler:scheduleSystem(system)
				scheduler:scheduleSystem(system)

				expect(#scheduler._systems).to.equal(1)
			end)

			it("registers update capable systems only", function()
				local scheduler = Scheduler.new()

				local a = {}
				local b = {}

				function a:Update() end

				scheduler:scheduleSystem(a)
				scheduler:scheduleSystem(b)

				expect(#scheduler._updateSystems).to.equal(1)
			end)

			it("registers multiple systems", function()
				local scheduler = Scheduler.new()

				local systems = {
					{},
					{},
					{},
				}

				scheduler:scheduleSystems(systems)

				expect(#scheduler._systems).to.equal(3)
			end)
		end)

		describe("Lifecycle", function()
			it("runs lifecycle in correct order", function()
				local scheduler = Scheduler.new()

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

				scheduler:scheduleSystem(system)

				scheduler:initialize({})

				expect(calls[1]).to.equal("PreInit")
				expect(calls[2]).to.equal("Init")
				expect(calls[3]).to.equal("Start")
			end)

			it("passes world to lifecycle", function()
				local scheduler = Scheduler.new()

				local received

				local system = {}

				function system:Init(world)
					received = world
				end

				scheduler:scheduleSystem(system)

				local world = {}

				scheduler:initialize(world)

				expect(received).to.equal(world)
			end)
		end)

		describe("Update", function()
			it("updates systems", function()
				local scheduler = Scheduler.new()

				local called = false

				local system = {}

				function system:Update(world, dt)
					called = true

					expect(world).to.equal("World")

					expect(dt).to.equal(1 / 60)
				end

				scheduler:scheduleSystem(system)

				scheduler:update("World", 1 / 60)

				expect(called).to.equal(true)
			end)

			it("keeps update order", function()
				local scheduler = Scheduler.new()

				local order = {}

				local a = {}
				local b = {}

				function a:Update()
					table.insert(order, "A")
				end

				function b:Update()
					table.insert(order, "B")
				end

				scheduler:scheduleSystems({
					a,
					b,
				})

				scheduler:update({}, 0)

				expect(order[1]).to.equal("A")

				expect(order[2]).to.equal("B")
			end)

			it("tracks execution count", function()
				local scheduler = Scheduler.new()

				local system = {}

				function system:Update() end

				scheduler:scheduleSystem(system)

				scheduler:update({}, 0)
				scheduler:update({}, 0)

				local state = scheduler._systemState[system]

				expect(state.executionCount).to.equal(2)
			end)
		end)

		describe("State", function()
			it("disables systems", function()
				local scheduler = Scheduler.new()

				local count = 0

				local system = {}

				function system:Update()
					count += 1
				end

				scheduler:scheduleSystem(system)

				scheduler:disable(system)

				scheduler:update({}, 0)

				expect(count).to.equal(0)
			end)

			it("reenables systems", function()
				local scheduler = Scheduler.new()

				local count = 0

				local system = {}

				function system:Update()
					count += 1
				end

				scheduler:scheduleSystem(system)

				scheduler:disable(system)
				scheduler:enable(system)

				scheduler:update({}, 0)

				expect(count).to.equal(1)
			end)

			it("stores runtime state", function()
				local scheduler = Scheduler.new()

				local system = {}

				scheduler:scheduleSystem(system)

				local state = scheduler._systemState[system]

				expect(state).never.to.equal(nil)

				expect(state.enabled).to.equal(true)

				expect(state.executionCount).to.equal(0)
			end)
		end)
	end)
end
