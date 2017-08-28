---
-- query/tests/test_query.lua
--
-- Author Jason Perkins
-- Copyright (c) 2016-2017 Jason Perkins and the Premake project
---

	local suite = test.declare("query")

	local p = premake

	local Query = require("query")


---
-- Setup
---

	local configSet

	function suite.setup()
		configSet = p.configset.new()
	end


---
-- Construct a new Query instance from an existing Context.
---

	function suite.new_fromContext()
		local ctx = p.context.new(configSet)
		local q = Query.new(ctx)
		test.isnotnil(q)
	end
