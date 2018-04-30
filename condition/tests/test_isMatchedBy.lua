---
-- condition/tests/test_isMatchedBy.lua
--
-- Author Jason Perkins
-- Copyright (c) 2017 Jason Perkins and the Premake project
---

	local suite = test.declare('condition_isMatchedBy')

	local condition = require('condition')


---
-- A condition with no clauses should always match.
---

	function suite.isMatchedBy_returnsTrue_onNoClauses()
		local data = {}
		local open = {}
		local closed = {}

		local cnd = condition.new({})
		test.istrue(condition.isMatchedBy(cnd, data, open, closed))
	end



---
-- Should return false if a term required by the condition can't be matched by
-- any of the data sources.
---

	function suite.isMatchedBy_returnsFalse_onUnmatchedBlockPattern()
		local data = {}
		local open = {}
		local closed = {}

		local cnd = condition.new({ workspaces='MyWorkspace' })
		test.isfalse(condition.isMatchedBy(cnd, data, open, closed))
	end



---
-- Should return true if a matching value is found in any data source.
---

	function suite.isMatchedBy_returnsTrue_onClosedTermMatch()
		local data = {}
		local open = {}
		local closed = { workspaces='MyWorkspace' }

		local cnd = condition.new({ workspaces='MyWorkspace' })
		test.istrue(condition.isMatchedBy(cnd, data, open, closed))
	end



	function suite.isMatchedBy_returnsTrue_onOpenTermMatch()
		local data = {}
		local open = { workspaces='MyWorkspace' }
		local closed = {}

		local cnd = condition.new({ workspaces='MyWorkspace' })
		test.istrue(condition.isMatchedBy(cnd, data, open, closed))
	end



	function suite.isMatchedBy_returnsTrue_onDataMatch()
		local data = { workspaces='MyWorkspace' }
		local open = {}
		local closed = {}

		local cnd = condition.new({ workspaces='MyWorkspace' })
		test.istrue(condition.isMatchedBy(cnd, data, open, closed))
	end

