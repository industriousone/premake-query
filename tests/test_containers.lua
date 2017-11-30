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



-- ---
-- -- Verify that values can be fetched directly off the container object.
-- ---

-- 	function suite.fetch_directSetSourceValue()
-- 		local wks = workspace('MyWorkspace')
-- 		local qry = Query.new(wks)
-- 		test.isequal('MyWorkspace', qry:fetch('name'))
-- 	end



-- ---
-- -- It should eventually be possible to specify containers like any other list
-- -- value, e.g. `workspaces { 'Workspace1', 'Workspace2', 'Workspace3' }`. Make
-- -- pretend that queries can present the container collections in that fashion.
-- ---

-- 	function suite.fetch_workspacesFromGlobalScope()
-- 		workspace('Workspace1')
-- 		workspace('Workspace2')
-- 		workspace('Workspace3')

-- 		local qry = Query.new(p.api.scope.global)

-- 		local result = qry:fetch('workspaces')
-- 		test.isequal({ 'Workspace1', 'Workspace2', 'Workspace3' }, result)
-- 	end


-- 	function suite.fetch_projectsFromWorkspace()
-- 		local wks1 = workspace('Workspace1')
-- 		project('Project1')
-- 		project('Project2')
-- 		workspace('Workspace2')
-- 		project('Project3')

-- 		local q = Query.new(wks1)

-- 		local result = q:fetch('projects')
-- 		test.isequal({ 'Project1', 'Project2' }, result)
-- 	end



-- ---
-- -- Container fetches should behave just like other values, and not drill
-- -- down into more specific scopes.
-- ---

-- 	function suite.fetch_doesNotReturnChildContainers()
-- 		workspace('Workspace1')
-- 		project('Project1')
-- 		project('Project2')

-- 		local q = Query.new(p.api.scope.global)

-- 		local result = q:fetch('projects')
-- 		test.isequal({}, result)
-- 	end



-- ---
-- -- It should be possible to narrow a query to specific container.
-- ---

-- 	function suite.filter_canSelectWorkspace()
-- 		workspace('Workspace1')
-- 		workspace('Workspace2')

-- 		local qry = Query.new(p.api.scope.global)
-- 		local wks = qry:filter({ workspaces='Workspace1' })

-- 		local result = wks:fetch('name')
-- 		test.isequal('Workspace1', result)
-- 	end


-- 	function suite.filter_canSelectProject_fromGlobalScope()
-- 		workspace('Workspace1')
-- 		project('Project1')
-- 		workspace('Workspace2')
-- 		project('Project2')

-- 		local qry = Query.new(p.api.scope.global)
-- 		local wks = qry:filter({ workspaces='Workspace1', projects='Project1' })

-- 		local result = wks:fetch('name')
-- 		test.isequal('Project1', result)
-- 	end


-- 	function suite.filter_canSelectProject_fromWorkspaceScope()
-- 		local wks1 = workspace('Workspace1')
-- 		project('Project1')
-- 		workspace('Workspace2')
-- 		project('Project2')

-- 		local qry = Query.new(wks1)
-- 		local wks = qry:filter({ projects='Project1' })

-- 		local result = wks:fetch('name')
-- 		test.isequal('Project1', result)
-- 	end



-- ---
-- -- If the target container doesn't exist, should return no results.
-- ---

-- 	function suite.filter_returnsEmptyResult_onMissingContainer()
-- 		workspace('Workspace1')
-- 		workspace('Workspace2')

-- 		local qry = Query.new(p.api.scope.global)
-- 		local wks = qry:filter({ workspaces='Workspace8' })

-- 		local result = wks:fetch('name')
-- 		test.isnil(result)
-- 	end
