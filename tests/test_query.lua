---
-- query/tests/test_query.lua
--
-- Author Jason Perkins
-- Copyright (c) 2017 Jason Perkins and the Premake project
---

	local suite = test.declare('query')

	local query = require('query')


---
-- Setup and teardown.
---


	local qry


	function suite.setup()
		qry = query.new()
	end


---
-- Primitive value fields which have not been set should return nil. I'm using
-- knowledge of Premake internals to query a field that I believe has not been set.
---

	function suite.fetch_returnsNil_onUnsetPrimitiveType()
		local result = query.fetch(qry, 'prebuildmessage')
		test.isnil(result)
	end


---
-- Collection value fields should return an empty collection. I'm using knowledge
-- of Premake internals to query a field that I believe has not been set.
---

	function suite.fetch_returnsEmptyList_onUnsetListType()
		local result = query.fetch(qry, 'libdirs')
		test.isequal({}, result)
	end


---
-- A query with no filters should fetch values from the global scope.
---

	function suite.fetch_returnsPrimitive_fromGlobalScope()
		rtti('On')
		local result = query.fetch(qry, 'rtti')
		test.isequal('On', result)
	end


---
-- Should be able to fetch simple values set in a workspace scope.
---

	function suite.fetch_returnsPrimitive_fromWorkspaceScope()
		workspace('MyWorkspace')
		rtti('On')
		project('MyProject')
		rtti('Off')

		qry = query.filter(qry, { workspaces='MyWorkspace' })

		local result = query.fetch(qry, 'rtti')
		test.isequal('On', result)
	end


---
-- Should be able to fetch simple values set in a project scope.
---

	function suite.fetch_returnsPrimitive_fromProjectScope()
		workspace('MyWorkspace')
		rtti('On')
		project('MyProject')
		rtti('Off')

		qry = query.filter(qry, { workspaces='MyWorkspace', projects='MyProject' })

		local result = query.fetch(qry, 'rtti')
		test.isequal('Off', result)
	end


---
-- When the workspace scope is specified as as open filter, values from the
-- global scope should be inherited.
---

	function suite.fetch_inheritsGlobalInWorkspace_onOpenFilter()
		workspace('MyWorkspace')

		qry = query.filter(qry, { workspaces='MyWorkspace' })

		local result = query.fetch(qry, 'rtti')
		test.isequal('Default', result)
	end


---
-- When the workspace scope if specified as as closed filter, values from the
-- global scope should not be inherited.
---

	function suite.fetch_doesNotInheritGlobalInWorkspace_onClosedFilter()
		workspace('MyWorkspace')

		qry = query.filter(qry, {}, { workspaces='MyWorkspace' })

		local result = query.fetch(qry, 'rtti')
		test.isnil(result)
	end


---
-- Should be able to fetch values from a project scope, inheriting values
-- from the workspace.
---

	function suite.fetch_projectScope_withInheritance()
		defines { 'GLOBAL' }
		workspace('MyWorkspace')
		defines { 'WORKSPACE' }
		project('MyProject')
		defines { 'PROJECT' }

		qry = query.filter(qry, { workspaces='MyWorkspace', projects='MyProject' })

		local result = query.fetch(qry, 'defines')
		test.isequal({ 'GLOBAL', 'WORKSPACE', 'PROJECT' }, result)
	end


---
-- Should be able to fetch values from a project scope, with no inheritance
-- from the workspace.
---

	function suite.fetch_projectScope_withoutInheritance()
		defines { 'GLOBAL' }
		workspace('MyWorkspace')
		defines { 'WORKSPACE' }
		project('MyProject')
		defines { 'PROJECT' }

		qry = query.filter(qry, { workspaces='MyWorkspace' }, { projects='MyProject' })

		local result = query.fetch(qry, 'defines')
		test.isequal({ 'PROJECT' }, result)
	end


