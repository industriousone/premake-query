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

	function m.new(key, patterns)
		-- convert from old `{'system:windows'}` style to `{system='windows'}`
		if type(key) == 'number' then
			local parts = patterns:explode(':', true, 1)
			key = parts[1]
			patterns = parts[2]
		end

		local rule = cache[patterns]

		if not rule then
			rule = {}
			rule.patterns = { patterns }
			rule.negated = false
			cache[patterns] = rule
		end

		local clause = {}
		clause.key = key
		clause.rule = rule

		return clause
	end



---
-- Determines if this clause can match the provided value.
---

	function m.test(self, value)
		local rule = self.rule

		for _, pattern in ipairs(rule.patterns) do
			if value:match(pattern) then
				return true
			end
		end

		return false
	end



---
-- End of module
---

	return m
