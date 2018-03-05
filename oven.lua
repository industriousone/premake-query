---
-- query/oven.lua
--
-- Preprocess the existing hierarchical configuration container setup into flat
-- lists that are easier to evaluate.
--
-- This is what things look like in the configuration container hierarchy: it starts
-- with a "global" container that contains blocks of configuration data, along with
-- "workspace" and "rule" containers. These containers in turn contain more blocks
-- and more containers.
--
--   [ Global container ]
--       [ Block #1 : filter {} ]
--       [ Container : name "MyWorkspace" ]
--           [ Block #2 : filter {} ]
--           [ Block #3 : filter { "configuration:Debug"}]
--           [ Project container : name "MyProject"]
--               [ Block #4 : filter {} ]
--               [ Block #5 : filter { "configuration:Debug"}]
--
-- Going forward, the new query system works better if everything is flattened out,
-- and the scopes are listed as part of the filter, rather than appearing as a
-- separate data structure:
--
--   [ Block #1 : filter {} ]
--   [ Block #2 : filter { "workspaces:MyWorkspace" } ]
--   [ Block #3 : filter { "workspaces:MyWorkspace", "configurations:Debug" } ]
--   [ Block #4 : filter { "workspaces:MyWorkspace", "projects:MyProject" } ]
--   [ Block #5 : filter { "workspaces:MyWorkspace", "projects:MyProject", "configurations:Debug" } ]
--
-- (I think this may turn out to have other advantages as well, like linking projects to
-- multiple workspaces, enabling filters to specify scopes with wildcard patterns.)
--
-- To avoid rewriting the entire container/API system *right now*, I instead leave
-- all of that as it is, and flattened it out the first time a query is compiled.
-- Eventually, I'd expect to rework the API system to build the flattened version
-- in the first place, and the containers would go away.
--
-- Author Jason Perkins
-- Copyright (c) 2018 Jason Perkins and the Premake project
---

	local p = premake

	local condition = require(path.join(_SCRIPT_DIR, 'condition'))

	local m = {}

	local flattenedDataBlocks = nil



---
-- Override `api.reset()`, which is called between each unit test run, use it to
-- blow away our cached flattened configuration list. For bonus points, I also
-- trim off any blocks that were added to the global scope by the tests, which
-- makes testing global state changes much easier.
---

	local startupGlobalBlockCount = #p.api.scope.global.blocks

	p.override(p.api, 'reset', function(base)
		base()

		flattenedDataBlocks = nil

		local currentGlobalBlockCount = #p.api.scope.global.blocks
		for i = currentGlobalBlockCount, startupGlobalBlockCount + 1, -1 do
			table.remove(p.api.scope.global.blocks, i)
		end
	end)



---
-- Retrieve the flattened version of the global configuration data, building
-- it if needed.
---

	function m.globalDataBlocks()
		if not flattenedDataBlocks then
			flattenedDataBlocks = m.buildGlobalBlockList()
		end
		return flattenedDataBlocks
	end



	function m.buildGlobalBlockList()
		local dataBlocks = {}
		local scopeTerms = {}

		m.addBlocksFromContainer(dataBlocks, p.api.scope.global, scopeTerms)

		return dataBlocks
	end



	function m.addBlocksFromContainer(dataBlocks, container, scopeTerms)
		local blocks = container.blocks
		local n = #blocks

		for i = 1, n do
			local block = blocks[i]

			local criteria = block._criteria
			local terms = table.join(criteria.terms, scopeTerms)
			block._condition = condition.new(terms)

			table.insert(dataBlocks, block)
		end

		for class in p.container.eachChildClass(container.class) do
			for child in p.container.eachChild(container, class) do
				local localScopeTerms = table.arraycopy(scopeTerms)
				table.insert(localScopeTerms, class.pluralName .. ':' .. child.name)
				m.addBlocksFromContainer(dataBlocks, child, localScopeTerms)
			end
		end
	end



---
-- End of module
---

	return m