---
-- Should be able to fetch values from a file scope, inheriting values
-- from the project.
---

	function suite.fetch_fileScope_withInheritance()
		defines { 'GLOBAL' }
		workspace('MyWorkspace')
		defines { 'WORKSPACE' }
		project('MyProject')
		defines { 'PROJECT' }
		filter { 'files:**.c' }
		defines { 'FILE' }

		qry = query.filter(qry, { workspaces='MyWorkspace', projects='MyProject', files='hello.c' })

		local result = query.fetch(qry, 'defines')
		test.isequal({ 'GLOBAL', 'WORKSPACE', 'PROJECT', 'FILE' }, result)
	end


---
-- Should be able to fetch values from a project scope, with no inheritance
-- from the workspace.
---

	function suite.fetch_fileScope_withoutInheritance()
		defines { 'GLOBAL' }
		workspace('MyWorkspace')
		defines { 'WORKSPACE' }
		project('MyProject')
		defines { 'PROJECT' }
		filter { 'files:**.c' }
		defines { 'FILE' }

		qry = query.filter(qry, { workspaces='MyWorkspace', projects='MyProject' }, { files='hello.c' })

		local result = query.fetch(qry, 'defines')
		test.isequal({ 'FILE' }, result)
	end


---
-- Fetching a list value using an open filter should inherit values from the
-- outer scope(s), while ignoring inner scopes.
---

	function suite.fetch_mergesLists_fromWorkspaceScope_usingOpenFilter()
		defines { 'GLOBAL' }
		workspace('MyWorkspace')
		defines { 'WORKSPACE' }
		project('MyProject')
		defines { 'PROJECT' }

		qry = query.filter(qry, { workspaces='MyWorkspace' })

		local result = query.fetch(qry, 'defines')
		test.isequal({ 'GLOBAL', 'WORKSPACE' }, result)
	end


---
-- Fetching a list value using a closed filter should only include values
-- from that specific scope.
---

	function suite.fetch_mergesLists_fromWorkspaceScope_onClosedFilter()
		defines { 'GLOBAL' }
		workspace('MyWorkspace')
		defines { 'WORKSPACE' }
		project('MyProject')
		defines { 'PROJECT' }

		qry = query.filter(qry, {}, { workspaces='MyWorkspace' })

		local result = query.fetch(qry, 'defines')
		test.isequal({ 'WORKSPACE' }, result)
	end


---
-- Blocks with criteria that aren't met by the query or the data
-- should be ignored.
---

	function suite.fetch_ignoresBlocksWithUnmatchedCriteria()
		defines { 'GLOBAL' }
		workspace('MyWorkspace')
		defines { 'WORKSPACE' }
		filter { 'configurations:Debug' }
		defines { 'DEBUG' }

		qry = query.filter(qry, { workspaces='MyWorkspace' }, {})

		local result = query.fetch(qry, 'defines')
		test.isequal({ 'GLOBAL', 'WORKSPACE' }, result)
	end


---
-- Blocks with conflicting conditions should be ignored.
---

	function suite.fetch_ignoresBlocksWithMismatchedScopes()
		defines { 'GLOBAL' }
		workspace('MyWorkspace')
		defines { 'WORKSPACE' }
		filter { 'configurations:Debug' }
		defines { 'DEBUG' }

		qry = query.filter(qry, { workspaces='MyOtherWorkspace' }, {})

		local result = query.fetch(qry, 'defines')
		test.isequal({ 'GLOBAL' }, result)
	end


---
-- Should be able to remove values set at the global scope.
---

	function suite.fetch_removes_fromGlobalScopes()
		defines { 'A', 'B', 'C' }
		removedefines { 'B' }

		local result = query.fetch(qry, 'defines')
		test.isequal({ 'A', 'C' }, result)
	end


---
-- Should be able to remove values using wildcards.
---

	function suite.fetch_removes_withWildcard()
		defines { 'DEBUG_DLL', 'DEBUG_LIB' }
		removedefines { '*_LIB' }

		local result = query.fetch(qry, 'defines')
		test.isequal({ 'DEBUG_DLL' }, result)
	end


---
-- Values that are set at a general scope, and then removed at a more
-- specific scope, should not appear at the general scope.
---

	function suite.fetch_removes_considersMoreSpecificScopes()
		defines { 'GLOBAL', 'WORKSPACE', 'PROJECT', 'FILE' }
		workspace('MyWorkspace')
		removedefines { 'WORKSPACE' }
		project('MyProject')
		removedefines { 'PROJECT' }
		filter { 'files:**.c' }
		removedefines { 'FILE' }

		local result = query.fetch(qry, 'defines')
		test.isequal({ 'GLOBAL' }, result)
	end


