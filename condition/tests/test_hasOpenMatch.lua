---
-- condition/tests/test_hasOpenMatch.lua
--
-- Author Jason Perkins
-- Copyright (c) 2017 Jason Perkins and the Premake project
---

	local suite = test.declare('condition_hasOpenMatch')

	local condition = require('condition')



---
-- If a matching clause is found, return true.
---

	function suite.hasOpenMatch_returnsTrue_onExactMatch()
		local cnd = condition.new({ workspaces='MyWorkspace' })
		test.istrue(condition.hasOpenMatch(cnd, 'workspaces', 'MyWorkspace'))
	end


	function suite.hasOpenMatch_returnsTrue_onPatternMatch()
		local cnd = condition.new({ workspaces='My.+' })
		test.istrue(condition.hasOpenMatch(cnd, 'workspaces', 'MyWorkspace'))
	end



---
-- Open values match so long as there is no _conflicting_ clause. If there is
-- no clause which matches the term, return true.
---

	function suite.hasOpenMatch_returnsFalse_onNoMatchingClause()
		local cnd = condition.new({ workspaces='MyWorkspace' })
		test.istrue(condition.hasOpenMatch(cnd, 'projects', 'MyProject'))
	end



---
-- If a clause exists for the term, but it has a conflicting pattern, return false.
---

	function suite.hasOpenMatch_returnsFalse_onValueMismatch()
		local cnd = condition.new({ workspaces='MyWorkspace' })
		test.isfalse(condition.hasOpenMatch(cnd, 'workspaces', 'OtherWorkspace'))
	end
