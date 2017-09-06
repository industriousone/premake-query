---
-- query/tests/test_query.lua
--
-- Author Jason Perkins
-- Copyright (c) 2016 Jason Perkins and the Premake project
---

	local suite = test.declare("query")

	local p = premake

	local Query = require("query")


---
-- Setup
---

	function suite.setup()
	end


---
-- Construct a new Query instance from an existing Context.
---

	function suite.new_fromContext()
		local ctx = p.context.new(configSet)
		local q = Query.new(ctx)
		test.isnotnil(q)
	end


---
-- Simplest test: fetch a primitive value with no filtering.
---

	function suite.fetch_simpleValue_noFiltering()
		local optimize = p.field.get("optimize")

		local set = p.configset.new()
		p.configset.store(set, optimize, "Speed")

		local q = Query.new(set)
		test.isequal("Speed", q.optimize)
	end


---
-- Fetch a simple value from the most specific scope.
---

	function suite.fetch_simpleValue_fromMixedScopes()
		-- optimize "Off"
		-- filter { configurations = "Debug" } optimize "Debug"
		-- filter { files = "filename" } optimize "Speed"  <------ could maybe do files in a separate test
		-- filter {} optimize "On"
		-- query for { configuration="Debug", files="filename"}
		-- assert "Speed"

		-- configset.addblock(cset, { configurations="Debug" })
		-- configset.store(cset, p.fields.optimize, "Debug")

		-- local q = Query.new(cset).filter({ configuration="Debug", files="filename"})
		-- test.isequal("Speed", q.optimize)
	end


-- TODO: Synthesize queries for workspaces, projects, rules, etc.?
