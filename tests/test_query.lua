---
-- query/tests/test_query.lua
--
-- Author Jason Perkins
-- Copyright (c) 2016 Jason Perkins and the Premake project
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
-- Make sure we can create a Query instance without issues.
---

	function suite.canConstructNewInstance()
		test.isnotnil(qry)
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



-- ---
-- -- A query with no filters should fetch values from the global scope.
-- ---

	function suite.fetch_returnsPrimitive_fromGlobalScopeWithNoFilters()
		rtti('On')
		local result = query.fetch(qry, 'rtti')
		test.isequal('On', result)
	end



---
-- Should be able to fetch values set in a workspace scope.
---

	function suite.fetch_returnsPrimitive_fromWorkspaceScopeWithNoFilters()
		workspace('MyWorkspace')
		rtti('On')
		project('MyProject')
		rtti('Off')

		qry = query.filter(qry, { workspace='MyWorkspace' })

		local result = query.fetch(qry, 'rtti')
		test.isequal('On', result)
	end



-- ---
-- -- When the workspace scope is specified as as open filter, values from the
-- -- global scope should be inherited.
-- ---

-- 	function suite.fetch_inheritsGlobalInWorkspace_onOpenFilter()
-- 		workspace('MyWorkspace')

-- 		local result = qry
-- 			:filter({ workspace='MyWorkspace' }, {})
-- 			:fetch('rtti')

-- 		test.isequal('Default', result)
-- 	end



-- ---
-- -- When the workspace scope if specified as as closed filter, values from the
-- -- global scope should not be inherited.
-- ---

-- 	function suite.fetch_doesNotInheritGlobalInWorkspace_onClosedFilter()
-- 		workspace('MyWorkspace')

-- 		local result = qry
-- 			:filter({}, { workspace='MyWorkspace' })
-- 			:fetch('rtti')

-- 		test.isnil(result)
-- 	end

