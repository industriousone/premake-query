---
-- query/compiler.lua
--
-- Evaluates a query against the global configuration set.
--
-- Author Jason Perkins
-- Copyright (c) 2017 Jason Perkins and the Premake project
---

	local condition = require(path.join(_SCRIPT_DIR, 'condition'))
	local field = require(path.join(_SCRIPT_DIR, 'field'))

	local m = {}

	local oven = dofile('./oven.lua')


---
-- Evaluates a query's filters against the global configuration set and
-- returns the result.
---

	function m.evaluate(open, closed)
		local result = {}

		local dataBlocks = oven.globalDataBlocks()
		local n = #dataBlocks

		for i = 1, n do
			local block = dataBlocks[i]
			if condition.appliesTo(block._condition, result, open, closed) then
				m.merge(result, block)
			end
		end

		return result
	end



---
-- Retrieve the flattened version of the global configuration data, building
-- it if needed.
---

	function m.globalDataBlocks()
		return oven.globalDataBlocks()
	end



	function m.merge(result, block)
		for key, value in pairs(block) do
			local fld = field.get(key)
			result[key] = field.merge(fld, result[key] or {}, value)
		end
	end



---
-- End of module
---

	return m
