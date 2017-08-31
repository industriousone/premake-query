---
-- query/query.lua
--
-- Author Jason Perkins
-- Copyright (c) 2017 Jason Perkins and the Premake project
---

	local m = {}

	local p = premake


---
-- Set up ":" style calling.
---

	local metatable =
	{
		__index = function(self, key)
			return m[key]
		end
	}


---
-- Construct a new Query object.
--
-- Queries are evaluated lazily. They are cheap to create and extend.
---

	function m.new(source)
		local self =
		{
			_configSet = source
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
		local value

		local field = p.field.get(key)

		if p.field.merges(field) then
			value = m.fetchCollection(self, field)
		else
			value = m.fetchPrimitive(self, field)
		end

		return value
	end



---
-- Fetch a collection (e.g. list, set) value, applying the previously
-- specified filtering criteria.
---

	function m.fetchCollection(self, field)
		return nil
	end



---
-- Fetch a primitive (e.g. string, number) value, applying the previously
-- specified filtering criteria.
---

	function m.fetchPrimitive(self, field)
		local blocks = self._configSet.blocks
		local key = field.name

		-- Walk the list of blocks backwards; exit on first value found
		local n = #blocks
		for i = n, 1, -1 do
			local block = blocks[i]
			local value = block[key]

			if value ~= nil then
				return value
			end
		end

		return nil
	end


---
-- End of module
--

	return m
