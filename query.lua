---
-- query/query.lua
--
-- Author Jason Perkins
-- Copyright (c) 2017 Jason Perkins and the Premake project
---

	local m = {}

	local p = premake


---
-- Set up ":" style calling for methods, and "." style accessors for field values.
---

	local metatable =
	{
		__index = function(self, key)
			local value = m[key]

			if not value then
				value = self:fetch(key)
				rawset(self, key, value)
			end

			return value
		end
	}


---
-- Construct a new Query object.
--
-- Queries are evaluated lazily. They are cheap to create and extend.
---

	function m.new(source, terms)
		local self =
		{
			_configSet = source,
			_terms = terms or {}
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
-- making changes, and be on your best behavior!
---

	function m.fetch(self, key)
		local result

		local field = m._field_get(key)

		local blocks = self._configSet.blocks

		local n = #blocks
		for i = 1, n do
			local block = blocks[i]
			local value = block[key]

			if value ~= nil then
				result = value
			end
		end

		return result
	end



---
-- Narrow an existing query with additional filtering terms.
---

	function m.filter(self, terms)
		local mergedTerms = table.merge(self._terms, terms)
		local q = m.new(self._configSet, mergedTerms)
		return q
	end



---
-- Field helper: Fetch a Field definition by name.
-- TODO: Integrate this into the Field system when that gets moved into a module.
---

	function m._field_get(key)
		local field = p.field.get(key)

		-- if there is no such field, synthesize a custom definition for a simple
		-- primitive value, using the provided name
		if not field then
			field = p.field.new({
				name = key,
				scope = "config",
				kind = "string"
			})
		end

		return field
	end



---
-- End of module
--

	return m