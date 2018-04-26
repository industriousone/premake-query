---
-- query/compiler.lua
--
-- Evaluates a query against the global configuration set.
--
-- Author Jason Perkins
-- Copyright (c) 2018 Jason Perkins and the Premake project
---

	local condition = require(path.join(_SCRIPT_DIR, 'condition'))
	local field = require(path.join(_SCRIPT_DIR, 'field'))

	local m = {}

	local oven = dofile('./oven.lua')



---
-- Add values from a configuration data block to the final result.
---

	local function evaluateAdditions(block, result)
		for key, value in pairs(block) do
			local fld = field.get(key)
			result[key] = field.merge(fld, result[key] or {}, value)
		end
	end



---
-- Process any values marked as removed in a configuration block, removing
-- them from the final result.
---

	local function evaluateRemoves(block, result)
		local removes = block._removes
		for key, patterns in pairs(removes) do
			local fld = field.get(key)
			local values = result[key]

			for i, pattern in ipairs(patterns) do
				values = field.remove(fld, values or {}, pattern)
			end

			result[key] = values
		end
	end



---
-- Check the conditions on a configuration block, and add or remove values
-- from the final result as appropriate.
--
-- @param block
--    The configuration data block to evaluate.
-- @param result
--    The current result set.
-- @param open
--    The list of open terms from the query filter.
-- @param closed
--    The list of closed terms from the query filter.
---

	local function evaluateBlock(block, result, open, closed)
		local cond = block._condition

		for key, value in pairs(closed) do
			if not condition.hasClosedMatch(cond, key, value) then
				return false
			end
		end

		for key, value in pairs(open) do
			if not condition.hasOpenMatch(cond, key, value) then
				return false
			end
		end

		if block._removes then
			evaluateRemoves(block, result)
		end

		if not condition.isMatchedBy(cond, result, open, closed) then
			return false
		end

		evaluateAdditions(block, result)
	end



---
-- Evaluates a query's filters against the global configuration set and
-- return the result.
--
-- @param open
--    The list of open terms from the query filter.
-- @param closed
--    The list of closed terms from the query filter.
---

	function m.evaluate(open, closed)
		local result = {}

		local dataBlocks = oven.globalDataBlocks()

		for i, block in ipairs(dataBlocks) do
			evaluateBlock(block, result, open, closed)
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


---
-- End of module
---

	return m
