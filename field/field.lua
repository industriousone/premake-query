---
-- query/field.lua
--
-- An adapter between "what I think the Field module should look like" and
-- "what the field module looks like now."
--
-- Author Jason Perkins
-- Copyright (c) 2017 Jason Perkins and the Premake project
---

	local p = premake

	local m = {}


---
-- The current configset code assumes that containers do not have a field instance to
-- represent them, and will break if it encounters one. Only return container field
-- instances to the new code.
---

	m.containerFieldNames = {}

	local function remapContainerClasses(parentClass)
		for childClass in p.container.eachChildClass(parentClass) do
			local name = childClass.pluralName
			m.containerFieldNames[name] = '_container_' .. name
			remapContainerClasses(childClass)
		end
	end

	remapContainerClasses(p.global)



---
-- Retrieve a field by name. If no such field exists, synthesize a simple
-- assignment-only field on the fly.
---

	function m.get(name)
		-- Remap container names to avoid breaking older code
		-- TODO: Get rid of this once everything has migrated to new approach
		name = m.containerFieldNames[name] or name

		local field = p.field.get(name)

		if field == nil and not m.containerFieldNames[name] then
			field = p.field.new({
				name = name,
				scope = 'config',
				-- TODO: should be 'object' but that is treated like a table now? I want
				-- a type that will simply copy the reference and not try to merge.
				kind = 'string'
			})
		end

		return field
	end



---
-- Return the appropriate "empty" value for this field. For simple value fields,
-- this will return nil. For collections, it will return an empty collection.
---

	function m.emptyValue(self)
		local value = nil

		if p.field.merges(self) then
			value = {}
		end

		return value
	end



---
-- Return true if `name` is a valid field name.
---

	function m.isFieldName(name)
		if p.field._list[name] or p.field._loweredList[name:lower()] then
			return true
		end
		return false
	end



---
-- Does this field support pattern matching against its values? If so, the
-- `field.matches()` method can be used, and the field can be used in filters.
---

	function m.isMatchable(self)
		local kinds = string.explode(self._kind, ':', true, 2)
		local kind = kinds[1]

		if kind == 'list' then
			kind = kinds[2]
		end

		if kind == 'list' or kind == 'table' or kind == 'keyed' then
			return false
		end

		return true
	end



---
-- Check to see if the provided pattern matches any of the provided
-- field values.
--
-- TODO: This should delegate out to a field type implementation. But
-- for now, just try to handle things in a general way.
---

	function m.matches(self, values, pattern)
		if type(values) == 'table' then
			local n = #values
			for i = 1, n do
				if values[i]:match(pattern) then
					return true
				end
			end
		else
			return values:match(pattern)
		end
	end



---
-- Merge new values into a field's existing value.
---

	function m.merge(self, currentValue, newValues)
		return p.field.merge(self, currentValue, newValues)
	end



---
-- Remove one or more values from a field's current values.
--
-- TODO: This should delegate out to a field type implementation. But
-- for now, just assume a table with keys and/or indices.
--
-- @param currentValue
--    The current value of the field.
-- @param removePattern
--    The value(s) to remove; can be a Lua pattern.
---

	function m.remove(self, currentValue, removePattern)
		local pattern = path.wildcards(removePattern):lower()

		local n = #currentValue
		for i = n, 1, -1 do
			local value = currentValue[i]
			local loweredValue = value:lower()
			if loweredValue:match(pattern) == loweredValue then
				currentValue[value] = nil
				table.remove(currentValue, i)
			end
		end

		return currentValue
	end



---
-- Turn a field value into a string for visualization during debugging.
-- TODO: Needs some work, obviously. Should delegate to the field type chain.
---

	function m.toString(self, value)
		local result = tostring(value)

		if type(value) == 'string' then
			result = '"' .. result .. '"'
		end

		return result
	end



---
-- End of module
---

	return m
