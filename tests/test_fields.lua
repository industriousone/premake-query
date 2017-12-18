---
-- query/tests/test_query.lua
--
-- Author Jason Perkins
-- Copyright (c) 2016 Jason Perkins and the Premake project
---

	local suite = test.declare('query_fields')

	local p = premake

	local Query = require('query')


---
-- Setup
--
-- For now, queries are built on the existing `configset` data structure.
---

	local set, qry

	function suite.setup()
		set = p.configset.new()
		p.configset.addblock(set, {})

		qry = Query.new(set)
	end



---
-- Simplest test: fetch a primitive value with no filtering.
---

	function suite.fetch_simpleValue_noFiltering()
		p.configset.store(set, p.field.get('optimize'), 'Speed')
		test.isequal('Speed', qry:fetch('optimize'))
	end



---
-- Fetching a value from the global scope should exclude blocks with
-- more specific filters.
---

	function suite.fetch_excludesNonMatchingBlocks_onGlobalFetch()
		p.configset.store(set, p.field.get('optimize'), 'Speed')

		p.configset.addblock(set, { configurations='Release' })
		p.configset.store(set, p.field.get('optimize'), 'Debug')

		test.isequal('Speed', qry:fetch('optimize'))
	end



---
-- Try adding a single filtering term to the query; should only match
-- data blocks with matching filter terms.
---

	function suite.fetch_withSimpleSingleTermFilter()
		p.configset.addblock(set, { configurations='Debug' })
		p.configset.store(set, p.field.get('optimize'), 'Debug')

		p.configset.addblock(set, { configurations='Release' })
		p.configset.store(set, p.field.get('optimize'), 'Speed')

		qry = qry:filter({ configurations='Debug' })
		test.isequal('Debug', qry:fetch('optimize'))
	end



---
-- It should be possible to filter against values that have been collected
-- from earlier data blocks.
---

	function suite.fetch_canFilterAgainstDataValues()
		p.configset.store(set, p.field.get('kind'), 'SharedLib')

		p.configset.addblock(set, { kind='StaticLib' })
		p.configset.store(set, p.field.get('optimize'), 'Speed')

		p.configset.addblock(set, { kind='SharedLib' })
		p.configset.store(set, p.field.get('optimize'), 'Debug')

		p.configset.addblock(set, { kind='ConsoleApp' })
		p.configset.store(set, p.field.get('optimize'), 'Size')

		test.isequal('Debug', qry:fetch('optimize'))
	end



---
-- Values specified on the filter should not conflict with data collected
-- from the script.
---

	function suite.fetch_onFilterAndDataKeyCollision()
		p.configset.store(set, p.field.get('configurations'), { 'Debug', 'Release'})

		p.configset.addblock(set, { configurations='Debug' })
		p.configset.store(set, p.field.get('optimize'), 'Debug')

		qry = qry:filter({ configurations='Debug' })
		test.isequal('Debug', qry:fetch('optimize'))
	end



---
-- Try fetching a simple array of values.
---

	function suite.fetch_simpleArray()
		p.configset.store(set, p.field.get('defines'), { 'A', 'B'})
		test.isequal({ 'A', 'B' }, qry:fetch('defines'))
	end



---
-- Try merging an array from multiple scopes.
---

	function suite.fetch_shouldMergeArrays()
		p.configset.store(set, p.field.get('defines'), { 'A', 'B'})

		p.configset.addblock(set, { configurations='Debug' })
		p.configset.store(set, p.field.get('defines'), { 'C', 'D' })

		qry = qry:filter({ configurations='Debug' })
		test.isequal({ 'A', 'B', 'C', 'D' }, qry:fetch('defines'))
	end



---
-- If no value is set for a simple value field, should return nil.
---

	function suite.fetch_shouldReturnNil_whenNoSimpleValueSet()
		test.isnil(qry:fetch('language'))
	end



---
-- If no value is set for a list field, should return an empty list.
---

	function suite.fetch_shouldReturnEmptyCollection_whenNoCollectionValueSet()
		test.isequal({ }, qry:fetch('defines'))
	end




-- TODO: Test wildcards in the configset filter
-- TODO: Test `not`
-- TODO: Test `or`
