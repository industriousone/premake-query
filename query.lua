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
			_source = source,
			_configSet = source._cfgset or source,
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
-- making changes!
--
-- Note that unlike fetching values by dot notation (e.g. `cfg.name`),
-- calls to `fetch()` do not cache their results, and always perform a
-- full lookup.
---

	function m.fetch(self, key)
		local result

		local field = p.field.get(key)

		-- TODO: If I haven't already, walk the list of available blocks and
		-- filter them down to only those that meet my filtering criteria. This
		-- should only be done once, on the first call to `fetch()`. Note that
		-- there is no filter precedence like in the old implementation, just
		-- walk the blocks in order and apply the filters based on whatever
		-- the current environment happens to be at that point.

		local blocks = self._configSet.blocks

		-- TODO: Put back reverse search for primitive fields?

		local n = #blocks
		for i = 1, n do
			local block = blocks[i]
			local value = block[key]

			if value ~= nil then
				result = value
			end
		end

		-- HACK: The current implementation stores some values directly on
		-- the "container", rather than in a configuration block.
		-- TODO: Store all settings in configuration blocks.

		if not result then
			result = self._source[key]
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
-- End of module
---

	return m