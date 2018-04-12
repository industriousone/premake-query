---
-- condition/tests/test_canMatchTerm.lua
--
-- Author Jason Perkins
-- Copyright (c) 2017 Jason Perkins and the Premake project
---

	local suite = test.declare('condition_canMatchTerm')

	local condition = require('condition')


	function suite.canMatchTerm_returnsTrue_onMatch()
		local cnd = condition.new({ workspaces='MyWorkspace' })
		test.istrue(condition.canMatchTerm(cnd, 'workspaces', 'MyWorkspace'))
	end


	function suite.canMatchTerm_returnsTrue_onMatch_usingOldSyntax()
		local cnd = condition.new({ 'workspaces:MyWorkspace' })
		test.istrue(condition.canMatchTerm(cnd, 'workspaces', 'MyWorkspace'))
	end


	function suite.canMatchTerm_returnsFalse_onNoMatch()
		local cnd = condition.new({ workspaces='MyWorkspace' })
		test.isfalse(condition.canMatchTerm(cnd, 'workspaces', 'OtherWorkspace'))
	end

