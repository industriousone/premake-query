---
-- query/query.lua
--
-- Author Jason Perkins
-- Copyright (c) 2017 Jason Perkins and the Premake project
---

	local m = {}

	local Condition = dofile('condition.lua')
	local Field = dofile('field.lua')

	local p = premake



---
-- With this approach, the baking step goes away. We should no longer be pre-processing
-- things, since that limits the ways we can pull the data later. And file configuration
-- objects are evil and need to die.
---

	p.override(p.main, "bake", function()
	end)

	p.override(p.main, "postBake", function()
	end)

	p.override(p.main, "validate", function()
		p.warnOnce("query-validation", "Validation is not yet implemented for queries")
	end)



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
-- @param dataSource
--    The collection of configuration setting blocks holding the values to be queried.
--    If not set, defaults to `premake.api.scope.global`.
-- @param filter
--    A list of key-value pairs representing the specifics of the condition,
--    e.g. `{ configurations = 'Debug', system = 'Windows' }`.
-- @return
--    A new Query instance.
--
-- TODO: There is a lot of overlap between ConfigSet/Context and Query right now. I'd
--       like to convert ConfigSet into a dumb list of data blocks, and drop Context
--       entirely, at some point.
---

	function m.new(self, dataSource, filter)
		local self = {
			_dataSource = dataSource or p.api.scope.global,
			_filter = filter or {},
			_result = nil
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
		local value

		value = nil

		-- -- Treat requests for containers as a list of container names
		-- if containerKeys[key] ~= nil then
		-- 	local containers = self._source[key]
		-- 	value = table.extract(containers or {}, "name")
		-- 	return value
		-- end

		-- First fetch will cause query results to be compiled
		if self._result == nil then
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
		local source = self._dataSource or {}
		local filter = self._filter or {}

		local result = {}

		-- Use my insider knowledge to peek under the hood of the data source and
		-- find the list of configuration data blocks. The way things are currently
		-- set up, the data source will always be a container's configuration set,
		-- or a context built from one.

		local container = source._cfgset or source
		local blocks = container.blocks or {}

		-- Compare the terms on each block with my filter, and merge together all
		-- of the blocks that pass the test. Again, using insider knowledge of the
		-- block data structure for now.

		local n = #blocks

		for i = 1, n do
			local block = blocks[i]

			-- If this is the first time I've encountered this block, wrap its list
			-- of terms up in a Condition instance, which I'll then use to test.
			block._condition = block._condition or Condition.new(block._criteria.terms)

			if block._condition:appliesTo(filter, result) then
				m._merge(result, block)
			end
		end

		return result
	end



---
-- Merge a block of configuration settings into a result set.
---

	function m._merge(result, block)
		for key, value in pairs(block) do
			local field = Field.get(key)
			result[key] = p.field.merge(field, result[key] or {}, value)
		end
	end






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
-- End of module
---

	return m