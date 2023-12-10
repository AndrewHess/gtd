local Evaluator = require('gtd.filter.evaluator')

describe("Evaluator Module Tests", function()

    describe("evaluateTag function", function()
        it("should return true if tag is present", function()
            local node = { type = "Tag", value = "@todo" }
            local fileTags = { ["@todo"] = true }
            assert.is_true(Evaluator.evaluateTag(node, fileTags))
        end)

        it("should return false if tag is not present", function()
            local node = { type = "Tag", value = "@todo" }
            local fileTags = { ["@done"] = true }
            assert.is_false(Evaluator.evaluateTag(node, fileTags))
        end)
    end)

    -- Test for evaluating And nodes
    describe("evaluateAnd function", function()
        it("should return true if all child nodes are true", function()
            local node = { type = "And", children = { 
                { type = "Tag", value = "@work" }, 
                { type = "Tag", value = "@urgent" } 
            }}
            local fileTags = { ["@work"] = true, ["@urgent"] = true }
            assert.is_true(Evaluator.evaluateAnd(node, fileTags))
        end)

        it("should return false if any child node is false", function()
            local node = { type = "And", children = { 
                { type = "Tag", value = "@work" }, 
                { type = "Tag", value = "@urgent" } 
            }}
            local fileTags = { ["@work"] = true }
            assert.is_false(Evaluator.evaluateAnd(node, fileTags))
        end)
    end)

    -- Tests for evaluating Or nodes
    describe("evaluateOr function", function()
        it("should return true if any child node is true", function()
            local node = {
                type = "Or",
                children = {
                    { type = "Tag", value = "@urgent" },
                    { type = "Tag", value = "@optional" }
                }
            }
            local fileTags = { ["@urgent"] = true }
            assert.is_true(Evaluator.evaluateOr(node, fileTags))
        end)

        it("should return false if all child nodes are false", function()
            local node = {
                type = "Or",
                children = {
                    { type = "Tag", value = "@urgent" },
                    { type = "Tag", value = "@optional" }
                }
            }
            local fileTags = { ["@completed"] = true }
            assert.is_false(Evaluator.evaluateOr(node, fileTags))
        end)

        it("should return true if at least one child node is true", function()
            local node = {
                type = "Or",
                children = {
                    { type = "Tag", value = "@urgent" },
                    { type = "Tag", value = "@completed" }
                }
            }
            local fileTags = { ["@completed"] = true, ["@optional"] = true }
            assert.is_true(Evaluator.evaluateOr(node, fileTags))
        end)
    end)

    -- Test for evaluating Not nodes
    describe("evaluateNot function", function()
        it("should return true if the child node is false", function()
            local node = { type = "Not", children = { 
                { type = "Tag", value = "@work" } 
            }}
            local fileTags = { ["@home"] = true }
            assert.is_true(Evaluator.evaluateNot(node, fileTags))
        end)

        it("should return false if the child node is true", function()
            local node = { type = "Not", children = { 
                { type = "Tag", value = "@work" } 
            }}
            local fileTags = { ["@work"] = true }
            assert.is_false(Evaluator.evaluateNot(node, fileTags))
        end)
    end)

    -- Test for the main evaluate function
    describe("evaluate function", function()
        it("should correctly evaluate complex expressions", function()
            local node = { -- Represents (@work And (@urgent Or Not @completed))
                type = "And", children = {
                    { type = "Tag", value = "@work" },
                    { type = "Or", children = {
                        { type = "Tag", value = "@urgent" },
                        { type = "Not", children = {
                            { type = "Tag", value = "@completed" }
                        }}
                    }}
                }
            }
            local fileTags = { ["@work"] = true, ["@urgent"] = true }
            assert.is_true(Evaluator.evaluate(node, fileTags))

            local fileTags2 = { ["@urgent"] = true }
            assert.is_false(Evaluator.evaluate(node, fileTags2))

            local fileTags3 = { ["@work"] = true }
            assert.is_true(Evaluator.evaluate(node, fileTags3))

            local fileTags4 = { ["@work"] = true, ["@completed"] = true }
            assert.is_false(Evaluator.evaluate(node, fileTags4))
        end)
    end)

end)

