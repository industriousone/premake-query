---
-- query/tests/test_query.lua
--
-- Author Jason Perkins
-- Copyright (c) 2016 Jason Perkins and the Premake project
---

	local suite = test.declare('query')

	local p = premake

	local Query = require('query')



---
-- Setup
--
-- For now, queries are built on the existing `configset` data structure.
---


	local qry


	function suite.setup()
		qry = Query:new()
	end

	function suite.teardown()
		prebuildmessage(nil)
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
		local result = qry:fetch('prebuildmessage')
		test.isnil(result)
	end



---
-- Collection value fields should return an empty collection. I'm using knowledge
-- of Premake internals to query a field that I believe has not been set.
---

	function suite.fetch_returnsEmptyList_onUnsetListType()
		local result = qry:fetch('libdirs')
		test.isequal({}, result)
	end



---
-- A query with no filters should fetch values from the global scope. I'm using
-- knowledge of Premake internals to query field I believe should be set.
---

	function suite.fetch_returnsPrimitive_fromGlobalScopeOnNoFilters()
		local result = qry:fetch('rtti')
		test.isequal('Default', result)
	end
