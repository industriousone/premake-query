---
-- query/query.lua
--
-- Queries process a list of configuration blocks, return values from those blocks
-- which meet certain criteria, or "filters". A filter is a key-value collection
-- of values that need to be matched by the filtering terms associated with each
-- configuration block.
--
--     -- Include only blocks from the 'Debug' configuration of 'Workspace1'
--     { workspaces='Workspace1', configurations='Debug' }
--
-- Queries use two different kinds of filters: "open" and "closed". An open filter
-- will pass if it matches the corresponding term on a configuration block, or if
-- there is no corresponding term on the configuration block (i.e. nil). It  will
-- fail if there is a conflicting value on a configuration block. If the above
-- query is treated as "open", it will match blocks with no workspace or
-- configuration (i.e. global scope), blocks with a matching workspace but no
-- configuration (i.e. workspace scope), blocks with a matching configuration but
-- no workspace, and blocks which match both workspace and configuration.
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
-- With this approach, any simple (non-list) field can be used in a filter.
---

	for fld in p.field.each() do
		if field.isSimpleType(fld) then
			criteria._validPrefixes[fld.name] = true
		end
	end



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
