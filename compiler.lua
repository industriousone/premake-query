---
-- query/compiler.lua
--
-- Evaluates a query against the global configuration set.
--
-- Author Jason Perkins
-- Copyright (c) 2017 Jason Perkins and the Premake project
---

	local field = require(path.join(_SCRIPT_DIR, 'field'))

	local m = {}

	local condition = dofile('./condition.lua')
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
			-- if condition.passes(block._condition, open, closed) then
				m.merge(result, block)
			-- end
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




-- 	function m:compile()
-- 		local result = {}

-- 		local dataBlocks = Oven:flattenedBlockList()

-- -- Let's assume that I'm given an un-baked data source, since I've turned off
-- -- baking above. So I will always get a container of some kind.

-- 		-- result = self:_mergeContainer(result, self._dataSource)



-- 		-- -- Use my insider knowledge to peek under the hood of the data source and
-- 		-- -- find the list of configuration data blocks. The way things are currently
-- 		-- -- set up, the data source will always be a container's configuration set,
-- 		-- -- or a context built from one.

-- 		-- local container = dataSource._cfgset or dataSource
-- 		-- local blocks = container.blocks or {}

-- 		-- -- Compare the terms on each block with my filters, and merge together all
-- 		-- -- of the blocks that pass the test. Again, using insider knowledge of the
-- 		-- -- block data structure for now.

-- 		-- local n = #blocks

-- 		-- for i = 1, n do
-- 		-- 	local block = blocks[i]

-- 		-- 	-- If this is the first time I've encountered this block, wrap its list
-- 		-- 	-- of terms up in a Condition instance, which I'll then use to test.
-- 		-- 	block._condition = block._condition or Condition:new(block._criteria.terms)

-- 		-- 	if block._condition:appliesTo(result, open, closed) then
-- 		-- 		m._merge(result, block)
-- 		-- 	end
-- 		-- end

-- 		return result
-- 	end


-- 	function m:_mergeContainer(result, container)
-- 		result = self:_mergeBlocks(result, container.blocks)
-- 		result = m:_mergeChildContainers(result, container)
-- 		return result
-- 	end



-- 	function m:_mergeChildContainers(result, parentContainer)
-- 		for childClass in container.eachChildClass(parentContainer.class) do
-- 			for child in container.eachChild(parentContainer, childClass) do

-- 				-- I have `clildClass`, which has `name` and `pluralName`
-- 				-- I have `child`, which has `name`

-- 				-- The condition is "workspaces" and name

-- 				local key = childClass.pluralName  -- e.g. "projects"
-- 				local value = child.name  -- e.g. "MyProject"

-- 				-- closed: (self._closed[key] == value)
-- 				-- open: (self._open[key] == value)




-- 			end
-- 		end
-- 	end


-- 	function m:_mergeBlocks(result, blocks)
-- 		local n = #blocks

-- 		for i = 1, n do
-- 			local block = blocks[i]

-- 			-- If this is the first time I've encountered this block, wrap its list
-- 			-- of terms up in a Condition instance, which I'll then use to test.
-- 			block._condition = block._condition or Condition:new(block._criteria.terms)

-- 			if block._condition:appliesTo(result, self._open, self._closed) then
-- 				self:_mergeBlock(result, block)
-- 			end
-- 		end

-- 		return result
-- 	end


-- 	function m:_mergeBlock(result, block)
-- 		for key, value in pairs(block) do
-- 			local field = Field.get(key)
-- 			result[key] = p.field.merge(field, result[key] or {}, value)
-- 		end
-- 	end



---
-- End of module
---

	return m
