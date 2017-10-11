---
-- query/tests/test_containers.lua
--
-- Containers are currently a special case: they hold configurable information
-- related to the container itself, but they don't follow the same patterns as
-- the "regular" configuration blocks. Verify that queries are able access this
-- container information in a transparent way.
--
-- Author Jason Perkins
-- Copyright (c) 2017 Jason Perkins and the Premake project
---

	local suite = test.declare("query_containers")

	local p = premake

	local Query = require("query")


---
-- Verify that values can be fetched directly off the container object.
---

	function suite.fetch_directSetSourceValue()
		local wks = workspace("MyWorkspace")
		local q = Query.new(wks)
		test.isequal("MyWorkspace", q:fetch("name"))
	end



---
-- It should eventually be possible to specify containers like any other list
-- value, e.g. `workspaces { "Workspace1", "Workspace2", "Workspace3" }`. Make
-- that queries can present the container collections in that fashion.
---

	function suite.fetch_workspacesFromGlobalScope()
		workspace("Workspace1")
		workspace("Workspace2")
		workspace("Workspace3")

		local q = Query.new(p.api.scope.global)

		local result = q:fetch("workspaces")
		test.isequal({ "Workspace1", "Workspace2", "Workspace3" }, result)
	end


	function suite.fetch_projectsFromGlobalScope()
		workspace("Workspace1")
		project("Project1")

		local q = Query.new(p.api.scope.global)

		local result = q:fetch("projects")
		test.isequal({}, result)
	end



	-- function suite.filter_canSelectSingleWorkspace()
	-- 	workspace("Workspace1")
	-- 	workspace("Workspace2")

	-- 	local qry = Query.new(p.api.scope.global)
	-- 	local wks = qry:filter({ workspaces="Workspace1" })

	-- 	local result = wks:fetch("name")
	-- 	test.isequal("Workspace1", result)
	-- end


	-- function suite.fetch_projectsForSpecificWorkspace()
	-- 	local wks = workspace("Workspace1")
	-- 	project("Project1")
	-- 	project("Project2")
	-- 	workspace("Workspace2")
	-- 	project("Project3")

	-- 	local wks = Query.new(wks)
	-- 	local result = wks:fetch("projects")
	-- 	test.isequal({ "Project1", "Project2" }, result)
	-- end

