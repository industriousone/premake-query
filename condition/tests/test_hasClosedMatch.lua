---
-- condition/tests/test_hasClosedMatch.lua
--
-- Author Jason Perkins
-- Copyright (c) 2017 Jason Perkins and the Premake project
---

	local suite = test.declare('condition_hasClosedMatch')

	local condition = require('condition')



---
-- Closed values require a positive match with the condition.
---

	function suite.hasClosedMatch_returnsTrue_onExactMatch()
		local cnd = condition.new({ workspaces='MyWorkspace' })
		test.istrue(condition.hasClosedMatch(cnd, 'workspaces', 'MyWorkspace'))
	end


	function suite.hasClosedMatch_returnsTrue_onPatternMatch()
		local cnd = condition.new({ workspaces='My.+' })
		test.istrue(condition.hasClosedMatch(cnd, 'workspaces', 'MyWorkspace'))
	end



---
-- If there no is clause on the condition which can match the term, return false.
-- This is what makes the match "closed" (an open match would pass so long as there
-- is no _conflicting_ clause).
---

	function suite.hasClosedMatch_returnsFalse_onNoMatchingClause()
		local cnd = condition.new({ workspaces='MyWorkspace' })
		test.isfalse(condition.hasClosedMatch(cnd, 'projects', 'MyProject'))
	end


---
-- If a clause exists for the term, but it has a conflicting pattern, return false.
---

	function suite.hasClosedMatch_returnsFalse_onValueMismatch()
		local cnd = condition.new({ workspaces='MyWorkspace' })
		test.isfalse(condition.hasClosedMatch(cnd, 'workspaces', 'OtherProject'))
	end
