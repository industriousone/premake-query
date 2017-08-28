---
-- query/query.lua
--
-- Author Jason Perkins
-- Copyright (c) 2016-2017 Jason Perkins and the Premake project
---

local m = {}


---
-- Set up ":" style calling.
---

	local metatable = {
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
		local self = {
		}
		setmetatable(self, metatable)
		return self
	end


return m
