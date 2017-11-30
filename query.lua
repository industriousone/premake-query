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


---
-- End of module
---

	return m