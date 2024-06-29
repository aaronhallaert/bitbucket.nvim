local Writer = require("bitbucket.ui.writer")
describe("writer", function()
    describe("write", function()
        it("returns start and endline", function()
            -- create a buffer
            local buf = vim.api.nvim_create_buf(false, true)
            local start_line, end_line = Writer:write(buf, { "hello", "world" })

            assert(start_line, 1)
            assert(end_line, 2)
        end)

        it("does not override", function()
            local buf = vim.api.nvim_create_buf(false, true)
            local start_line_hello, end_line_hello =
                Writer:write(buf, { "hello" })
            local start_line_world, end_line_world =
                Writer:write(buf, { "world" })
            local start_line_last_lines, end_line_last_lines =
                Writer:write(buf, { "good", "bye" })

            assert(start_line_hello, 1)
            assert(end_line_hello, 1)
            assert(start_line_world, 2)
            assert(end_line_world, 2)
            assert(start_line_last_lines, 3)
            assert(end_line_last_lines, 4)
        end)
    end)
end)
