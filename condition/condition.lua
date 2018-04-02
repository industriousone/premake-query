---
-- query/condition.lua
--
-- The Condition class represents the clauses that appear in the `filter` calls
-- of the scripts, and provides methods to test those clauses against different
-- query filters.
--
-- Author Jason Perkins
-- Copyright (c) 2017 Jason Perkins and the Premake project
---

	local m = {}

	local clause = dofile('./clause.lua')


---
-- Construct a new Condition object.
--
-- @param terms
--    A list of key-value pairs representing the specifics of the condition,
--    e.g. `{ configurations = "Debug", system = "Windows" }`.
---

	function m.new(terms)
		terms = terms or {}

		local clauses = {}

		for i, term in ipairs(terms) do
			clauses[i] = clause.new(term)
		end

		local self = {
			terms = terms,
			_clauses = clauses,
		}

		return self
	end



---
-- Does this condition apply to the provided criteria?
--
-- @param data
--    The currently assembled data set. Values that have been previously
--    set can match clauses in the condition.
-- @param open
--
--
	function m.appliesTo(self, data, open, closed)
		local clauses = self._clauses
		local n = #clauses

		for i = 1, n do
			if not clause.appliesTo(clauses[i], data, open, closed) then
				return false
			end
		end

		return true
	end


---
-- End of module
---

	return m