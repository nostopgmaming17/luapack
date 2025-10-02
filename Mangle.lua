--
-- MangleTableProperties.lua
--
-- This module provides a function that takes a Lua AST, mangles all
-- table property names, and returns the modified AST.
-- It correctly handles ASTs with circular references to prevent stack overflows.
--

local Mangle = {}

-- The visitor table defines functions to be called on specific AST node types.
local visitor = {}

---
-- Recursively walks the AST and applies visitor functions to modify nodes.
-- @param node The current AST node or a table of nodes.
-- @param context A table holding the state for the current transformation pass.
--
function Mangle.traverse(node, context)
    -- VITAL FIX: Prevent infinite recursion from circular references in the AST.
    -- If the node is not a table or if we have already visited it, stop.
    if type(node) ~= 'table' or context.visited[node] then
        return
    end
    -- Mark the current node as visited BEFORE traversing its children.
    context.visited[node] = true

    -- 1. Apply the visitor function to the current node.
    local visitorFunc = visitor[node.AstType]
    if visitorFunc then
        visitorFunc(node, context)
    end

    -- 2. Recursively traverse the children of the current node.
    -- The pairs() iterator will correctly find all child nodes.
    for key, child in pairs(node) do
        Mangle.traverse(child, context)
    end
end

---
-- Visitor for Member Expressions (e.g., `table.property` or `table:method`)
--
function visitor.MemberExpr(node, context)
    local originalName = node.Ident.Data
    if originalName then
        node.Ident.Data = context.getMangledName(originalName)
    end
end

---
-- Visitor for Table Constructors (e.g., `t = { key = value }`)
--
function visitor.ConstructorExpr(node, context)
    if not node.EntryList then return end
    for _, entry in ipairs(node.EntryList) do
        -- Handles cases like `{ my_prop = value }`
        if entry.Type == 'KeyString' then
            local originalName = entry.Key
            entry.Key = context.getMangledName(originalName)

        -- Handles cases like `{ ["my_prop"] = value }`
        elseif entry.Type == 'Key' and entry.Key.AstType == 'StringExpr' then
            context.mangleStringNode(entry.Key)
        end
    end
end

---
-- Visitor for Index Expressions (e.g., `table["property"]`)
--
function visitor.IndexExpr(node, context)
    if node.Index and node.Index.AstType == 'StringExpr' then
        context.mangleStringNode(node.Index)
    end
end


---
-- This is the main function that will be returned by the module.
-- It sets up the context and initiates the AST traversal.
--
-- @param ast The Abstract Syntax Tree to be processed.
-- @return The modified Abstract Syntax Tree.
--
local function processAstAndMangleProperties(ast, auto)
    local context = {
        nameMap = {},
        nextNameId = 0,
        -- The 'visited' table is crucial for preventing stack overflows.
        -- Using a weak table for keys means it won't prevent garbage collection.
        visited = setmetatable({}, {__mode = "k"}),
    }

    ---
    -- Generates the next mangled name in the sequence (a, b, ..., z, aa, ab, ...).
    --
    function context.generateNextName()
        local n = context.nextNameId
        local name = ""
        repeat
            name = string.char(string.byte('a') + (n % 26)) .. name
            n = math.floor(n / 26) - 1
        until n < 0
        context.nextNameId = context.nextNameId + 1
        return name
    end

    ---
    -- Gets an existing mangled name or creates a new one for an original property name.
    --
    function context.getMangledName(originalName)
        if not auto and originalName:sub(1,1) ~= "_" then return originalName end
        if auto and originalName:sub(1,1) == "_" then return originalName:sub(2) end
        if not context.nameMap[originalName] then
            context.nameMap[originalName] = context.generateNextName()
        end
        return context.nameMap[originalName]
    end

    ---
    -- Helper function to mangle a StringExpr node used as a table key.
    --
    function context.mangleStringNode(stringNode)
        local fullStringLiteral = stringNode.Value.Data
        local quoteChar = fullStringLiteral:sub(1, 1)

        if quoteChar == "'" or quoteChar == '"' then
            local originalName = fullStringLiteral:sub(2, -2)
            local newName = context.getMangledName(originalName)
            stringNode.Value.Data = quoteChar .. newName .. quoteChar
            
            -- Also mark the string node's value table as visited, since it's part of the AST
            context.visited[stringNode.Value] = true
        end
    end

    -- Start the recursive traversal from the root of the AST.
    Mangle.traverse(ast, context)

    -- Return the modified AST.
    return ast
end

return processAstAndMangleProperties