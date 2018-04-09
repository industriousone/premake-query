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
			table.insert(clauses, clause.new(key, patterns))
		end

		local self = {
			_clauses = clauses,
		}

		return self
	end



---
-- Determines if the provided term key and value can be matched by this condition.
---

	function m.canMatchTerm(self, key, value)
		local clauses = self._clauses

		for i, cl in ipairs(clauses) do
			if clause.matchesTerm(cl, key, value) then
				return true
			end
		end

		return false
	end



---
-- Determines if a condition is satisfied by the supplied environment.
---

	function m.isMatchedBy(self, data, open, closed)
		local clauses = self._clauses

		for i, cl in ipairs(clauses) do
			if not clause.isMatchedBy(cl, data, open, closed) then
				return false
			end
		end

		return true
	end



---
-- End of module
---

	return m