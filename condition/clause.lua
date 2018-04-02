---
-- query/condition/clause.lua
--
-- Represents the clauses (e.g. `if system is "windows"`) that make up
-- the scoping filters on a block.
--
-- Author Jason Perkins
-- Copyright (c) 2017 Jason Perkins and the Premake project
---

	local m = {}

	local cache = {}


---
-- Creates a clause instance from a block scoping term.
---

	function m.new(term)
		local clause = cache[term]
		if clause then
			return clause
		end

		local parts = term:explode(":", true, 1)

		local key = parts[1]
		local values = { parts[2] }  -- TODO: support multiple values

		local clause = {}

		clause.key = key
		clause.values = values
		clause.negated = false

		cache[term] = clause
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

	-- TODO: should compiler.lua -> clause.lua?
	function m.appliesTo(clause, data, openFilters, closedFilters)
		local key = clause.key
		local blockPatterns = clause.values
		local n = #blockPatterns

		local open = openFilters[key]
		local closed = closedFilters[key]

		-- Closed filter values *must* be matched by the block
		if closed ~= nil then
			if n == 0 then
				return false  -- block has no terms to match the closed list
			end

			for i = 1, n do
				local pattern = blockPatterns[i]
				if not closed:match(pattern) then
					return false
				end
			end
		end

		-- Patterns listed on the block must match something in the filters to pass
		for i = 1, n do
			local pattern = blockPatterns[i]

			local matched = false

			if open ~= nil and open:match(pattern) then
				matched = true
			elseif closed ~= nil and closed:match(pattern) then
				matched = true
			end

			if not matched then
				return false
			end
		end

		return true
	end



---
-- End of module
---

	return m
