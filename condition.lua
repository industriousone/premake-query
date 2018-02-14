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

	m._clauseCache = {}


---
-- Set up ":" style calling for methods.
---

	local metatable =
	{
		__index = m
	}



---
-- Construct a new Condition object.
--
-- @param terms
--    A list of key-value pairs representing the specifics of the condition,
--    e.g. `{ configurations = "Debug", system = "Windows" }`.
---

	function m:new(terms)
		local self = {
			_clauses = m._compileTermsToClauses(terms or {})
		}

		setmetatable(self, metatable)
		return self
	end



	function m._compileTermsToClauses(terms)
		local clauses = {}

		local n = #terms
		for i = 1, n do
			local term = terms[i]

			local clause = m._clauseCache[term]

			if not clause then
				clause = m._compileTermToClause(term)
				m._clauseCache[term] = clause
			end

			clauses[clause.key] = clause
		end

		return clauses
	end



	function m._compileTermToClause(term)
		local parts = term:explode(":", true, 1)
		local key = parts[1]
		local values = parts[2]

		local clause = { values }
		clause.key = key
		clause.negated = false

		return clause
	end



---
-- Test this condition against a set of data.
--
-- @param data
--    A set of key-value pairs, representing the state to be tested against.
--    These will be considered in the case that the target value is not specified
--    by the filter.
-- @param open
--    A key-value collection of "open" filtering terms.
-- @param closed
--    A key-value collection of "closed" filtering terms.
---

	function m:appliesTo(data, open, closed)
		for key, clause in pairs(self._clauses) do
			local closedValue = closed[key]
			local openValue = open[key]

			-- TODO: I need to reverse closedValue checks...

			local n = #clause

			-- Closed filter values must be matched by the block
			if closedValue then
				if n == 0 then
					return false
				end

				for i = 1, n do
					local blockFilterPattern = clause[i]
					if not closedValue:match(blockFilterPattern) then
						return false
					end
				end
			end

			-- Terms listed on the block must match something in the filters to pass
			for i = 1, n do
				local blockFilterPattern = clause[i]

				local matched = false

				if openValue ~= nil and openValue:match(blockFilterPattern) then
					matched = true
				elseif closedValue ~= nil and closedValue:match(blockFilterPattern) then
					matched = true
				end

				if not matched then
					return false
				end
			end
		end

		return true
	end



---
-- End of module
---

	return m