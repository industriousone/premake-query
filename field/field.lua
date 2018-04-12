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
-- Merge new values into a field's existing value.
---

	function m.merge(self, currentValue, newValues)
		return p.field.merge(self, currentValue, newValues)
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
