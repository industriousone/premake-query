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

	function suite.fetch_returnsPrimitive_fromWorkspaceScope()
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
-- Fetching a list value using an open filter should inherit values from the
-- outer scope(s), while ignoring inner scopes.
---

	function suite.fetch_mergesLists_fromWorkspaceScope()
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

	function suite.fetch_mergesLists_fromWorkspaceScope()
		defines { 'GLOBAL' }
		workspace('MyWorkspace')
		defines { 'WORKSPACE' }
		project('MyProject')
		defines { 'PROJECT' }

		qry = query.filter(qry, {}, { workspaces='MyWorkspace' })

		local result = query.fetch(qry, 'defines')
		test.isequal({ 'WORKSPACE' }, result)
	end
