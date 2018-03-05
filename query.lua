---
-- query/query.lua
--
-- Queries process a list of configuration blocks, return values from those blocks
-- which meet certain criteria, or "filters". A filter is a key-value collection
-- of values that need to be matched by the filtering terms associated with each
-- configuration block.
--
--     -- Include only blocks from the 'Debug' configuration of 'Workspace1'
--     { workspace='Workspace1', configurations='Debug' }
--
-- Queries use two different kinds of filters: "open" and "closed". An open term
-- will pass if it matches the corresponding term on a configuration block, or
-- if there is no corresponding term on the configuration block (i.e. nil). It
-- will fail if there is a conflicting value on a configuration block. If the
-- the above query is treated as "open", it will match blocks with no workspace
-- or configuration (i.e. global scope), blocks with a matching workspace but
-- no configuration (i.e. workspace scope), blocks with a matching configuration
-- but no workspace, and blocks which match both workspace and configuration.
--
-- A closed term will pass only if the configuration block contains a match for
-- the term. If the above filter is treated as closed, it will only match blocks
-- which match both the workspace and the configuration.
--
-- Author Jason Perkins
-- Copyright (c) 2017 Jason Perkins and the Premake project
---

	local p = premake

	local field = require(path.join(_SCRIPT_DIR, 'field'))

	local m = {}

	local compiler = dofile('./compiler.lua')



---
-- With this approach, the original baking process goes away. We should no longer be
-- pre-processing things, since that limits the ways we can pull and use the data later.
-- And file configuration objects are evil and need to die.
---

	p.override(p.main, "bake", function()
	end)

	p.override(p.main, "postBake", function()
	end)

	p.override(p.main, "validate", function()
		p.warnOnce("query-validation", "Validation is not yet implemented for queries")
	end)



---
-- Construct a new Query object.
--
-- Queries are evaluated lazily. They are cheap to create and extend.
--
-- @param open
--    A key-value collection of "open" filtering terms.
-- @param closed
--    A key-value collection of "closed" filtering terms.
-- @return
--    A new Query instance.
---

	function m.new(open, closed)
		local self = {}

		self = {
			_open = open or {},
			_closed = closed or {},
			_values = nil
		}

		return self
	end



---
-- Fetch a value from the query's filtered result set.
--
-- *Values returned from this function should be considered immutable!*
-- don't have a way to enforce that (yet), so you'll just have to be on
-- your best behavior. If you change a value returned from this method,
-- you may be changing it for all future calls as well. Make copies before
-- making changes!
---

	function m.fetch(self, key)
		if not self._values then
			self._values = compiler.evaluate(self._open, self._closed)
		end

		local value = self._values[key]

		if not value then
			local fld = field.get(key)
			value = field.emptyValue(fld)
		end

		return value
	end



---
-- Narrow an existing query with additional filtering.
--
-- @param open
--    A key-value collection of "open" filtering terms.
-- @param closed
--    A key-value collection of "closed" filtering terms.
-- @return
--    A new Query instance with the additional filtering applied.
---

	function m.filter(self, open, closed)
		local open = table.merge(self._open, open)
		local closed = table.merge(self._closed, closed)

		-- If a term has moved from open to closed, remove it from open
		for key, _ in pairs(closed) do
			open[key] = nil
		end

		local qry = m.new(open, closed)
		return qry
	end





---
-- Fetch a value, applying the previously specified filtering criteria.
--
-- *Values returned from this function should be considered immutable!* I
-- don't have a way to enforce that (yet), so you'll just have to be on
-- your best behavior. If you change a value returned from this method,
-- you may be changing it for all future calls as well. Make copies before
-- making changes!
---

	-- function m:fetch(key)
	-- 	local private = self[m]

	-- 	-- The first fetch will cause query results to be compiled
	-- 	if private.result == nil then
	-- 		private.result = m.compile(self)
	-- 	end


	-- 	local value = nil

	-- 	-- -- -- Treat requests for containers as a list of container names
	-- 	-- -- if containerKeys[key] ~= nil then
	-- 	-- -- 	local containers = self._source[key]
	-- 	-- -- 	value = table.extract(containers or {}, "name")
	-- 	-- -- 	return value
	-- 	-- -- end

	-- 	-- -- First fetch will cause query results to be compiled
	-- 	-- if self._result == nil then
	-- 	-- 	self._result = self:_compile()
	-- 	-- end

	-- 	-- value = self._result[key]

	-- 	-- If no value present, return an appropriate empty value
	-- 	if not value then
	-- 		local field = Field:get(key)
	-- 		value = field:emptyValue()
	-- 	end

	-- 	return value
	-- end



---
-- Run the query against the source data and compile the results. This gets
-- called the first time a value is fetched from this instance.
---

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



-- ---
-- -- Narrow an existing query with additional filtering.
-- --
-- -- @param open
-- --    A key-value collection of "open" filtering terms.
-- -- @param closed
-- --    A key-value collection of "closed" filtering terms.
-- -- @return
-- --    A new Query instance with the additional filtering applied.
-- ---

-- 	function m:filter(open, closed)
-- 		return self
-- 		-- open = table.merge(self._open, open)
-- 		-- closed = table.merge(self._closed, closed)

