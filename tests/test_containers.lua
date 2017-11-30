---
-- query/tests/test_containers.lua
--
-- Containers are currently a special case: they hold configurable information
-- related to the container itself, but they don't follow the same patterns as
-- the 'regular' configuration blocks. Verify that queries are able access this
-- container information in a transparent way.
--
-- Author Jason Perkins
-- Copyright (c) 2017 Jason Perkins and the Premake project
---

	local suite = test.declare('query_containers')

	local p = premake

	local Query = require('query')


---
-- Setup
---

	local q

	function suite.setup()
		q = Query.new(premake.api.scope.global)
	end



---
-- Should be able to construct a query from the scripted settings.
---

	function suite.canConstructFromScriptedSettings()
		test.isnotnil(q)
	end



---
-- Should be able to query a list of workspaces as they had been originally
-- specified as a list of strings (which should eventually be possible).
---

	function suite.fetch_workspacesAsStringList()
		workspace('Workspace1')
		workspace('Workspace2')
		workspace('Workspace3')

		local workspaces = q:fetch('workspaces')
		test.isequal({ 'Workspace1', 'Workspace2', 'Workspace3' }, workspaces)
	end



---
-- Should be able to narrow filter to a specific workspace.
---

	function suite.fetch_filterSpecificWorkspace()
		workspace('MyWorkspace')

		local wks = q:filter({ workspaces = 'MyWorkspace' })
		test.isequal('MyWorkspace', wks:fetch('name'))
	end



---
-- Should be able to query a list of projects from a workspace.
---

	function suite.fetch_projectsFromWorkspaceAsStringList()
		workspace('Workspace1')
		project('Project1')
		project('Project2')
		workspace('Workspace2')
		project('Project3')

		local wks = q:filter({ workspaces = 'Workspace1' })
		local projects = wks:fetch('projects')

		test.isequal({ 'Project1', 'Project2' }, projects)
	end



---
-- If the target container doesn't exist, should return an empty result set.
---

	function suite.filter_returnsEmptyResult_onMissingContainer()
		workspace('Workspace1')

		local wks = q:filter({ workspaces = 'Workspace8' })

		local result = wks:fetch('name')
		test.isnil(result)
	end
