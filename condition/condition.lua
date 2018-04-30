---
-- condition/condition.lua
--
-- Conditions represent the environment tests for a block of configuration data,
-- corresponding to the `filter()` calls in a project script. If a condition is
-- met, then the data contained by the block should be applied.  If the condition
-- is not met, the block should be ignored.
--
-- Conditions are made up clauses. This condition contains two clauses:
--
--     filter { system='Windows', kind='SharedLib' }
--
-- Author Jason Perkins
-- Copyright (c) 2017 Jason Perkins and the Premake project
---

	local m = {}

	local clause = dofile('./clause.lua')



---
-- Construct a new Condition object from a list of filtering clauses.
--
-- @param filter
--    A list of key-value pairs representing the specifics of the condition,
--    e.g. `{ configurations = 'Debug', system = 'Windows' }`.
---

	function m.new(filter)
		local clauses = {}

		for key, patterns in pairs(filter or {}) do
			local cl = clause.new(key, patterns)
			clauses[cl.key] = cl
		end

		local self = {
			_clauses = clauses,
		}

		return self
	end



	function m.hasClosedMatch(self, key, value)
		local cl = self._clauses[key]

		if not cl or not clause.test(cl, value) then
			return false
		end

		return true
	end



	function m.hasOpenMatch(self, key, value)
		local cl = self._clauses[key]

		if cl ~= nil and not clause.test(cl, value) then
			return false
		end

		return true
	end



	function m.isMatchedBy(self, data, open, closed)
		local clauses = self._clauses

		for key, cl in pairs(clauses) do
			local value = closed[key] or open[key] or data[key]
			if not value or not clause.test(cl, value) then
				return false
			end
		end

		return true
	end



---
-- End of module
---

	return m