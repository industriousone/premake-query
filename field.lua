---
-- query/field.lua
--
-- An adapter between "what I think the Field module should look like" and
-- "what the field code looks like now."
--
-- Author Jason Perkins
-- Copyright (c) 2017 Jason Perkins and the Premake project
---

	local p = premake

	local Field = {}
	local m = {}


	local metatable = {
		__index = m
	}


---
-- Return the appropriate "empty" value for this field. For simple value fields,
-- this will return nil. For collections, it will return an empty collection.
---

	function m:emptyValue()
		local value = nil

		if p.field.merges(self) then
			value = {}
		end

		return value
	end



---
-- Turn a field value into a string for visualization during debugging.
-- TODO: Needs some work, obviously. Should delegate to the field type chain.
---

	function m:toString(value)
		local result = tostring(value)

		if type(value) == 'string' then
			result = '"' .. result .. '"'
		end

		return result
	end



---
-- Retrieve a field by name. If no such field exists, synthesize a simple
-- assignment-only field on the fly.
---

	function Field:get(name)
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

		if getmetatable(field) == nil then
			setmetatable(field, metatable)
		end

		return field
	end


---
-- End of module
---

	return Field
