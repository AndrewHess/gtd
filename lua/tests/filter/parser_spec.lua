local Parser = require('gtd.filter.parser')
local ASTNode = require('gtd.filter.ast')

describe("Parser Tests", function()

    describe("Tag Parsing", function()
        it("parses a simple tag", function()
            local ast = Parser.parse("@work")
            assert.are.same(ast, ASTNode.Tag("@work"))
        end)
    end)

    describe("And Expression Parsing", function()
        it("parses an and expression with tags", function()
            local ast = Parser.parse("and(@work, @home)")
            assert.are.same(ast, ASTNode.And({ASTNode.Tag("@work"), ASTNode.Tag("@home")}))
        end)
    end)

    describe("Or Expression Parsing", function()
        it("parses an or expression with tags", function()
            local ast = Parser.parse("or(@work, @home)")
            assert.are.same(ast, ASTNode.Or({ASTNode.Tag("@work"), ASTNode.Tag("@home")}))
        end)
    end)

    describe("Not Expression Parsing", function()
        it("parses a not expression with a tag", function()
            local ast = Parser.parse("not(@work)")
            assert.are.same(ast, ASTNode.Not({ASTNode.Tag("@work")}))
        end)
        it("parses a not expression with multiple tags", function()
            local ast = Parser.parse("not(@work, @errand)")
            assert.are.same(ast, ASTNode.Not({ASTNode.Tag("@work"), ASTNode.Tag("@errand")}))
        end)
    end)

    describe("Nested Expressions Parsing", function()
        it("parses nested expressions", function()
            local ast = Parser.parse("and(@work, or(@home, not(@vacation)))")
            assert.are.same(ast, ASTNode.And({
                ASTNode.Tag("@work"),
                ASTNode.Or({
                    ASTNode.Tag("@home"),
                    ASTNode.Not({ASTNode.Tag("@vacation")})
                })
            }))
        end)
    end)

    -- Additional tests to cover edge cases, invalid inputs, etc.

end)

