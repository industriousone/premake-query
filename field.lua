---
-- query/field.lua
--
-- An adapter between "what I think the Field module should look like" and
-- "what the field code looks like now."
--
-- Author Jason Perkins
-- Copyright (c) 2017 Jason Perkins and the Premake project
---

	local m = {}

	local p = premake


---
-- Retrieve a field by name. If no such field exists, synthesize a simple
-- assignment-only field on the fly.
---

	function m.get(name)
		local field = p.field.get(name)

		if field == nil then
			field = p.field.new({
				name = name,
				scope = "config",
				kind = "string"  -- TODO: should "object" but that is treated like a table now?
			})
		end

		return field
	end


---
-- End of module
---

	return m