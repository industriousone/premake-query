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


	m.simpleFieldTypes = {
		['boolean'] = true,
		['directory'] = true,
		['file'] = true,
		['integer'] = true,
		['mixed'] = true,
		['number'] = true,
		['path'] = true,
		['string'] = true,
	}


---
-- Retrieve a field by name. If no such field exists, synthesize a simple
-- assignment-only field on the fly.
---

	function m.get(name)
		local field = p.field.get(name)

		if field == nil then
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
-- Returns true if the field uses a simple (not a collection) data type.
---

	function m.isSimpleType(self)
		local value = m.simpleFieldTypes[self._kind]
		return value
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