-- 		-- -- If a term has moved from open to closed, remove it from open
-- 		-- for key, _ in pairs(closed) do
-- 		-- 	open[key] = nil
-- 		-- end

-- 		-- local qry = m:new(self._dataSource, open, closed)
-- 		-- return qry
-- 	end





--[[

---
-- Identify which keys represent containers, e.g. "workspaces", "projects". I'll
-- use these to trigger container specific behavior, so that I can provide the
-- illusion that they are just normally configured lists like everything else.
---

	local containerKeys = {}

	for name, class in pairs(p.container.classes) do
		local key = class.pluralName
		containerKeys[key] = key
	end



---
-- Set up ":" style calling for methods.
---

	local metatable =
	{
		__index = m
	}



---
-- Construct a new Query object.
--
-- Queries are evaluated lazily. They are cheap to create and extend.
--
-- @param filter
--    A list of key-value pairs representing the specifics of the condition,
--    e.g. `{ "configurations:Debug", "system:Windows" }`.
---

	function m.new(source, filter)
		local self = {
			_source = source,
			_filter = filter or {}
		}

		setmetatable(self, metatable)
		return self
	end



---
-- Fetch a value, applying the previously specified filtering criteria.
--
-- *Values returned from this function should be considered immutable!* I
-- don't have a way to enforce that (yet), so you'll just have to be on
-- your best behavior. If you change a value returned from this method,
-- you may be changing it for all future calls as well. Make copies before
-- making changes!
---

	function m:fetch(key)
		-- Treat requests for containers as a list of container names
		if containerKeys[key] ~= nil then
			local containers = self._source[key]
			value = table.extract(containers or {}, "name")
			return value
		end

		-- First fetch will cause query results to be compiled
		if not self._result then
			self._result = self:_compile()
		end

		value = self._result[key]

		-- If no value present, return an appropriate empty value
		if not value then
			value = Field.emptyValue(key)
		end

		return value
	end



---
-- Run the query against the source data and compile the results. This gets
-- called the first time a value is fetched from this instance.
---

	function m:_compile()
		local source = self._source or {}
		local filter = self._filter

		-- Seed the results with the properties of the container (name, etc.)
		local result = table.shallowcopy(source)

		-- Peek under the hood of Context/ConfigSet to find the list of blocks
		local cfgSet = source._cfgset or source
		local blocks = cfgSet.blocks or {}

		-- Merge together values from all blocks that pass the query's filter
		local n = #blocks
		for i = 1, n do
			local block = blocks[i]

			block._condition = block._condition or Condition.new(block._criteria.terms)

			if block._condition:appliesTo(filter, result) then
				m._merge(result, block)
			end
		end

		return result
	end



	function m._merge(result, block)
		for key, value in pairs(block) do
			local field = Field.get(key)
			result[key] = p.field.merge(field, result[key] or {}, value)
		end
	end



---
-- Narrow an existing query with additional filtering.
---

	function m:filter(filter)
		local source = self:_findSourceContainer(self._source, filter) or {}
		local mergedFilter = table.merge(self._filter, filter)

		local q = m.new(source, mergedFilter)
		return q
	end


	function m:_findSourceContainer(source, filter)
		if not source then
			return nil
		end

		for containerType in pairs(containerKeys) do
			local containersOfType = source[containerType]
			local targetContainerName = filter[containerType]
			if containersOfType and targetContainerName then
				local container = containersOfType[targetContainerName]
				return self:_findSourceContainer(container, filter)
			end
		end

		return source
	end

]]




---
-- Construct a new Query object.
--
-- Queries are evaluated lazily. They are cheap to create and extend.
--
-- @param dataSource
--    The collection of configuration setting blocks holding the values to be queried.
--    If not set, defaults to `premake.api.scope.global`.
-- @param open
--    A key-value collection of "open" filtering terms.
-- @param closed
--    A key-value collection of "closed" filtering terms.
-- @return
--    A new Query instance.
---

	-- function Query:new(open, closed)
	-- 	local newInstance = {}

	-- 	newInstance[m] = {
	-- 		-- open = open or {},
	-- 		-- closed = closed or {},
	-- 		result = nil
	-- 	}

	-- 	setmetatable(newInstance, metatable)
	-- 	return newInstance
	-- end



---
-- Write the full list of global configuration blocks out to the console for debugging.
--
-- TODO: Move this into the API module.
--
-- @param targetFieldName
--    Optional; if set, will only show values for this specific field.
---

	function m.visualizeSourceData(targetFieldName)
		local eol = '\r\n'

		local dataBlocks = compiler.globalDataBlocks()

		for i = 1, #dataBlocks do
			local block = dataBlocks[i]
			local condition = block._condition

			local terms = table.concat(condition.terms, ', ')
			local text = string.format('BLOCK %d: { %s }%s', i, terms, eol)
			io.stdout:write(text)

			for key, value in pairs(block) do
				if targetFieldName == nil or targetFieldName == key then
					local fld = field.get(key)
					text = string.format('  %s: %s%s', fld.name, field.toString(fld, value), eol)
					io.stdout:write(text)
				end
			end

			io.stdout:write(eol)
		end
	end



---
-- End of module
---

	return m