---
-- If a value is removed from only one of several sibling scopes, the
-- query should include the value only that sibling, and not the others.
---

	function suite.fetch_removes_onlyFromMostSpecifcScope()
		defines { 'A', 'B', 'C' }
		workspace('Workspace1')
		workspace('Workspace2')
		removedefines('B')
		workspace('Workspace3')

		qry = query.filter(qry, { workspaces='Workspace1' })
		local result = query.fetch(qry, 'defines')
		test.isequal({ 'A', 'B', 'C' }, result)

		qry = query.filter(qry, { workspaces='Workspace2' })
		local result = query.fetch(qry, 'defines')
		test.isequal({ 'A', 'C' }, result)

		qry = query.filter(qry, { workspaces='Workspace3' })
		local result = query.fetch(qry, 'defines')
		test.isequal({ 'A', 'B', 'C' }, result)
	end


---
-- Should be able to filter against simple (non-list) field values that were
-- previously set in an earlier configuration block.
---

	function suite.fetch_onArbitrarySimpleField_previouslySet()
		workspace('Workspace1')
		project('Project1')
		kind('SharedLib')
		filter { 'kind:SharedLib' }
		defines('SHAREDLIB')
		filter { 'kind:StaticLib' }
		defines('STATICLIB')

		qry = query.filter(qry, { workspaces='Workspace1', projects='Project1' })
		local result = query.fetch(qry, 'defines')
		test.isequal({ 'SHAREDLIB' }, result)
	end


---
-- Should be able to filter against simple (non-list) field values that were
-- not available for filtering in the previous system.
---

	function suite.fetch_onArbitrarySimpleField_previouslyIncompatible()
		workspace('Workspace1')
		project('Project1')
		optimize('Speed')
		filter { 'optimize:Speed' }
		defines('FAST')
		filter { 'optimize:Size' }
		defines('SIZE')

		qry = query.filter(qry, { workspaces='Workspace1', projects='Project1' })
		local result = query.fetch(qry, 'defines')
		test.isequal({ 'FAST' }, result)
	end


---
-- Should be able to filter against collection field values that were previously
-- set in an earlier configuration block.
---

	function suite.fetch_onArbitraryCollectionField_previouslySet()
		workspace('Workspace1')
		project('Project1')
		tags { 'a1', 'a2', 'b1' }
		filter { 'tags:a2' }
		defines('A2')

		qry = query.filter(qry, { workspaces='Workspace1', projects='Project1' })
		local result = query.fetch(qry, 'defines')
		test.isequal({ 'A2' }, result)
	end

	function suite.fetch_onArbitraryCollectionField_onMismatch()
		workspace('Workspace1')
		project('Project1')
		tags { 'a1', 'a2', 'b1' }
		filter { 'tags:b2' }
		defines('B2')

		qry = query.filter(qry, { workspaces='Workspace1', projects='Project1' })
		local result = query.fetch(qry, 'defines')
		test.isequal({}, result)
	end

	function suite.fetch_onArbitraryCollectionField_previouslyIncompatible()
		workspace('Workspace1')
		project('Project1')
		defines { 'A1', 'A2' }
		filter { 'defines:A2' }
		defines('X2')

		qry = query.filter(qry, { workspaces='Workspace1', projects='Project1' })
		local result = query.fetch(qry, 'defines')
		test.isequal({ 'A1', 'A2', 'X2' }, result)
	end


---
-- Filters should fail if they specify a non-existant field.
---

	function suite.filter_fails_onNoSuchField()
		local ok, err = pcall(function ()
			filter { 'nosuchfield:value' }
		end)
		test.isfalse(ok)
	end


---
-- Filters should fail if they specify a field that does not support pattern matching.
---

	function suite.filter_fails_onNoPatternMatchingSupport()
		local ok, err = pcall(function ()
			filter { 'vpaths:value' }
		end)
		test.isfalse(ok)
	end
